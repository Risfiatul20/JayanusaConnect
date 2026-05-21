import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Login Screen — JAYANUSA Neon-Glass Design
/// Tab Masuk  : satu form untuk semua role (NOBP → mahasiswa, email → admin/alumni)
/// Tab Daftar : form register khusus Admin BEM via backend Laravel
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0; // 0 = Masuk, 1 = Daftar

  // ── Form Login ────────────────────────────────────────────────────────────
  final _loginFormKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _obscureLogin = true;

  // ── Form Register ─────────────────────────────────────────────────────────
  final _registerFormKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _registerPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscureRegister = true;
  bool _obscureConfirm = true;
  String? _selectedProdi;
  String? _selectedAngkatan;

  static const _prodiList = [
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen Informatika',
  ];
  static const _angkatanList = ['2020', '2021', '2022', '2023', '2024'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) return;
        setState(() => _activeTab = _tabController.index);
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nimCtrl.dispose();
    _registerPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool get _isEmailLogin => _identifierCtrl.text.trim().contains('@');

  // ── Login logic ───────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final id = _identifierCtrl.text.trim();
    final pw = _loginPasswordCtrl.text;

    final success = _isEmailLogin
        ? await auth.loginAdmin(id, pw)
        : await auth.loginWithNobp(id, pw);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else {
      _showSnack(auth.errorMessage ?? 'Login gagal. Periksa kembali data Anda.', isError: true);
    }
  }

  // ── Register logic ────────────────────────────────────────────────────────
  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    final result = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _registerPasswordCtrl.text,
      passwordConfirmation: _confirmPasswordCtrl.text,
      nim: _nimCtrl.text.trim().isEmpty ? null : _nimCtrl.text.trim(),
      angkatan: _selectedAngkatan,
      prodi: _selectedProdi,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else {
      _showSnack(result['message'] ?? 'Registrasi gagal.', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.errorContainer : AppColors.tertiaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow kiri atas
          Positioned(
            top: -120,
            left: -120,
            child: _glowCircle(400, const Color(0xFF3B2FC9), 0.22),
          ),
          // Ambient glow kanan bawah
          Positioned(
            bottom: -80,
            right: -80,
            child: _glowCircle(280, AppColors.tertiaryAlt, 0.10),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 44),
                  _buildBrandHeader(),
                  const SizedBox(height: 32),
                  _buildGlassCard(),
                  const SizedBox(height: 20),
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

  Widget _glowCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }

  // ── Brand Header ──────────────────────────────────────────────────────────
  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 24,
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 14),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Pusat Digital Aspirasi & Karir Mahasiswa',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Glass Card ────────────────────────────────────────────────────────────
  Widget _buildGlassCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          // Tab bar
          _buildTabBar(),
          // Tab content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _activeTab == 0
                ? _buildLoginForm()
                : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Masuk',
            isActive: _activeTab == 0,
            onTap: () {
              _tabController.animateTo(0);
              setState(() => _activeTab = 0);
            },
          ),
          _TabItem(
            label: 'Daftar',
            isActive: _activeTab == 1,
            onTap: () {
              _tabController.animateTo(1);
              setState(() => _activeTab = 1);
            },
          ),
        ],
      ),
    );
  }

  // ── Login Form ────────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Padding(
      key: const ValueKey('login'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identifier
            TextFormField(
              controller: _identifierCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              onChanged: (_) => setState(() {}),
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
                suffixIcon: _identifierCtrl.text.isNotEmpty
                    ? _roleChip(_isEmailLogin ? 'Admin' : 'Mahasiswa', _isEmailLogin)
                    : null,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email atau NOBP wajib diisi';
                if (!v.contains('@') && v.trim().length < 5) return 'NOBP minimal 5 karakter';
                if (v.contains('@') && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                  return 'Format email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            TextFormField(
              controller: _loginPasswordCtrl,
              obscureText: _obscureLogin,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Kata Sandi',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                suffixIcon: _visibilityBtn(_obscureLogin, () => setState(() => _obscureLogin = !_obscureLogin)),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
            ),
            const SizedBox(height: 24),

            // Button
            _buildCyanButton(
              label: 'Masuk',
              onTap: _login,
            ),

            const SizedBox(height: 16),

            // Switch to register
            Center(
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(1);
                  setState(() => _activeTab = 1);
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(text: 'Belum punya akun? '),
                      TextSpan(
                        text: 'Daftar Sekarang',
                        style: TextStyle(
                          color: AppColors.tertiaryAlt,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Register Form ─────────────────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Padding(
      key: const ValueKey('register'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama
            _inputField(
              controller: _nameCtrl,
              hint: 'Nama Lengkap',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),

            // Email
            _inputField(
              controller: _emailCtrl,
              hint: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // NIM (opsional)
            _inputField(
              controller: _nimCtrl,
              hint: 'NIM (opsional)',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Prodi dropdown
            _dropdownField(
              hint: 'Program Studi',
              icon: Icons.school_outlined,
              value: _selectedProdi,
              items: _prodiList,
              onChanged: (v) => setState(() => _selectedProdi = v),
            ),
            const SizedBox(height: 12),

            // Angkatan dropdown
            _dropdownField(
              hint: 'Angkatan',
              icon: Icons.calendar_today_outlined,
              value: _selectedAngkatan,
              items: _angkatanList,
              onChanged: (v) => setState(() => _selectedAngkatan = v),
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _registerPasswordCtrl,
              obscureText: _obscureRegister,
              style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                suffixIcon: _visibilityBtn(_obscureRegister, () => setState(() => _obscureRegister = !_obscureRegister)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password wajib diisi';
                if (v.length < 8) return 'Password minimal 8 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Konfirmasi password
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Konfirmasi Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                suffixIcon: _visibilityBtn(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                if (v != _registerPasswordCtrl.text) return 'Password tidak cocok';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Button
            _buildCyanButton(label: 'Daftar Sekarang', onTap: _register),

            const SizedBox(height: 16),

            // Switch to login
            Center(
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(0);
                  setState(() => _activeTab = 0);
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                    children: [
                      TextSpan(text: 'Sudah punya akun? '),
                      TextSpan(
                        text: 'Masuk',
                        style: TextStyle(
                          color: AppColors.tertiaryAlt,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildCyanButton({required String label, required VoidCallback onTap}) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) => GestureDetector(
        onTap: auth.isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: auth.isLoading
                ? AppColors.tertiary.withValues(alpha: 0.55)
                : AppColors.tertiary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: auth.isLoading
                ? []
                : [
                    BoxShadow(
                      color: AppColors.tertiaryAlt.withValues(alpha: 0.32),
                      blurRadius: 18,
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
                : Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onTertiary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      ),
      validator: validator,
    );
  }

  Widget _dropdownField({
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surfaceContainerHigh,
      style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _visibilityBtn(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.onSurfaceVariant,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  Widget _roleChip(String label, bool isEmail) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isEmail
            ? AppColors.secondaryContainer.withValues(alpha: 0.35)
            : AppColors.tertiaryContainer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmail
              ? AppColors.secondary.withValues(alpha: 0.4)
              : AppColors.tertiaryAlt.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.05,
          color: isEmail ? AppColors.secondary : AppColors.tertiaryAlt,
        ),
      ),
    );
  }

  // ── Info Hint ─────────────────────────────────────────────────────────────
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
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.tertiaryAlt),
                  ),
                  TextSpan(text: 'Masuk dengan NOBP & password SIAKAD.\n'),
                  TextSpan(
                    text: 'Admin / Alumni: ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                  TextSpan(text: 'Masuk atau daftar dengan email.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Item Widget ───────────────────────────────────────────────────────────
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}
