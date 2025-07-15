// lib/widgets/animated_text.dart
import 'package:flutter/material.dart';

class AnimatedText extends StatefulWidget {
  final List<String> texts;
  final TextStyle textStyle;
  final Duration animationDuration;
  
  const AnimatedText({
    super.key,
    required this.texts,
    required this.textStyle,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Metinleri döndür
    Future.delayed(widget.animationDuration, _rotateText);
  }

  void _rotateText() {
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.texts.length;
      });
      Future.delayed(widget.animationDuration * 2, _rotateText);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Text(
            widget.texts[_currentIndex],
            style: widget.textStyle.copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      },
    );
  }
}