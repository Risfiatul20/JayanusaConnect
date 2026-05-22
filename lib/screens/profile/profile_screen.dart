import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  List<dynamic> _trainingHistory = [];
  int _aspirationCount = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    final results = await Future.wait([
      _service.getTrainingHistory(),
      _service.getAspirationCount(),
    ]);

    if (!mounted) return;
    final trainings = results[0] as Map<String, dynamic>;
    final aspCount = results[1] as int;

    setState(() {
      _trainingHistory = (trainings['data']?['data'] as List? ?? []);
      _aspirationCount = aspCount;
      _loadingStats = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.onSurfaceVariant),
        ),
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
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.tertiaryAlt,
        backgroundColor: AppColors.surfaceContainer,
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ── Hero Profile ─────────────────────────────────────────────
              _buildHeroProfile(user),

              // ── Stats Bar ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildStatsBar(),
              ),

              // ── Info Card ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildInfoCard(user),
              ),

              // ── Riwayat Pelatihan ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildTrainingHistory(),
              ),

              // ── Action Buttons ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildActionButtons(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Profile ──────────────────────────────────────────────────────────
  Widget _buildHeroProfile(user) {
    final initials = (user?.name ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Banner gradient
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B2FC9), Color(0xFF1A1A3A), Color(0xFF005651)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiaryAlt.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -20, left: 40,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withValues(alpha: 0.06),
                  ),
                ),
              ),
              // Safe area padding
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil Saya',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: _loadStats,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Avatar + name — overlapping banner
        Positioned(
          top: 100,
          left: 0, right: 0,
          child: Column(
            children: [
              // Avatar circle
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                  border: Border.all(color: AppColors.background, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tertiaryAlt.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                user?.name ?? '',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.01,
                ),
              ),
              const SizedBox(height: 4),

              // NIM/NOBP + prodi
              Text(
                [
                  user?.nobp ?? user?.nim,
                  user?.prodi,
                ].where((e) => e != null && e.isNotEmpty).join(' • '),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AKTIF • ${(user?.displayRole ?? 'Mahasiswa').toUpperCase()}',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tertiary,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Spacer untuk konten di bawah
        const SizedBox(height: 340),
      ],
    );
  }

  // ── Stats Bar ─────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    final trainingCount = _trainingHistory.length;

    return Row(
      children: [
        Expanded(child: _statCard('Aspirasi', _loadingStats ? '...' : '$_aspirationCount')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Pelatihan', _loadingStats ? '...' : '$trainingCount')),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Portofolio', '0')),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard(user) {
    final items = <_InfoItem>[
      if (user?.email != null && user!.email.isNotEmpty)
        _InfoItem(Icons.email_outlined, 'Email', user.email),
      if (user?.phone != null && user!.phone!.isNotEmpty)
        _InfoItem(Icons.phone_outlined, 'No. HP', user.phone!),
      if (user?.angkatan != null && user!.angkatan!.isNotEmpty)
        _InfoItem(Icons.calendar_today_outlined, 'Angkatan', user.angkatan!),
      if (user?.prodi != null && user!.prodi!.isNotEmpty)
        _InfoItem(Icons.school_outlined, 'Program Studi', user.prodi!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: AppColors.tertiary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.05,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.glassBorder),
            ],
          );
        }),
      ),
    );
  }

  // ── Riwayat Pelatihan ─────────────────────────────────────────────────────
  Widget _buildTrainingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Pelatihan',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        if (_loadingStats)
          const Center(child: CircularProgressIndicator(color: AppColors.tertiaryAlt, strokeWidth: 2))
        else if (_trainingHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_outlined, color: AppColors.onSurfaceVariant, size: 20),
                SizedBox(width: 12),
                Text(
                  'Belum ada riwayat pelatihan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: _trainingHistory.take(4).map((reg) {
              final training = reg['training'];
              final status = reg['status'] ?? 'pending';
              final title = training?['title'] ?? 'Pelatihan';
              final date = training?['date'] ?? '';

              String formattedDate = '';
              if (date.isNotEmpty) {
                try {
                  final dt = DateTime.parse(date);
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                                  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                  formattedDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
                } catch (_) {
                  formattedDate = date;
                }
              }

              Color statusColor;
              switch (status) {
                case 'approved':  statusColor = AppColors.tertiary; break;
                case 'completed': statusColor = AppColors.tertiary; break;
                case 'rejected':  statusColor = AppColors.error; break;
                default:          statusColor = AppColors.warning;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_outlined, color: AppColors.tertiary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            formattedDate.isNotEmpty ? formattedDate : 'Tanggal tidak tersedia',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        status == 'approved' || status == 'completed'
                            ? 'Aktif'
                            : status == 'rejected'
                                ? 'Ditolak'
                                : 'Pending',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Pengaturan
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur pengaturan segera hadir',
                    style: TextStyle(fontFamily: 'PlusJakartaSans')),
                backgroundColor: AppColors.surfaceContainerHigh,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.glassSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Keluar
        GestureDetector(
          onTap: _logout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.errorContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Text(
                  'Keluar',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}
