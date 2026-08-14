import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/maps/google_maps_config.dart';
import 'package:yelo_laundry_customer/core/maps/location_service.dart';
import 'package:yelo_laundry_customer/features/pickup/models/checkout_address_input.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({
    super.key,
    required this.title,
    this.initial,
  });

  final String title;
  final CheckoutAddressInput? initial;

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final _locationService = LocationService();
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;

  late LatLng _target;
  String _addressPreview = '';
  bool _loadingAddress = false;
  bool _locating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _target = LatLng(
      widget.initial?.latitude ?? GoogleMapsConfig.defaultLatitude,
      widget.initial?.longitude ?? GoogleMapsConfig.defaultLongitude,
    );
    _addressPreview = widget.initial?.address ?? '';
    if (_addressPreview.isEmpty) {
      _resolveAddress(_target);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
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

  Future<void> _resolveAddress(LatLng position) async {
    setState(() {
      _loadingAddress = true;
      _error = null;
    });

    try {
      final address = await _locationService.reverseGeocode(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      if (!mounted) return;
      setState(() {
        _addressPreview = address ?? _addressPreview;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal membaca alamat dari lokasi ini.';
      });
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _moveTo(LatLng position, {bool resolve = true}) async {
    setState(() => _target = position);
    await _mapController?.animateCamera(CameraUpdate.newLatLng(position));
    if (resolve) await _resolveAddress(position);
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _error =
              'Izin lokasi ditolak atau layanan lokasi tidak aktif. Pilih lokasi di peta atau ketik alamat manual.';
        });
        return;
      }

      await _moveTo(LatLng(position.latitude, position.longitude));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loadingAddress = true;
      _error = null;
    });

    try {
      final position = await _locationService.geocodeAddress(query);
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _error = 'Alamat tidak ditemukan. Coba kata kunci lain.';
        });
        return;
      }

      await _moveTo(
        LatLng(position.latitude, position.longitude),
        resolve: false,
      );
      setState(() => _addressPreview = query);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal mencari alamat.';
      });
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  void _confirmSelection() {
    final address = _addressPreview.trim();
    if (address.isEmpty) {
      setState(() {
        _error = 'Alamat belum tersedia. Geser peta atau cari lokasi.';
      });
      return;
    }

    Navigator.of(context).pop(
      CheckoutAddressInput(
        address: address,
        latitude: _target.latitude,
        longitude: _target.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!GoogleMapsConfig.isConfigured) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brandBlue,
          foregroundColor: Colors.white,
          title: Text(widget.title, style: _poppins(fontSize: 16)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Center(
            child: Text(
              'Google Maps API key belum dikonfigurasi. '
              'Tetap bisa mengisi alamat secara manual di halaman sebelumnya.',
              textAlign: TextAlign.center,
              style: _poppins(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s8,
                  AppSpacing.s8,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    TextField(
                      controller: _searchController,
                      style: _poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cari alamat...',
                        hintStyle: _poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: _loadingAddress ? null : _searchAddress,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                          vertical: AppSpacing.s12,
                        ),
                      ),
                      onSubmitted: (_) => _searchAddress(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _target,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) => _target = position.target,
                  onCameraIdle: () => _resolveAddress(_target),
                ),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Icon(
                      Icons.location_on,
                      size: 42,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
                Positioned(
                  right: AppSpacing.s16,
                  bottom: AppSpacing.s16,
                  child: FloatingActionButton.extended(
                    heroTag: 'current-location',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brandBlue,
                    onPressed: _locating ? null : _useCurrentLocation,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      'Lokasi saya',
                      style: _poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi terpilih',
                    style: _poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  if (_loadingAddress)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: AppColors.brandBlue,
                    )
                  else
                    Text(
                      _addressPreview.isEmpty
                          ? 'Geser peta untuk memilih lokasi'
                          : _addressPreview,
                      style: _poppins(fontSize: 14),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      _error!,
                      style: _poppins(fontSize: 12, color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loadingAddress ? null : _confirmSelection,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.brandBlue,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Gunakan lokasi ini',
                        style: _poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
