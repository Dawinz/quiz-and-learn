import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class TaskRatingWidget extends StatelessWidget {
  final int rating;

  const TaskRatingWidget({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? AppColors.warning : AppColors.textSecondary,
          size: 24,
        );
      }),
    );
  }
}
