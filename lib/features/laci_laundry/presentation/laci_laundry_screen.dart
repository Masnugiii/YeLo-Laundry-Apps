import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_erp/app/theme/app_colors.dart';
import 'package:yelo_laundry_erp/app/theme/app_spacing.dart';
import 'package:yelo_laundry_erp/shared/widgets/api_state_widgets.dart';
import 'package:yelo_laundry_erp/features/laci_laundry/presentation/widgets/laci_feature_app_bar.dart';
import 'package:yelo_laundry_erp/features/laci_laundry/providers/laci_laundry_provider.dart';

class LaciLaundryScreen extends ConsumerStatefulWidget {
  const LaciLaundryScreen({super.key});

  @override
  ConsumerState<LaciLaundryScreen> createState() => _LaciLaundryScreenState();
}

class _LaciLaundryScreenState extends ConsumerState<LaciLaundryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _searching = false;
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
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

  Future<void> _refresh() async {
    ref.invalidate(laciLaundryLockersProvider);
    ref.invalidate(laciLaundryDashboardProvider);
    await ref.read(laciLaundryLockersProvider.future);
  }

  Future<void> _runSearch() async {
    final q = _searchController.text.trim();
    setState(() {
      _searchQuery = q;
      _searching = true;
    });

    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }

    try {
      final response = await ref.read(laciLaundryRepositoryProvider).searchBoxes(q: q);
      final items = (response['items'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _searchResults = items;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  List<Map<String, dynamic>> _filterBoxes(List<dynamic> boxes) {
    if (_searchQuery.trim().isEmpty) return boxes.cast<Map<String, dynamic>>();
    final q = _searchQuery.toLowerCase();
    return boxes.cast<Map<String, dynamic>>().where((box) {
      final code = (box['code'] as String? ?? '').toLowerCase();
      final orderCount = box['orderCount'] as int? ?? 0;
      final orders = (box['orders'] as List<dynamic>? ?? []);
      return code.contains(q) ||
          orders.any((order) {
            final item = order as Map<String, dynamic>;
            final orderNumber = (item['orderNumber'] as String? ?? '').toLowerCase();
            final customerName = (item['customerName'] as String? ?? '').toLowerCase();
            final customerPhone = (item['customerPhone'] as String? ?? '').toLowerCase();
            return orderNumber.contains(q) ||
                customerName.contains(q) ||
                customerPhone.contains(q);
          }) ||
          (orderCount > 0 && '$orderCount order'.contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lockersAsync = ref.watch(laciLaundryLockersProvider);
    final dashboardAsync = ref.watch(laciLaundryDashboardProvider);
    final canManage = ref.watch(canManageStorageProvider);

    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: const LaciFeatureAppBar(title: 'Laci Laundry'),
      body: lockersAsync.when(
        loading: () => const ApiLoadingView(message: 'Memuat laci laundry...'),
        error: (error, _) => ApiErrorView(
          message: messageFromError(error),
          onRetry: _refresh,
        ),
        data: (lockers) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.s16),
              children: [
                dashboardAsync.maybeWhen(
                  data: (dashboard) => _DashboardSummary(dashboard: dashboard),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.s12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari lokasi, order, customer, atau HP',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: AppColors.primary),
                      onPressed: _runSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (_) => _runSearch(),
                ),
                if (_searching)
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s12),
                    child: LinearProgressIndicator(),
                  ),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'Hasil Pencarian',
                    style: _poppins(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  ..._searchResults.map((box) => _SearchResultCard(
                        box: box,
                        onTap: () => context.push('/laci-laundry/box/${box['code']}'),
                      )),
                  const SizedBox(height: AppSpacing.s16),
                ],
                ...lockers.map((locker) {
                  final boxes = _filterBoxes(locker['boxes'] as List<dynamic>? ?? []);
                  if (_searchQuery.isNotEmpty && boxes.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _LockerCard(
                    locker: locker,
                    boxes: boxes.isEmpty && _searchQuery.isEmpty
                        ? (locker['boxes'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>()
                        : boxes,
                    canManage: canManage,
                    onBoxTap: (box) => context.push('/laci-laundry/box/${box['code']}'),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({required this.dashboard});

  final Map<String, dynamic> dashboard;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: _metric('Laci', '${dashboard['totalLockers'] ?? 3}'),
            ),
            Expanded(
              child: _metric('Kotak', '${dashboard['totalBoxes'] ?? 39}'),
            ),
            Expanded(
              child: _metric('Order', '${dashboard['totalOrdersInStorage'] ?? 0}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.box, required this.onTap});

  final Map<String, dynamic> box;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final orderCount = box['orderCount'] as int? ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: ListTile(
        title: Text(box['code'] as String? ?? '-'),
        subtitle: Text(
          orderCount > 0 ? '$orderCount ORDER · ${box['statusLabel']}' : 'KOSONG',
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}

class _LockerCard extends StatelessWidget {
  const _LockerCard({
    required this.locker,
    required this.boxes,
    required this.canManage,
    required this.onBoxTap,
  });

  final Map<String, dynamic> locker;
  final List<Map<String, dynamic>> boxes;
  final bool canManage;
  final ValueChanged<Map<String, dynamic>> onBoxTap;

  @override
  Widget build(BuildContext context) {
    final occupied = boxes.where((b) => (b['orderCount'] as int? ?? 0) > 0).length;
    final total = locker['totalBoxes'] as int? ?? boxes.length;
    final available = total - occupied;
    final orderCount = locker['orderCount'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  size: LaciFeatureAppBar.titleIconSize,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    locker['name'] as String? ?? 'Laci',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              '$total Kotak · $available Kosong · $occupied Terisi · $orderCount Order',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: boxes.map((box) {
                final orderCount = box['orderCount'] as int? ?? 0;
                final occupiedBox = orderCount > 0;
                return InkWell(
                  onTap: () => onBoxTap(box),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 96,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: occupiedBox
                          ? const Color(0xFFFFF3CD)
                          : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: occupiedBox
                            ? const Color(0xFFF6CF00)
                            : const Color(0xFF81C784),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${box['boxNumber']}'.padLeft(2, '0'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          occupiedBox ? 'TERISI' : 'KOSONG',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: occupiedBox
                                ? AppColors.primary
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                        if (occupiedBox) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$orderCount ORDER',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (!canManage)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s8),
                child: Text(
                  'Mode baca saja',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
