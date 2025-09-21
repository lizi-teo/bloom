import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final List<PendingOperation> _pendingOperations = [];
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();
  final StreamController<List<PendingOperation>> _pendingOperationsController = 
      StreamController<List<PendingOperation>>.broadcast();
  
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  Stream<List<PendingOperation>> get pendingOperationsStream => _pendingOperationsController.stream;
  
  bool _isOnline = true;
  bool _isSyncing = false;
  Timer? _syncTimer;
  Timer? _connectivityTimer;
  
  Duration _syncInterval = const Duration(minutes: 5);
  int _maxRetryAttempts = 3;
  Duration _retryDelay = const Duration(seconds: 30);
  
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  List<PendingOperation> get pendingOperations => List.unmodifiable(_pendingOperations);

  void initialize({
    Duration? syncInterval,
    int? maxRetryAttempts,
    Duration? retryDelay,
  }) {
    _syncInterval = syncInterval ?? _syncInterval;
    _maxRetryAttempts = maxRetryAttempts ?? _maxRetryAttempts;
    _retryDelay = retryDelay ?? _retryDelay;
    
    _loadPendingOperations();
    _startConnectivityMonitoring();
    _startPeriodicSync();
    
    debugPrint('OfflineSyncService initialized');
  }

  void _startConnectivityMonitoring() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnectivity();
    });
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (_isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      await Supabase.instance.client
          .from('sessions')
          .select('id')
          .limit(1)
          .timeout(const Duration(seconds: 5));
      
      _setOnlineStatus(true);
    } catch (e) {
      _setOnlineStatus(false);
    }
  }

  void _setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _syncStatusController.add(SyncStatus(
        isOnline: _isOnline,
        isSyncing: _isSyncing,
        pendingCount: _pendingOperations.length,
        lastSyncTime: DateTime.now(),
      ));
      
      if (_isOnline && _pendingOperations.isNotEmpty) {
        syncPendingOperations();
      }
      
      debugPrint('Connection status changed: ${_isOnline ? "Online" : "Offline"}');
    }
  }

  Future<T> executeOperation<T>(
    String operationType,
    Future<T> Function() onlineOperation,
    T Function() offlineOperation, {
    Map<String, dynamic>? operationData,
    bool requiresSync = true,
  }) async {
    if (_isOnline) {
      try {
        final result = await onlineOperation();
        debugPrint('Online operation completed: $operationType');
        return result;
      } catch (e) {
        debugPrint('Online operation failed, falling back to offline: $operationType, error: $e');
        _setOnlineStatus(false);
      }
    }

    // Execute offline operation
    final result = offlineOperation();
    
    if (requiresSync) {
      // Queue for sync when online
      final operation = PendingOperation(
        id: _generateId(),
        type: operationType,
        data: operationData ?? {},
        timestamp: DateTime.now(),
        retryCount: 0,
      );
      
      _addPendingOperation(operation);
    }
    
    debugPrint('Offline operation completed: $operationType');
    return result;
  }

  void _addPendingOperation(PendingOperation operation) {
    _pendingOperations.add(operation);
    _savePendingOperations();
    _pendingOperationsController.add(List.unmodifiable(_pendingOperations));
    
    _syncStatusController.add(SyncStatus(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingCount: _pendingOperations.length,
      lastSyncTime: DateTime.now(),
    ));
  }

  Future<void> syncPendingOperations() async {
    if (_isSyncing || _pendingOperations.isEmpty || !_isOnline) {
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingCount: _pendingOperations.length,
      lastSyncTime: DateTime.now(),
    ));

    debugPrint('Starting sync of ${_pendingOperations.length} pending operations');

    final operationsToSync = List<PendingOperation>.from(_pendingOperations);
    final syncedOperations = <String>[];
    final failedOperations = <PendingOperation>[];

    for (final operation in operationsToSync) {
      try {
        final success = await _syncOperation(operation);
        if (success) {
          syncedOperations.add(operation.id);
          debugPrint('Successfully synced operation: ${operation.type}');
        } else {
          operation.retryCount++;
          if (operation.retryCount >= _maxRetryAttempts) {
            failedOperations.add(operation);
            debugPrint('Operation failed permanently after ${operation.retryCount} attempts: ${operation.type}');
          } else {
            debugPrint('Operation failed, will retry: ${operation.type} (attempt ${operation.retryCount}/$_maxRetryAttempts)');
          }
        }
      } catch (e) {
        operation.retryCount++;
        debugPrint('Error syncing operation: ${operation.type}, error: $e');
        
        if (operation.retryCount >= _maxRetryAttempts) {
          failedOperations.add(operation);
        }
      }
    }

    // Remove synced operations
    _pendingOperations.removeWhere((op) => syncedOperations.contains(op.id));
    
    // Handle permanently failed operations
    for (final failedOp in failedOperations) {
      _pendingOperations.remove(failedOp);
      debugPrint('Permanently failed operation removed: ${failedOp.type}');
    }

    _savePendingOperations();
    _pendingOperationsController.add(List.unmodifiable(_pendingOperations));

    _isSyncing = false;
    _syncStatusController.add(SyncStatus(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingCount: _pendingOperations.length,
      lastSyncTime: DateTime.now(),
    ));

    debugPrint('Sync completed. ${syncedOperations.length} synced, ${failedOperations.length} failed, ${_pendingOperations.length} remaining');
  }

  Future<bool> _syncOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case 'create_session':
          return await _syncCreateSession(operation);
        case 'update_session':
          return await _syncUpdateSession(operation);
        case 'delete_session':
          return await _syncDeleteSession(operation);
        case 'submit_response':
          return await _syncSubmitResponse(operation);
        default:
          debugPrint('Unknown operation type: ${operation.type}');
          return false;
      }
    } catch (e) {
      debugPrint('Error in _syncOperation: $e');
      return false;
    }
  }

  Future<bool> _syncCreateSession(PendingOperation operation) async {
    try {
      final sessionData = operation.data['sessionData'] as Map<String, dynamic>;
      
      final response = await Supabase.instance.client
          .from('sessions')
          .insert(sessionData)
          .select()
          .single();
      
      // Update local storage with the server ID
      final localId = operation.data['localId'] as String?;
      if (localId != null) {
        _updateLocalIdMapping(localId, response['id']);
      }
      
      return true;
    } catch (e) {
      debugPrint('Failed to sync create session: $e');
      return false;
    }
  }

  Future<bool> _syncUpdateSession(PendingOperation operation) async {
    try {
      final sessionId = operation.data['sessionId'] as int;
      final updates = operation.data['updates'] as Map<String, dynamic>;
      
      await Supabase.instance.client
          .from('sessions')
          .update(updates)
          .eq('id', sessionId);
      
      return true;
    } catch (e) {
      debugPrint('Failed to sync update session: $e');
      return false;
    }
  }

  Future<bool> _syncDeleteSession(PendingOperation operation) async {
    try {
      final sessionId = operation.data['sessionId'] as int;
      
      await Supabase.instance.client
          .from('sessions')
          .delete()
          .eq('id', sessionId);
      
      return true;
    } catch (e) {
      debugPrint('Failed to sync delete session: $e');
      return false;
    }
  }

  Future<bool> _syncSubmitResponse(PendingOperation operation) async {
    try {
      final responseData = operation.data['responseData'] as Map<String, dynamic>;
      
      await Supabase.instance.client
          .from('responses')
          .insert(responseData);
      
      return true;
    } catch (e) {
      debugPrint('Failed to sync submit response: $e');
      return false;
    }
  }

  void _updateLocalIdMapping(String localId, int serverId) {
    try {
      final storage = web.window.localStorage;
      final mappingsJson = storage.getItem('bloom_id_mappings') ?? '{}';
      final mappings = Map<String, dynamic>.from(jsonDecode(mappingsJson));
      mappings[localId] = serverId;
      storage.setItem('bloom_id_mappings', jsonEncode(mappings));
    } catch (e) {
      debugPrint('Failed to update ID mapping: $e');
    }
  }

  int? getServerIdFromLocal(String localId) {
    try {
      final storage = web.window.localStorage;
      final mappingsJson = storage.getItem('bloom_id_mappings') ?? '{}';
      final mappings = Map<String, dynamic>.from(jsonDecode(mappingsJson));
      return mappings[localId] as int?;
    } catch (e) {
      debugPrint('Failed to get server ID mapping: $e');
      return null;
    }
  }

  void _savePendingOperations() {
    try {
      final storage = web.window.localStorage;
      final operationsJson = _pendingOperations.map((op) => op.toJson()).toList();
      storage.setItem('bloom_pending_operations', jsonEncode(operationsJson));
    } catch (e) {
      debugPrint('Failed to save pending operations: $e');
    }
  }

  void _loadPendingOperations() {
    try {
      final storage = web.window.localStorage;
      final operationsJson = storage.getItem('bloom_pending_operations');
      
      if (operationsJson != null) {
        final operationsList = List<Map<String, dynamic>>.from(jsonDecode(operationsJson));
        _pendingOperations.clear();
        
        for (final opData in operationsList) {
          _pendingOperations.add(PendingOperation.fromJson(opData));
        }
        
        debugPrint('Loaded ${_pendingOperations.length} pending operations from storage');
      }
    } catch (e) {
      debugPrint('Failed to load pending operations: $e');
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }

  void forceSyncNow() {
    if (_isOnline && !_isSyncing) {
      syncPendingOperations();
    }
  }

  void clearPendingOperations() {
    _pendingOperations.clear();
    _savePendingOperations();
    _pendingOperationsController.add(List.unmodifiable(_pendingOperations));
    
    _syncStatusController.add(SyncStatus(
      isOnline: _isOnline,
      isSyncing: _isSyncing,
      pendingCount: 0,
      lastSyncTime: DateTime.now(),
    ));
  }

  void dispose() {
    _syncTimer?.cancel();
    _connectivityTimer?.cancel();
    _syncStatusController.close();
    _pendingOperationsController.close();
  }
}

class PendingOperation {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.retryCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'PendingOperation(id: $id, type: $type, timestamp: $timestamp, retryCount: $retryCount)';
  }
}

class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
    required this.lastSyncTime,
  });

  @override
  String toString() {
    return 'SyncStatus(isOnline: $isOnline, isSyncing: $isSyncing, pendingCount: $pendingCount, lastSyncTime: $lastSyncTime)';
  }
}

// Widget to display sync status in the UI
class SyncStatusWidget extends StatelessWidget {
  final bool showWhenOnline;
  
  const SyncStatusWidget({
    super.key,
    this.showWhenOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: OfflineSyncService().syncStatusStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final status = snapshot.data!;
        
        if (status.isOnline && status.pendingCount == 0 && !showWhenOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withValues(alpha: 0.1),
            border: Border.all(color: _getStatusColor(status)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                size: 16,
                color: _getStatusColor(status),
              ),
              const SizedBox(width: 6),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(SyncStatus status) {
    if (!status.isOnline) return Colors.red;
    if (status.isSyncing) return Colors.blue;
    if (status.pendingCount > 0) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(SyncStatus status) {
    if (!status.isOnline) return Icons.wifi_off;
    if (status.isSyncing) return Icons.sync;
    if (status.pendingCount > 0) return Icons.sync_problem;
    return Icons.sync_alt;
  }

  String _getStatusText(SyncStatus status) {
    if (!status.isOnline) return 'Offline';
    if (status.isSyncing) return 'Syncing...';
    if (status.pendingCount > 0) return '${status.pendingCount} pending';
    return 'Synced';
  }
}