import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/training_model.dart';
import '../../services/training_service.dart';

class TrainingDetailScreen extends StatefulWidget {
  final int trainingId;
  const TrainingDetailScreen({super.key, required this.trainingId});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  final _service = TrainingService();
  TrainingModel? _training;
  bool _loading = true;
  bool _registering = false;
  bool _alreadyRegistered = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final result = await _service.getTraining(widget.trainingId);
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() {
        _training = TrainingModel.fromJson(result['data']);
        _loading = false;
      });
    } else {
      setState(() { _error = result['message']; _loading = false; });
    }
  }

  Future<void> _register() async {
    if (_training == null || _registering) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Pendaftaran',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Daftar ke pelatihan "${_training!.title}"?',
          style: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: AppColors.onTertiary,
              minimumSize: const Size(80, 36),
            ),
            child: const Text('Daftar'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _registering = true);
    final result = await _service.registerTraining(widget.trainingId);
    if (!mounted) return;
    setState(() => _registering = false);

    if (result['success'] == true) {
      setState(() => _alreadyRegistered = true);
      _showSnack('Berhasil mendaftar! Menunggu konfirmasi admin.', isSuccess: true);
      _load(); // refresh data
    } else {
      final msg = result['message'] ?? 'Gagal mendaftar';
      if (msg.contains('sudah terdaftar')) {
        setState(() => _alreadyRegistered = true);
      }
      _showSnack(msg);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.tertiaryContainer : AppColors.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.tertiaryAlt))
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final t = _training!;
    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Section ─────────────────────────────────────────────
              _buildHero(t),

              // ── Quota Card ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildQuotaCard(t),
              ),

              // ── Description ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildDescription(t),
              ),

              // ── Instructor ───────────────────────────────────────────────
              if (t.instructor != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildInstructor(t),
                ),

              // ── Benefits ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildBenefits(),
              ),
            ],
          ),
        ),

        // ── AppBar ───────────────────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: _buildAppBar(),
        ),

        // ── Bottom CTA ───────────────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _buildBottomCta(t),
        ),
      ],
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
                  'Detail Pelatihan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(TrainingModel t) {
    return Container(
      height: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A3A), Color(0xFF0D1B2A)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiaryAlt.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: 40,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Category badge
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
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Meta info
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    _metaItem(Icons.calendar_today_outlined, t.formattedDate),
                    if (t.location != null)
                      _metaItem(Icons.location_on_outlined, t.location!),
                    if (t.instructor != null)
                      _metaItem(Icons.person_outline_rounded, t.instructor!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQuotaCard(TrainingModel t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KAPASITAS PELATIHAN',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'PlusJakartaSans'),
                      children: [
                        TextSpan(
                          text: '${(t.quotaPercent * 100).toInt()}% Terisi ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tertiary,
                          ),
                        ),
                        TextSpan(
                          text: '(${t.registered}/${t.quota} Peserta)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.group_outlined,
                color: AppColors.tertiary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: t.quotaPercent,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                t.isFull ? AppColors.error : AppColors.tertiaryAlt,
              ),
              minHeight: 8,
            ),
          ),
          if (!t.isFull && t.remainingSlots <= 10) ...[
            const SizedBox(height: 8),
            Text(
              'Hanya tersisa ${t.remainingSlots} slot! Segera daftar.',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: AppColors.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription(TrainingModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
            SizedBox(width: 8),
            Text(
              'Tentang Pelatihan',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
            // Left accent border
          ),
          child: Text(
            t.description,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructor(TrainingModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instruktur',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.tertiary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.instructor!,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Instruktur Berpengalaman',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: AppColors.tertiaryAlt,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.onTertiary, size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Luaran & Sertifikasi',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _benefitCard(Icons.workspace_premium_outlined, 'E-Certificate Resmi', 'Diakui mitra industri JAYANUSA')),
            const SizedBox(width: 12),
            Expanded(child: _benefitCard(Icons.history_edu_outlined, 'Portfolio Review', 'Feedback dari mentor langsung')),
          ],
        ),
      ],
    );
  }

  Widget _benefitCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.tertiary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(TrainingModel t) {
    final canRegister = t.isOpen && !t.isFull && !_alreadyRegistered;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: canRegister ? _register : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: _alreadyRegistered
                  ? AppColors.tertiary.withValues(alpha: 0.2)
                  : !canRegister
                      ? AppColors.surfaceContainerHigh
                      : _registering
                          ? AppColors.tertiary.withValues(alpha: 0.6)
                          : AppColors.tertiary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: canRegister && !_registering
                  ? [
                      BoxShadow(
                        color: AppColors.tertiaryAlt.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: _registering
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.onTertiary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      _alreadyRegistered
                          ? '✓ Sudah Terdaftar'
                          : t.isFull
                              ? 'Kuota Penuh'
                              : !t.isOpen
                                  ? 'Pendaftaran Ditutup'
                                  : 'Daftar Sekarang',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _alreadyRegistered || !canRegister
                            ? AppColors.onSurfaceVariant
                            : AppColors.onTertiary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}
