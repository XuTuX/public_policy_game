import 'dart:math';
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

/// 커스텀 레이더 차트 위젯 (CustomPaint 활용)
class RadarChart extends StatelessWidget {
  final Map<String, double> stats; // 카테고리명 -> 0.0 ~ 1.0 찬성 비율
  final double size;

  const RadarChart({super.key, required this.stats, this.size = 240});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return SizedBox(
        height: size,
        child: const Center(child: Text('충분한 통계 데이터가 없습니다.')),
      );
    }

    final categories = stats.keys.toList();
    final values = stats.values.toList();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: RadarChartPainter(categories: categories, values: values),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<String> categories;
  final List<double> values;

  RadarChartPainter({required this.categories, required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.75;
    final count = categories.length;
    final angleStep = (2 * pi) / count;

    final axisPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final valuePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 1. 방사형 그리드 라인 그리기 (25%, 50%, 75%, 100%)
    for (int i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < count; j++) {
        final angle = j * angleStep - pi / 2;
        final point = Offset(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
        if (j == 0) {
          path.moveTo(point.dx, point.pointInside(center.dy, r, angle));
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. 축선 그리기 & 라벨 달기
    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - pi / 2;
      final outerPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // 중심에서 바깥쪽으로 뻗는 축선
      canvas.drawLine(center, outerPoint, axisPaint);

      // 라벨 텍스트 배치
      final textSpan = TextSpan(
        text: '${categories[i]}\n(${(values[i] * 100).toStringAsFixed(0)}%)',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // 글자가 차트 바깥으로 나가는 offset 보정
      final labelRadius = radius + 22;
      final labelOffset = Offset(
        center.dx + labelRadius * cos(angle) - textPainter.width / 2,
        center.dy + labelRadius * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, labelOffset);
    }

    // 3. 실제 값 데이터 다각형(Path) 그리기
    final valPath = Path();
    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - pi / 2;
      final valRadius =
          radius * values[i].clamp(0.05, 1.0); // 완전히 0이면 그리기가 어려우므로 최소값 부여
      final point = Offset(
        center.dx + valRadius * cos(angle),
        center.dy + valRadius * sin(angle),
      );

      if (i == 0) {
        valPath.moveTo(point.dx, point.dy);
      } else {
        valPath.lineTo(point.dx, point.dy);
      }
    }
    valPath.close();

    // 채우기 및 선 드로잉
    canvas.drawPath(valPath, valuePaint);
    canvas.drawPath(valPath, strokePaint);

    // 포인트 점 찍기
    final pointPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = i * angleStep - pi / 2;
      final valRadius = radius * values[i].clamp(0.05, 1.0);
      final point = Offset(
        center.dx + valRadius * cos(angle),
        center.dy + valRadius * sin(angle),
      );
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension OffsetHelper on Offset {
  double pointInside(double centerDy, double r, double angle) {
    return centerDy + r * sin(angle);
  }
}
