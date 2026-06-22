import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';
import '../models/vote_model.dart';

/// 대화형 선택지 버튼 (세로형)
class NarrativeVoteButton extends StatefulWidget {
  final VoteType voteType;
  final String text;
  final VoidCallback onPressed;
  final bool enabled;
  final bool isSelected;

  const NarrativeVoteButton({
    super.key,
    required this.voteType,
    required this.text,
    required this.onPressed,
    this.enabled = true,
    this.isSelected = false,
  });

  @override
  State<NarrativeVoteButton> createState() => _NarrativeVoteButtonState();
}

class _NarrativeVoteButtonState extends State<NarrativeVoteButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant NarrativeVoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.voteType) {
      case VoteType.yes:
        return AppColors.voteYes;
      case VoteType.no:
        return AppColors.voteNo;
      case VoteType.abstain:
        return AppColors.textSecondary;
    }
  }

  Color get _bgColor {
    switch (widget.voteType) {
      case VoteType.yes:
        return AppColors.voteYesBg;
      case VoteType.no:
        return AppColors.voteNoBg;
      case VoteType.abstain:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: widget.isSelected ? _color : _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _color.withValues(alpha: widget.enabled ? 0.3 : 0.1),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Text(
                widget.voteType.emoji,
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: widget.isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
