import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yelo_laundry_customer/app/theme/app_spacing.dart';
import 'package:yelo_laundry_customer/app/theme/app_theme.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_menu_section.dart';
import 'package:yelo_laundry_customer/core/widgets/dashboard_page_header.dart';
import 'package:yelo_laundry_customer/features/help/data/help_center_content.dart';
import 'package:yelo_laundry_customer/features/pickup/presentation/widgets/pickup_dashboard_card.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TextStyle _poppins({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        title,
        style: _poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.brandBlue,
        ),
      ),
    );
  }

  List<HelpFaqItem> get _filteredFaqs {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return HelpCenterContent.faqs;

    return HelpCenterContent.faqs.where((item) {
      if (item.question.toLowerCase().contains(query)) return true;
      if (item.answer.toLowerCase().contains(query)) return true;
      return item.keywords.any((keyword) => keyword.toLowerCase().contains(query));
    }).toList();
  }

  Widget _buildSearchField() {
    return PickupDashboardCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        style: _poppins(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Cari bantuan...',
          hintStyle: _poppins(fontSize: 14, color: AppColors.textSecondary),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.brandBlue,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.textSecondary,
                ),
        ),
      ),
    );
  }

  void _openCategoryRoute(BuildContext context, String route) {
    // Shell tab routes must use go() — push() stacks a duplicate navigator path.
    const shellTabRoutes = {
      '/home',
      '/pickup',
      '/completed-orders',
      '/profile',
    };
    if (shellTabRoutes.contains(route)) {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  Widget _buildCategories(BuildContext context) {
    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < HelpCenterContent.categories.length; i++) ...[
            DashboardMenuTile(
              entry: DashboardMenuEntry(
                icon: HelpCenterContent.categories[i].icon,
                label: HelpCenterContent.categories[i].label,
                onTap: HelpCenterContent.categories[i].route == null
                    ? null
                    : () => _openCategoryRoute(
                          context,
                          HelpCenterContent.categories[i].route!,
                        ),
              ),
            ),
            if (i < HelpCenterContent.categories.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.divider,
                indent: 64,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildFaqList() {
    final items = _filteredFaqs;

    if (items.isEmpty) {
      return PickupDashboardCard(
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              _query.isEmpty
                  ? 'Belum Ada Informasi Bantuan'
                  : 'Tidak ada hasil untuk "$_query"',
              textAlign: TextAlign.center,
              style: _poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_query.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Coba kata kunci lain atau lihat kategori bantuan.',
                textAlign: TextAlign.center,
                style: _poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      );
    }

    return PickupDashboardCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.divider,
          splashColor: AppColors.brandBlue.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s16,
                  vertical: AppSpacing.s4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  0,
                  AppSpacing.s16,
                  AppSpacing.s12,
                ),
                iconColor: AppColors.brandBlue,
                collapsedIconColor: AppColors.textSecondary,
                title: Text(
                  items[i].question,
                  style: _poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].answer,
                      style: _poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (i < items.length - 1)
                const Divider(height: 1, color: AppColors.divider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return PickupDashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Butuh bantuan lebih lanjut?',
            style: _poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Tim Yelo siap membantu kamu.',
            style: _poppins(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/help/customer-service'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Hubungi Customer Service',
                style: _poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const DashboardPageHeader(title: 'Pusat Bantuan'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s16,
                AppSpacing.s24,
              ),
              children: [
                _buildSearchField(),
                const SizedBox(height: AppSpacing.s20),
                _buildSectionTitle('Kategori Bantuan'),
                _buildCategories(context),
                const SizedBox(height: AppSpacing.s20),
                _buildSectionTitle('Pertanyaan Umum'),
                _buildFaqList(),
                const SizedBox(height: AppSpacing.s20),
                _buildContactCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
