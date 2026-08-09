import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/features/new_order/data/dummy_laundry_services.dart';
import 'package:yelo_laundry_erp/features/new_order/models/laundry_service.dart';

void showServiceBottomSheet(
  BuildContext context, {
  required ValueChanged<LaundryService> onServiceSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ServiceBottomSheet(onServiceSelected: onServiceSelected),
  );
}

class _ServiceBottomSheet extends StatelessWidget {
  const _ServiceBottomSheet({required this.onServiceSelected});

  final ValueChanged<LaundryService> onServiceSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s12,
        AppSpacing.s20,
        AppSpacing.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Pilih Layanan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: dummyLaundryServices.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final service = dummyLaundryServices[index];
                return _ServiceListTile(
                  service: service,
                  onTap: () {
                    onServiceSelected(service);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  const _ServiceListTile({
    required this.service,
    required this.onTap,
  });

  final LaundryService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Harga: ${service.priceLabel}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (service.description != null) ...[
                const SizedBox(height: AppSpacing.s4),
                Text(
                  service.description!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
