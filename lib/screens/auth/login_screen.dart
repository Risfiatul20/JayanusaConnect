import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Login Screen — JAYANUSA Neon-Glass Design
/// Satu form untuk semua role: Mahasiswa (NOBP), Admin BEM (email), Alumni (email)
/// Logic: jika identifier berisi '@' → login via backend Laravel
///        jika identifier angka saja → login via API kampus (NOBP)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Tab: 0 = Masuk, 1 = Info
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Deteksi otomatis jenis login berdasarkan identifier
  bool get _isEmailLogin => _identifierController.text.trim().contains('@');

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;
    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isEmailLogin) {
      // Admin BEM / Super Admin / Alumni → backend Laravel
      success = await authProvider.loginAdmin(identifier, password);
    } else {
      // Mahasiswa → API kampus via NOBP
      success = await authProvider.loginWithNobp(identifier, password);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      _showError(authProvider.errorMessage ?? 'Login gagal. Periksa kembali data Anda.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Ambient background glow ──────────────────────────────────────
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B2FC9).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tertiaryAlt.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // ── Brand Header ─────────────────────────────────────────
                  _buildBrandHeader(),

                  const SizedBox(height: 36),

                  // ── Glass Card ───────────────────────────────────────────
                  _buildGlassCard(),

                  const SizedBox(height: 24),

                  // ── Info hint ────────────────────────────────────────────
                  _buildInfoHint(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Logo glass container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pusat Digital Aspirasi & Karir Mahasiswa',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 13,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tab header ─────────────────────────────────────────────
              _buildTabHeader(),

              const SizedBox(height: 24),

              // ── Form ───────────────────────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Identifier field
                    _buildIdentifierField(),

                    const SizedBox(height: 16),

                    // Password field
                    _buildPasswordField(),

                    const SizedBox(height: 28),

                    // Login button
                    _buildLoginButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabHeader() {
    return Row(
      children: [
        Expanded(
          child: _TabItem(
            label: 'Masuk',
            isActive: true,
            onTap: () {},
          ),
        ),
        Expanded(
          child: _TabItem(
            label: 'Tentang',
            isActive: false,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifierField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 14,
            color: AppColors.onSurface,
          ),
          onChanged: (_) => setState(() {}), // rebuild untuk update hint
          decoration: InputDecoration(
            hintText: 'Email atau NOBP',
            prefixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isEmailLogin ? Icons.email_outlined : Icons.badge_outlined,
                key: ValueKey(_isEmailLogin),
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
            // Suffix chip menunjukkan mode login
            suffixIcon: _identifierController.text.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _isEmailLogin
                          ? AppColors.secondaryContainer.withValues(alpha: 0.4)
                          : AppColors.tertiaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isEmailLogin
                            ? AppColors.secondary.withValues(alpha: 0.4)
                            : AppColors.tertiaryAlt.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _isEmailLogin ? 'Admin' : 'Mahasiswa',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: _isEmailLogin
                            ? AppColors.secondary
                            : AppColors.tertiaryAlt,
                      ),
                    ),
                  )
                : null,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return 'Email atau NOBP wajib diisi';
            }
            if (!v.contains('@') && v.trim().length < 5) {
              return 'NOBP minimal 5 karakter';
            }
            if (v.contains('@') && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
              return 'Format email tidak valid';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Kata Sandi',
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password wajib diisi';
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return GestureDetector(
          onTap: auth.isLoading ? null : _login,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: auth.isLoading
                  ? AppColors.tertiary.withValues(alpha: 0.6)
                  : AppColors.tertiary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: auth.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.tertiaryAlt.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: auth.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.onTertiary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onTertiary,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Mahasiswa: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.tertiaryAlt,
                    ),
                  ),
                  TextSpan(text: 'Gunakan NOBP & password SIAKAD.\n'),
                  TextSpan(
                    text: 'Admin / Alumni: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  TextSpan(text: 'Gunakan email & password akun Anda.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab item widget untuk header card
class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.tertiaryAlt : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.tertiaryAlt : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
