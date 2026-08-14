import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/providers/core_providers.dart';
import 'package:yelo_laundry_customer/core/session/session_provider.dart';
import 'package:yelo_laundry_customer/features/address/data/address_repository.dart';
import 'package:yelo_laundry_customer/features/catalog/data/laundry_catalog_service.dart';
import 'package:yelo_laundry_customer/features/orders/data/order_repository.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_service_item_card.dart';

class PickupRequestScreen extends ConsumerStatefulWidget {
  const PickupRequestScreen({super.key});

  @override
  ConsumerState<PickupRequestScreen> createState() =>
      _PickupRequestScreenState();
}

class _PickupRequestScreenState extends ConsumerState<PickupRequestScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  static final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

  List<LaundryCatalogService> _services = [];
  List<OrderItem> _orders = [];
  List<CustomerAddress> _addresses = [];
  final Map<String, int> _quantities = {};
  String? _selectedAddressId;
  DateTime? _scheduledAt;
  final _notesController = TextEditingController();
  bool _usePickupDelivery = false;
  bool _loading = true;
  bool _submitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
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

  int _quantityFor(String serviceId) => _quantities[serviceId] ?? 0;

  int get _servicesSubtotal {
    var total = 0;
    for (final service in _services) {
      total += service.lineTotal(_quantityFor(service.id));
    }
    return total;
  }

  bool get _hasSelectedServices =>
      _quantities.values.any((quantity) => quantity > 0);

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final customerId = ref.read(sessionProvider).id;
      final servicesFuture =
          ref.read(catalogRepositoryProvider).fetchActiveServices();
      final ordersFuture = ref.read(orderRepositoryProvider).getOrders();
      final addressesFuture =
          ref.read(addressRepositoryProvider).list(customerId);

      final results = await Future.wait([
        servicesFuture,
        ordersFuture,
        addressesFuture,
      ]);

      if (!mounted) return;
      final services = results[0] as List<LaundryCatalogService>;
      final orders = results[1] as PaginatedOrders;
      final addresses = results[2] as List<CustomerAddress>;

      setState(() {
        _services = services;
        _orders = orders.items;
        _addresses = addresses;
        for (final service in services) {
          _quantities.putIfAbsent(service.id, () => 0);
        }
        if (_selectedAddressId == null && addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere(
            (item) => item.isDefault,
            orElse: () => addresses.first,
          );
          _selectedAddressId = defaultAddress.id;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _incrementService(String serviceId) {
    setState(() => _quantities[serviceId] = _quantityFor(serviceId) + 1);
  }

  void _decrementService(String serviceId) {
    final current = _quantityFor(serviceId);
    if (current <= 0) return;
    setState(() => _quantities[serviceId] = current - 1);
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  OrderItem? get _pickupEligibleOrder {
    if (_orders.isEmpty) return null;
    return _orders.firstWhere(
      (order) => order.pickupRequired,
      orElse: () => _orders.first,
    );
  }

  Future<void> _submit() async {
    if (!_hasSelectedServices) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu jasa laundry.')),
      );
      return;
    }

    if (_usePickupDelivery) {
      if (_selectedAddressId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih alamat pickup terlebih dahulu.')),
        );
        return;
      }

      final order = _pickupEligibleOrder;
      if (order == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Belum ada pesanan aktif untuk permintaan antar jemput.',
            ),
          ),
        );
        return;
      }

      setState(() => _submitting = true);
      try {
        await ref.read(pickupRepositoryProvider).createPickupRequest(
              orderId: order.id,
              pickupAddressId: _selectedAddressId,
              scheduledPickupAt: _scheduledAt,
              notes: _notesController.text.trim(),
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan antar jemput berhasil dikirim')),
        );
        context.pop();
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pilihan jasa tersimpan. Silakan antar laundry ke outlet Yelo Laundry.',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                    onPressed: () => context.pop(),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Pesan Laundry',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s4),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.s8),
                child: Text(
                  'Pilih jasa laundry dan atur opsi antar jemput.',
                  style: _poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        style: _poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    if (_services.isEmpty) {
      return PickupDashboardCard(
        child: Text(
          'Belum ada jasa laundry aktif.',
          style: _poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final service in _services) ...[
          PickupServiceItemCard(
            name: service.name,
            priceLabel: service.priceLabel,
            quantity: _quantityFor(service.id),
            onIncrement: () => _incrementService(service.id),
            onDecrement: () => _decrementService(service.id),
          ),
          const SizedBox(height: AppSpacing.s12),
        ],
      ],
    );
  }

  Widget _buildPickupDeliverySection() {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.brandBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  'Antar Jemput Laundry',
                  style: _poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            'Gunakan jasa antar jemput?',
            style: _poppins(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  value: false,
                  groupValue: _usePickupDelivery,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _usePickupDelivery = value);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.brandBlue,
                  title: Text('Tidak', style: _poppins(fontSize: 14)),
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  value: true,
                  groupValue: _usePickupDelivery,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _usePickupDelivery = value);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.brandBlue,
                  title: Text('Ya', style: _poppins(fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailsSection() {
    if (!_usePickupDelivery) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s12),
        _sectionTitle('Detail Antar Jemput'),
        PickupDashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedAddressId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Alamat Pickup',
                  labelStyle:
                      _poppins(fontSize: 13, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s12,
                  ),
                ),
                items: _addresses
                    .map(
                      (address) => DropdownMenuItem(
                        value: address.id,
                        child: Text(
                          '${address.recipientName} • ${address.label ?? address.district}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _poppins(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _addresses.isEmpty
                    ? null
                    : (value) => setState(() => _selectedAddressId = value),
              ),
              if (_selectedAddressId != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Text(
                  _addresses
                      .firstWhere((item) => item.id == _selectedAddressId)
                      .fullAddress,
                  style: _poppins(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.s12),
              InkWell(
                onTap: _pickSchedule,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.brandBlue,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu Pickup',
                            style: _poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            _scheduledAt == null
                                ? 'Pilih tanggal dan waktu'
                                : _dateFormat.format(_scheduledAt!),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: _poppins(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  labelStyle:
                      _poppins(fontSize: 13, color: AppColors.textSecondary),
                  alignLabelWithHint: true,
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSummary() {
    if (!_hasSelectedServices) return const SizedBox.shrink();

    return PickupDashboardCard(
      child: Column(
        children: [
          _summaryRow('Jasa Laundry', _currency.format(_servicesSubtotal)),
          const SizedBox(height: AppSpacing.s8),
          _summaryRow(
            'Antar Jemput',
            _usePickupDelivery ? 'Belum dikonfigurasi' : _currency.format(0),
            valueColor: _usePickupDelivery
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _summaryRow(
            'Total',
            _currency.format(_servicesSubtotal),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: _poppins(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: _poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (isTotal ? AppColors.brandBlue : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitting ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.brandBlue,
          disabledBackgroundColor:
              AppColors.accent.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandBlue,
                ),
              )
            : Text(
                _usePickupDelivery
                    ? 'Kirim Permintaan Antar Jemput'
                    : 'Simpan Pilihan Jasa',
                style: _poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.brandBlue),
              ),
            ),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gagal memuat data',
                        style: _poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        _loadError!,
                        style: _poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      FilledButton(
                        onPressed: _load,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                        ),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              color: AppColors.brandBlue,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s12,
                  AppSpacing.s16,
                  AppSpacing.s24,
                ),
                children: [
                  _sectionTitle('Pilih Jasa Laundry'),
                  _buildServiceList(),
                  const SizedBox(height: AppSpacing.s4),
                  _sectionTitle('Antar Jemput'),
                  _buildPickupDeliverySection(),
                  _buildPickupDetailsSection(),
                  const SizedBox(height: AppSpacing.s12),
                  _buildTotalSummary(),
                  const SizedBox(height: AppSpacing.s16),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
