import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/features/notifications/data/notification_repository.dart';
import 'package:yelo_laundry_customer/features/notifications/presentation/utils/notification_category.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

abstract final class NotificationFormat {
  static IconData iconForType(String type) {
    return resolveNotificationCategory(
      AppNotification(
        id: '',
        title: '',
        message: '',
        type: type,
        createdAt: DateTime.now().toIso8601String(),
        isRead: true,
      ),
    ).icon;
  }

  static DateTime? parseDate(String value) => DateTime.tryParse(value);

  static String relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
  }

  static String detailDateTime(DateTime dateTime) {
    return DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(dateTime.toLocal());
  }
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.category,
    this.onTap,
  });

  final AppNotification notification;
  final NotificationCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = NotificationFormat.parseDate(notification.createdAt);
    final isUnread = !notification.isRead;
    final orderNumber = notification.orderNumber?.trim();

    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isUnread
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: isUnread
                  ? const Border(
                      left: BorderSide(
                        color: AppColors.accent,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    size: 22,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: AppSpacing.s8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6CF00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Baru',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brandBlue,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (orderNumber != null && orderNumber.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Pesanan $orderNumber',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brandBlue,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        notification.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          NotificationFormat.relativeTime(date.toLocal()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
