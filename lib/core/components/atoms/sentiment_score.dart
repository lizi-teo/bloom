import 'package:flutter/material.dart';
import '../../themes/spacing_theme.dart';

enum SentimentType {
  positive,
  neutral,
  negative,
}

class SentimentScore extends StatelessWidget {
  final String score;
  final SentimentType sentimentType;
  final double size;
  
  const SentimentScore({
    super.key,
    required this.score,
    required this.sentimentType,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Color backgroundColor;
    Color textColor;
    
    switch (sentimentType) {
      case SentimentType.positive:
        backgroundColor = const Color(0xFF02542D); // positive secondary background
        textColor = const Color(0xFFCFF7D3); // positive text
        break;
      case SentimentType.neutral:
        backgroundColor = const Color(0xFF682D03); // warning secondary background
        textColor = const Color(0xFFFFF1C2); // warning text
        break;
      case SentimentType.negative:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        break;
    }
    
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(context.spacing.xs / 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          score,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: textColor,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}