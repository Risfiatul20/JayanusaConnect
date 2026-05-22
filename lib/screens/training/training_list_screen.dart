import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/training_model.dart';
import '../../services/training_service.dart';
import 'training_detail_screen.dart';

class TrainingListScreen extends StatefulWidget {
  const TrainingListScreen({super.key});

  @override
  State<TrainingListScreen> createState() => _TrainingListScreenState();
}

class _TrainingListScreenState extends State<TrainingListScreen> {
  final _service = TrainingService();
  List<TrainingModel> _trainings = [];
  bool _loading = true;
  String? _error;
  String _activeCategory = 'Semua';

  static const _categories = [
    'Semua', 'AI & Data Science', 'Programming',
    'UI/UX Design', 'Cybersecurity', 'Mobile Dev', 'Desain',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getTrainings(
      category: _activeCategory == 'Semua' ? null : _activeCategory,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      final items = (result['data']['data'] as List? ?? [])
          .map((e) => TrainingModel.fromJson(e))
          .toList();
      setState(() { _trainings = items; _loading = false; });
    } else {
      setState(() { _error = result['message']; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.tertiaryAlt))
                : _error != null
                    ? _buildError()
                    : _trainings.isEmpty
                        ? _buildEmpty()
                        : _buildContent(),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
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
                      'Pelatihan & Sertifikasi',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.01,
                      ),
                    ),
                    Text(
                      'Tingkatkan kompetensi teknologi Anda',
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

  // ── Category Filter ───────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final active = _activeCategory == cat;
          return GestureDetector(
            onTap: () {
              setState(() => _activeCategory = cat);
              _load();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                cat,
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

  // ── Content ───────────────────────────────────────────────────────────────
  Widget _buildContent() {
    return RefreshIndicator(
      color: AppColors.tertiaryAlt,
      backgroundColor: AppColors.surfaceContainer,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          // Hero card — pelatihan pertama
          if (_trainings.isNotEmpty) ...[
            _buildHeroCard(_trainings.first),
            const SizedBox(height: 20),
          ],

          // Section title
          if (_trainings.length > 1) ...[
            const Text(
              'Semua Pelatihan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Grid cards
          ...(_trainings.length > 1
              ? _trainings.skip(1).map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCard(t),
                  ))
              : []),
        ],
      ),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard(TrainingModel t) {
    return GestureDetector(
      onTap: () => _openDetail(t.id),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A3A), Color(0xFF0D1B2A)],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative glow
            Positioned(
              top: -40, right: -40,
              child: Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryAlt.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.tertiary, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          t.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiary,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    t.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.onSurfaceVariant, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        t.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (t.location != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            t.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CTA button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiaryAlt.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pelajari Selengkapnya',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: AppColors.onTertiary, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Regular Card ──────────────────────────────────────────────────────────
  Widget _buildCard(TrainingModel t) {
    return GestureDetector(
      onTap: () => _openDetail(t.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          t.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiary,
                            letterSpacing: 0.08,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (t.isFull)
                        _badge('Penuh', AppColors.errorContainer, AppColors.error)
                      else if (t.remainingSlots <= 5)
                        _badge('Sisa ${t.remainingSlots}', AppColors.errorContainer.withValues(alpha: 0.3), AppColors.error),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date & location
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.onSurfaceVariant, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        t.formattedDate,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (t.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.onSurfaceVariant, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            t.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Quota bar + daftar button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  // Quota progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${t.registered}/${t.quota} peserta',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(t.quotaPercent * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tertiaryAlt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: t.quotaPercent,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        t.isFull ? AppColors.error : AppColors.tertiaryAlt,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar button
                  GestureDetector(
                    onTap: () => _openDetail(t.id),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: t.isFull
                            ? AppColors.surfaceContainerHigh
                            : AppColors.tertiary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: t.isFull
                              ? AppColors.outlineVariant
                              : AppColors.tertiary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        t.isFull ? 'Kuota Penuh' : 'Lihat & Daftar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: t.isFull ? AppColors.outline : AppColors.tertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  void _openDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrainingDetailScreen(trainingId: id)),
    ).then((_) => _load());
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
            child: const Icon(Icons.school_outlined, color: AppColors.tertiary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pelatihan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pelatihan akan segera tersedia',
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
}
