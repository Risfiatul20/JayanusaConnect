import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/aspiration_model.dart';
import '../../services/aspiration_service.dart';

class AspirationDetailScreen extends StatefulWidget {
  final int aspirationId;
  const AspirationDetailScreen({super.key, required this.aspirationId});

  @override
  State<AspirationDetailScreen> createState() => _AspirationDetailScreenState();
}

class _AspirationDetailScreenState extends State<AspirationDetailScreen> {
  final _service = AspirationService();
  AspirationModel? _aspiration;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getAspiration(widget.aspirationId);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _aspiration = AspirationModel.fromJson(result['data']);
        _loading = false;
      });
    } else {
      setState(() { _error = result['message']; _loading = false; });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Aspirasi',
            style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700)),
        content: const Text('Aspirasi yang dihapus tidak dapat dikembalikan.',
            style: TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final result = await _service.deleteAspiration(widget.aspirationId);
      if (mounted) {
        if (result['success'] == true) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal menghapus')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.tertiaryAlt))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.onSurfaceVariant)))
                    : _buildContent(),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Detail Aspirasi',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (_aspiration?.status == 'dikirim')
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                  onPressed: _delete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final a = _aspiration!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Card ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (a.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          a.category!.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      a.timeAgo,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  a.title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  a.content,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Status Tracking ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics_outlined, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Status Pelacakan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStepper(a),
              ],
            ),
          ),

          // ── Admin Notes ──────────────────────────────────────────────────
          if (a.adminNotes != null && a.adminNotes!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryAlt.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.tertiaryAlt, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        a.handler?['name'] ?? 'Admin BEM',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiaryAlt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a.adminNotes!,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: AppColors.onSurface,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepper(AspirationModel a) {
    final steps = [
      _Step(
        title: 'Aspirasi Dikirim',
        desc: 'Laporan Anda telah berhasil diterima oleh sistem JAYANUSA Connect.',
        isDone: true,
        isActive: a.status == 'dikirim',
      ),
      _Step(
        title: 'Sedang Diproses',
        desc: a.status == 'diproses' || a.status == 'selesai'
            ? 'Aspirasi sedang ditinjau oleh tim BEM JAYANUSA.'
            : 'Menunggu ditinjau oleh tim BEM.',
        isDone: a.status == 'diproses' || a.status == 'selesai',
        isActive: a.status == 'diproses',
      ),
      _Step(
        title: 'Penyelesaian',
        desc: a.status == 'selesai'
            ? 'Aspirasi telah diselesaikan. Terima kasih atas partisipasi Anda.'
            : 'Aspirasi akan ditutup setelah perbaikan selesai.',
        isDone: a.status == 'selesai',
        isActive: a.status == 'selesai',
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper indicator
            Column(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.isDone
                        ? AppColors.tertiary
                        : s.isActive
                            ? AppColors.primaryContainer.withValues(alpha: 0.5)
                            : AppColors.surfaceContainerHighest,
                    border: s.isActive && !s.isDone
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                    boxShadow: s.isDone
                        ? [BoxShadow(color: AppColors.tertiaryAlt.withValues(alpha: 0.5), blurRadius: 10)]
                        : null,
                  ),
                  child: Center(
                    child: s.isDone
                        ? const Icon(Icons.check_rounded, color: AppColors.onTertiary, size: 14)
                        : s.isActive
                            ? const Icon(Icons.sync_rounded, color: AppColors.primary, size: 14)
                            : const Icon(Icons.hourglass_empty_rounded, color: AppColors.outline, size: 14),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: s.isDone
                            ? [AppColors.tertiaryAlt, AppColors.primaryContainer.withValues(alpha: 0.5)]
                            : [AppColors.outlineVariant, AppColors.outlineVariant],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: s.isDone
                            ? AppColors.tertiary
                            : s.isActive
                                ? AppColors.primary
                                : AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: s.isDone
                            ? AppColors.tertiary.withValues(alpha: 0.05)
                            : s.isActive
                                ? AppColors.primaryContainer.withValues(alpha: 0.1)
                                : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: s.isDone
                              ? AppColors.tertiary.withValues(alpha: 0.15)
                              : AppColors.glassBorder,
                        ),
                      ),
                      child: Text(
                        s.desc,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: s.isDone || s.isActive
                              ? AppColors.onSurfaceVariant
                              : AppColors.outline,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Step {
  final String title;
  final String desc;
  final bool isDone;
  final bool isActive;
  const _Step({required this.title, required this.desc, required this.isDone, required this.isActive});
}
