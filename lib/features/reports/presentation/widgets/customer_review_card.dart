import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/reports/models/report_models.dart';

class CustomerReviewCard extends StatelessWidget {
  const CustomerReviewCard({
    super.key,
    required this.reviews,
  });

  final List<CustomerReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < reviews.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(height: AppSpacing.s16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.s16),
          ],
          _ReviewItem(review: reviews[i]),
        ],
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final CustomerReview review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StarRating(rating: review.rating),
            const Spacer(),
            Text(
              review.date,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          '"${review.comment}"',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          review.customerName,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: filled ? AppColors.accent : AppColors.divider,
        );
      }),
    );
  }
}
