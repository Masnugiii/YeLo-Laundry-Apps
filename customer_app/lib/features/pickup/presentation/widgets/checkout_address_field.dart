import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/maps/google_maps_config.dart';
import 'package:yelo_laundry_customer/core/maps/location_service.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_address_input.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/map_location_picker_screen.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class CheckoutAddressField extends StatefulWidget {
  const CheckoutAddressField({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.mapPickerTitle,
  });

  final String title;
  final CheckoutAddressInput value;
  final ValueChanged<CheckoutAddressInput> onChanged;
  final String? mapPickerTitle;

  @override
  State<CheckoutAddressField> createState() => _CheckoutAddressFieldState();
}

class _CheckoutAddressFieldState extends State<CheckoutAddressField> {
  late final TextEditingController _controller;
  final _locationService = LocationService();
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.address);
  }

  @override
  void didUpdateWidget(covariant CheckoutAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.address != _controller.text) {
      _controller.text = widget.value.address;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  Future<void> _openMapPicker() async {
    if (!GoogleMapsConfig.isConfigured) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Maps belum dikonfigurasi. Anda tetap bisa mengisi alamat manual.',
          ),
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<CheckoutAddressInput>(
      MaterialPageRoute(
        builder: (_) => MapLocationPickerScreen(
          title: widget.mapPickerTitle ?? widget.title,
          initial: widget.value,
        ),
      ),
    );

    if (result == null || !mounted) return;
    _controller.text = result.address;
    widget.onChanged(result);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak. Gunakan peta atau ketik alamat manual.',
            ),
          ),
        );
        return;
      }

      final address = await _locationService.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      final next = CheckoutAddressInput(
        address: address ?? widget.value.address,
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _controller.text = next.address;
      widget.onChanged(next);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.brandBlue),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  widget.title,
                  style: _poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            style: _poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ketik alamat atau pilih dari Maps',
              hintStyle: _poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.all(AppSpacing.s12),
            ),
            onChanged: (text) {
              widget.onChanged(widget.value.copyWith(address: text));
            },
          ),
          if (widget.value.coordinatesLabel != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(
              '📍 ${widget.value.coordinatesLabel}',
              style: _poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: 'Pilih dari Maps',
                  emphasized: true,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: _actionButton(
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 16),
                  label: 'Lokasi Saya',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
    bool emphasized = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.brandBlue,
        side: BorderSide(
          color: emphasized ? AppColors.brandBlue : AppColors.divider,
        ),
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s8,
        ),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: AppSpacing.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
