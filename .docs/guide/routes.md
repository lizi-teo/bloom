# Routing Architecture

This document describes the routing system and access control patterns in the Bloom app.

## Route Types

The app has three main types of routes:

### 1. Private Routes (Facilitators Only)
These routes require authentication and are protected by `ConditionalAuthWrapper`:

- **`/`** - Dashboard screen (home page for authenticated facilitators)
- **`/session/results/{id}`** - Session results view for facilitators
- **Demo routes** - Testing/development screens (cards, components, etc.)

### 2. Public Routes (No Authentication)
These routes are accessible without authentication:

- **`/login`** - Login screen
- **`/demo`** - Public demo screen

### 3. Participant Routes (No Authentication)
These routes allow anonymous participants to access sessions:

- **`/session/{id}`** - Access session by numeric ID
- **`/session/{code}`** - Access session by alphanumeric code

## Authentication Logic

### ConditionalAuthWrapper
Located in `lib/core/widgets/auth_wrapper.dart`, this component conditionally applies authentication based on the route:

```dart
bool requiresAuth(String? routeName) {
  // Participant routes - no auth required
  if (routeName.startsWith('/session/')) {
    return false;
  }
  
  // Public routes - no auth required  
  const publicRoutes = ['/login', '/signup'];
  if (publicRoutes.contains(routeName)) {
    return false;
  }
  
  // All other routes require auth (facilitator routes)
  return true;
}
```

### Route Protection Implementation
In `lib/main.dart`, routes are wrapped with `ConditionalAuthWrapper`:

```dart
// Private route example
DashboardScreen.routeName: (context) => const ConditionalAuthWrapper(
  routeName: DashboardScreen.routeName, 
  child: DashboardScreen()
),

// Public participant route example (in onGenerateRoute)
return MaterialPageRoute(
  builder: (context) => DynamicTemplatePage(sessionId: sessionId), // No wrapper
  settings: settings,
);
```

## Dynamic Route Handling

The app uses `onGenerateRoute` to handle dynamic URL patterns:

### Session Results (Facilitator)
- **Pattern**: `/session/results/{id}`
- **Access**: Requires authentication
- **Implementation**: Wrapped with `ConditionalAuthWrapper`

### Session Access (Participant)
- **Pattern**: `/session/{id}` or `/session/{code}`
- **Access**: No authentication required
- **Implementation**: Direct route to `DynamicTemplatePage`

## User Types

User types are defined in `lib/core/models/user_model.dart`:

- **`facilitator`** (default) - Authenticated users who create and manage sessions
- **`participant`** - Implied for anonymous session access (no user model required)

## Implementation Files

- **Main routing**: `lib/main.dart` (lines 58-118)
- **Auth wrapper**: `lib/core/widgets/auth_wrapper.dart` (lines 91-143)
- **User model**: `lib/core/models/user_model.dart` (lines 28, 47)

## Security Model

The routing system follows a simple security model:

1. **Facilitator actions** (creating, managing, viewing results) require authentication
2. **Participant actions** (joining sessions) are public and anonymous
3. **Session access** is controlled by knowledge of session ID/code, not authentication
4. **No mixed permissions** - routes are either fully public or fully private