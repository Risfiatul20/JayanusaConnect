import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/aspiration_model.dart';
import '../../services/aspiration_service.dart';
import 'aspiration_form_screen.dart';
import 'aspiration_detail_screen.dart';

class AspirationListScreen extends StatefulWidget {
  const AspirationListScreen({super.key});

  @override
  State<AspirationListScreen> createState() => _AspirationListScreenState();
}

class _AspirationListScreenState extends State<AspirationListScreen> {
  final _service = AspirationService();
  List<AspirationModel> _aspirations = [];
  bool _loading = true;
  String? _error;
  String _activeFilter = 'semua';

  static const _filters = ['semua', 'dikirim', 'diproses', 'selesai'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getAspirations(
      status: _activeFilter == 'semua' ? null : _activeFilter,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      final items = (result['data']['data'] as List? ?? [])
          .map((e) => AspirationModel.fromJson(e))
          .toList();
      setState(() { _aspirations = items; _loading = false; });
    } else {
      setState(() { _error = result['message']; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF3B2FC9).withValues(alpha: 0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────────
              _buildAppBar(),

              // ── Filter chips ─────────────────────────────────────────────
              _buildFilterChips(),

              // ── Content ──────────────────────────────────────────────────
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.tertiaryAlt))
                    : _error != null
                        ? _buildError()
                        : _aspirations.isEmpty
                            ? _buildEmpty()
                            : _buildList(),
              ),
            ],
          ),

          // ── FAB ──────────────────────────────────────────────────────────
          Positioned(
            bottom: 24, right: 20,
            child: _buildFab(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        border: const Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aspirasi & Dialog',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.01,
                      ),
                    ),
                    Text(
                      'Sampaikan suara Anda untuk kemajuan kampus',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _load,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final active = _activeFilter == f;
          return GestureDetector(
            onTap: () {
              setState(() => _activeFilter = f);
              _load();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppColors.tertiary : AppColors.glassSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.tertiary : AppColors.glassBorder,
                ),
                boxShadow: active
                    ? [BoxShadow(color: AppColors.tertiaryAlt.withValues(alpha: 0.3), blurRadius: 10)]
                    : [],
              ),
              child: Text(
                f[0].toUpperCase() + f.substring(1),
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.onTertiary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: AppColors.tertiaryAlt,
      backgroundColor: AppColors.surfaceContainer,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: _aspirations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(_aspirations[i]),
      ),
    );
  }

  Widget _buildCard(AspirationModel a) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AspirationDetailScreen(aspirationId: a.id)),
      ).then((_) => _load()),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Category badge
                if (a.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      a.category!.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tertiary,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '• ${a.timeAgo}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    color: AppColors.outline,
                  ),
                ),
                const Spacer(),
                // Status badge
                _statusBadge(a.status),
              ],
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              a.title,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),

            // Content preview
            Text(
              a.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: 10),

            // Footer
            Row(
              children: [
                Text(
                  'ID: #ASP-${a.id.toString().padLeft(4, '0')}',
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    color: AppColors.outline,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg, text, border;
    switch (status) {
      case 'diproses':
        bg = AppColors.secondaryContainer.withValues(alpha: 0.3);
        text = AppColors.secondary;
        border = AppColors.secondaryContainer;
        break;
      case 'selesai':
        bg = AppColors.tertiary.withValues(alpha: 0.1);
        text = AppColors.tertiary;
        border = AppColors.tertiary.withValues(alpha: 0.3);
        break;
      default:
        bg = AppColors.surfaceVariant.withValues(alpha: 0.5);
        text = AppColors.onSurfaceVariant;
        border = AppColors.outlineVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: text,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined, color: AppColors.tertiary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada aspirasi',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + untuk kirim aspirasi pertama Anda',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Terjadi kesalahan',
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _load,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AspirationFormScreen()),
      ).then((_) => _load()),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiaryAlt.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.onTertiary, size: 28),
      ),
    );
  }
}
