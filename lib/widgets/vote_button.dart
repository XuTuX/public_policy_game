import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/vote_model.dart';

/// O(찬성) / X(반대) 대형 투표 버튼
class VoteButton extends StatefulWidget {
  final VoteType voteType;
  final VoidCallback onPressed;
  final bool enabled;

  const VoteButton({
    super.key,
    required this.voteType,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isYes => widget.voteType == VoteType.yes;

  Color get _color => _isYes ? AppColors.voteYes : AppColors.voteNo;
  Color get _bgColor => _isYes ? AppColors.voteYesBg : AppColors.voteNoBg;
  String get _label => _isYes ? '찬성' : '반대';
  String get _emoji => _isYes ? '⭕' : '❌';

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.enabled) _controller.forward();
          },
          onTapUp: (_) {
            if (widget.enabled) {
              _controller.reverse();
              widget.onPressed();
            }
          },
          onTapCancel: () {
            if (widget.enabled) _controller.reverse();
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: widget.enabled ? _bgColor : _bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.enabled
                    ? _color.withValues(alpha: 0.3)
                    : _color.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _label,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
