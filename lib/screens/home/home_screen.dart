import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // ── Quick Actions ─────────────────────────────────────────────────────────
  static const _quickActions = [
    _QuickAction(icon: Icons.campaign_outlined,      label: 'Aspirasi',    index: 1),
    _QuickAction(icon: Icons.school_outlined,         label: 'Pelatihan',   index: 2),
    _QuickAction(icon: Icons.folder_shared_outlined,  label: 'Portofolio',  index: 3),
    _QuickAction(icon: Icons.work_outline_rounded,    label: 'Lowongan',    index: 4),
    _QuickAction(icon: Icons.people_outline_rounded,  label: 'Alumni',      index: 4),
    _QuickAction(icon: Icons.account_balance_outlined,label: 'Program BEM', index: 4),
  ];

  // ── Dummy trainings (nanti diganti API) ───────────────────────────────────
  static const _trainings = [
    _TrainingItem(title: 'Workshop Cybersecurity Dasar', category: 'Cybersecurity', quota: 30, registered: 12),
    _TrainingItem(title: 'Bootcamp Flutter Mobile Dev',  category: 'Programming',   quota: 25, registered: 20),
    _TrainingItem(title: 'Pelatihan UI/UX dengan Figma', category: 'Desain',        quota: 20, registered: 8),
  ];

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar?',
            style: TextStyle(fontFamily: 'PlusJakartaSans')),
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
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
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
    final greeting = _greeting();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient glow ─────────────────────────────────────────────────
          Positioned(
            top: -80, right: -80,
            child: _glow(300, const Color(0xFF3B2FC9), 0.18),
          ),

          // ── Scrollable content ────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // Top padding for AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),

              // Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, ${user?.name.split(' ').first ?? 'Pengguna'}!',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Siap untuk berinovasi hari ini?',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _buildHeroBanner(),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildQuickActions(),
                ),
              ),

              // Pelatihan Unggulan
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                  child: _buildTrainingSection(),
                ),
              ),

              // Aspirasi Terbaru
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildAspirationSection(user),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ── Glass TopAppBar ───────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildTopAppBar(user),
          ),

          // ── Bottom Nav ────────────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),

          // ── FAB ───────────────────────────────────────────────────────────
          Positioned(
            bottom: 80, right: 20,
            child: _buildFab(),
          ),
        ],
      ),
    );
  }

  // ── TopAppBar ─────────────────────────────────────────────────────────────
  Widget _buildTopAppBar(user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        border: const Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Center(
                  child: Text(
                    (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // App name
              const Expanded(
                child: Text(
                  'JAYANUSA Connect',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -0.01,
                  ),
                ),
              ),

              // Notification
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassSurface,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 8),

              // Logout
              GestureDetector(
                onTap: _logout,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassSurface,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.onSurfaceVariant, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Banner ───────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceContainerHigh,
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E3A), Color(0xFF0D1B2A)],
              ),
            ),
          ),

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
            bottom: -20, left: 60,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'PROGRAM BEM 2024',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tertiary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Innovation Summit 2024:\nDigital Frontier',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {},
                  child: Container(
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
                    child: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onTertiary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _quickActions.length,
          itemBuilder: (_, i) => _buildActionTile(_quickActions[i]),
        ),
      ],
    );
  }

  Widget _buildActionTile(_QuickAction action) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = action.index),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(action.icon, color: AppColors.tertiary, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Pelatihan Section ─────────────────────────────────────────────────────
  Widget _buildTrainingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pelatihan Unggulan',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 2),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiaryAlt,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _trainings.length,
            itemBuilder: (_, i) => _buildTrainingCard(_trainings[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingCard(_TrainingItem t) {
    final pct = t.quota > 0 ? t.registered / t.quota : 0.0;
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.25)),
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
          const SizedBox(height: 8),
          Text(
            t.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.3,
            ),
          ),
          const Spacer(),
          // Quota bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${t.registered}/${t.quota} peserta',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
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
              value: pct,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiaryAlt),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Aspirasi Section ──────────────────────────────────────────────────────
  Widget _buildAspirationSection(user) {
    // Hanya tampilkan untuk mahasiswa
    if (user?.isAdmin == true) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aspirasi Terbaru',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: const Text(
                'Lacak Semua',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiaryAlt,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Empty state — nanti diganti dengan data dari API
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(14),
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
                child: const Icon(Icons.campaign_outlined, color: AppColors.tertiary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Belum ada aspirasi',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap + untuk kirim aspirasi pertama Anda',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.home_outlined,      activeIcon: Icons.home_rounded,         label: 'Home'),
      _NavItem(icon: Icons.campaign_outlined,   activeIcon: Icons.campaign_rounded,     label: 'Aspirasi'),
      _NavItem(icon: Icons.school_outlined,     activeIcon: Icons.school_rounded,       label: 'Pelatihan'),
      _NavItem(icon: Icons.folder_shared_outlined, activeIcon: Icons.folder_shared_rounded, label: 'Portofolio'),
      _NavItem(icon: Icons.person_outline,      activeIcon: Icons.person_rounded,       label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = _currentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? items[i].activeIcon : items[i].icon,
                        color: active ? AppColors.tertiary : AppColors.onSurfaceVariant,
                        size: 22,
                        shadows: active
                            ? [Shadow(color: AppColors.tertiaryAlt.withValues(alpha: 0.6), blurRadius: 12)]
                            : null,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? AppColors.tertiary : AppColors.onSurfaceVariant,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFab() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppColors.tertiary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiaryAlt.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add_comment_rounded, color: AppColors.onTertiary, size: 24),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _glow(double size, Color color, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      );

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────
class _QuickAction {
  final IconData icon;
  final String label;
  final int index;
  const _QuickAction({required this.icon, required this.label, required this.index});
}

class _TrainingItem {
  final String title;
  final String category;
  final int quota;
  final int registered;
  const _TrainingItem({required this.title, required this.category, required this.quota, required this.registered});
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
