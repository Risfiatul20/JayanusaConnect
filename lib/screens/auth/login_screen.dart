import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'otp_verification_screen.dart';

/// Login Screen — JAYANUSA Neon-Glass Design
/// Tab Masuk  : NOBP → mahasiswa | email → admin/alumni
/// Tab Daftar : khusus Alumni (buat akun + data alumni sekaligus)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  // ── Login fields ──────────────────────────────────────────────────────────
  final _loginKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _loginPwCtrl = TextEditingController();
  bool _obscureLogin = true;

  // ── Register Alumni fields ────────────────────────────────────────────────
  final _registerKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _regPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _obscureReg = true;
  bool _obscureConfirm = true;
  String? _selectedProdi;
  String? _selectedAngkatan;

  static const _prodiList = [
    'Sistem Informasi',
    'Teknik Informatika',
    'Manajemen Informatika',
  ];
  static const _angkatanList = [
    '2015', '2016', '2017', '2018', '2019',
    '2020', '2021', '2022', '2023', '2024',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() => _activeTab = _tabController.index);
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _identifierCtrl.dispose();
    _loginPwCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _nimCtrl.dispose();
    _phoneCtrl.dispose();
    _professionCtrl.dispose();
    _companyCtrl.dispose();
    _positionCtrl.dispose();
    _linkedinCtrl.dispose();
    _bioCtrl.dispose();
    _regPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  bool get _isEmailLogin => _identifierCtrl.text.trim().contains('@');

  void _switchTab(int index) {
    _tabController.animateTo(index);
    setState(() => _activeTab = index);
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
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
        backgroundColor:
            isError ? AppColors.errorContainer : AppColors.tertiaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_loginKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final id = _identifierCtrl.text.trim();
    final pw = _loginPwCtrl.text;

    final success = _isEmailLogin
        ? await auth.loginAdmin(id, pw)
        : await auth.loginWithNobp(id, pw);

    if (!mounted) return;
    success
        ? _goHome()
        : _showSnack(auth.errorMessage ?? 'Login gagal. Periksa kembali data Anda.');
  }

  // ── Register Alumni ───────────────────────────────────────────────────────
  Future<void> _registerAlumni() async {
    if (!_registerKey.currentState!.validate()) return;
    if (_selectedAngkatan == null) {
      _showSnack('Angkatan wajib dipilih.');
      return;
    }
    final auth = context.read<AuthProvider>();

    final result = await auth.registerAlumni(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _regPwCtrl.text,
      passwordConfirmation: _confirmPwCtrl.text,
      angkatan: _selectedAngkatan!,
      nim: _nimCtrl.text.trim().isEmpty ? null : _nimCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      prodi: _selectedProdi,
      profession: _professionCtrl.text.trim().isEmpty ? null : _professionCtrl.text.trim(),
      company: _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      position: _positionCtrl.text.trim().isEmpty ? null : _positionCtrl.text.trim(),
      linkedin: _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
    );

    if (!mounted) return;
    if (result['success'] == true) {
      // Alumni perlu verifikasi OTP via WA dulu
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => OtpVerificationScreen(
            otpCode:   result['data']['otp_code'],
            waLink:    result['data']['wa_link'],
            userName:  _nameCtrl.text.trim(),
            phone:     _phoneCtrl.text.trim(),
            expiresAt: result['data']['expires_at'],
          ),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else {
      _showSnack(result['message'] ?? 'Registrasi gagal.');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -120, left: -120,
            child: _glow(400, const Color(0xFF3B2FC9), 0.22),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _glow(280, AppColors.tertiaryAlt, 0.10),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 44),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildCard(),
                  const SizedBox(height: 20),
                  _buildHint(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(double size, Color color, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
      );

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Column(
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

  // ── Glass Card ────────────────────────────────────────────────────────────
  Widget _buildCard() => Container(
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            _buildTabBar(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: _activeTab == 0 ? _buildLoginForm() : _buildRegisterAlumniForm(),
            ),
          ],
        ),
      );

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
        ),
        child: Row(
          children: [
            _TabItem(label: 'Masuk', isActive: _activeTab == 0, onTap: () => _switchTab(0)),
            _TabItem(label: 'Daftar Alumni', isActive: _activeTab == 1, onTap: () => _switchTab(1)),
          ],
        ),
      );

  // ── Login Form ────────────────────────────────────────────────────────────
  Widget _buildLoginForm() => Padding(
        key: const ValueKey('login'),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _loginKey,
          child: Column(
            children: [
              // Identifier
              TextFormField(
                controller: _identifierCtrl,
                keyboardType: TextInputType.emailAddress,
                style: _inputStyle,
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
                      ? _chip(_isEmailLogin ? 'Admin/Alumni' : 'Mahasiswa', _isEmailLogin)
                      : null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email atau NOBP wajib diisi';
                  if (!v.contains('@') && v.trim().length < 5) return 'NOBP minimal 5 karakter';
                  if (v.contains('@') && !_emailRegex.hasMatch(v)) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Password
              TextFormField(
                controller: _loginPwCtrl,
                obscureText: _obscureLogin,
                style: _inputStyle,
                decoration: InputDecoration(
                  hintText: 'Kata Sandi',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _eyeBtn(_obscureLogin, () => setState(() => _obscureLogin = !_obscureLogin)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              _cyanBtn('Masuk', _login),
              const SizedBox(height: 16),

              _switchLink(
                text: 'Belum punya akun? ',
                link: 'Daftar sebagai Alumni',
                onTap: () => _switchTab(1),
              ),
            ],
          ),
        ),
      );

  // ── Register Alumni Form ──────────────────────────────────────────────────
  Widget _buildRegisterAlumniForm() => Padding(
        key: const ValueKey('register'),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _registerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline_rounded, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daftar sebagai Alumni JAYANUSA untuk bergabung di direktori dan program mentoring.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: AppColors.secondary.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Data Diri ──────────────────────────────────────────────
              _sectionLabel('Data Diri'),
              const SizedBox(height: 10),
              _field(_nameCtrl, 'Nama Lengkap *', Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null),
              const SizedBox(height: 10),
              _field(_emailCtrl, 'Email *', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                    if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
                    return null;
                  }),
              const SizedBox(height: 10),
              _field(_nimCtrl, 'NIM (opsional)', Icons.badge_outlined,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _field(_phoneCtrl, 'No. HP (opsional)', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _dropdown('Angkatan *', Icons.calendar_today_outlined,
                  _selectedAngkatan, _angkatanList,
                  (v) => setState(() => _selectedAngkatan = v)),
              const SizedBox(height: 10),
              _dropdown('Program Studi', Icons.school_outlined,
                  _selectedProdi, _prodiList,
                  (v) => setState(() => _selectedProdi = v)),

              const SizedBox(height: 20),

              // ── Karir ──────────────────────────────────────────────────
              _sectionLabel('Informasi Karir (opsional)'),
              const SizedBox(height: 10),
              _field(_professionCtrl, 'Profesi / Jabatan', Icons.work_outline_rounded),
              const SizedBox(height: 10),
              _field(_companyCtrl, 'Perusahaan / Instansi', Icons.business_outlined),
              const SizedBox(height: 10),
              _field(_positionCtrl, 'Posisi', Icons.badge_outlined),
              const SizedBox(height: 10),
              _field(_linkedinCtrl, 'LinkedIn URL', Icons.link_rounded,
                  keyboardType: TextInputType.url),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                style: _inputStyle,
                decoration: const InputDecoration(
                  hintText: 'Bio singkat (opsional)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.notes_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Password ───────────────────────────────────────────────
              _sectionLabel('Buat Password'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _regPwCtrl,
                obscureText: _obscureReg,
                style: _inputStyle,
                decoration: InputDecoration(
                  hintText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _eyeBtn(_obscureReg, () => setState(() => _obscureReg = !_obscureReg)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 8) return 'Password minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPwCtrl,
                obscureText: _obscureConfirm,
                style: _inputStyle,
                decoration: InputDecoration(
                  hintText: 'Konfirmasi Password *',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _eyeBtn(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                  if (v != _regPwCtrl.text) return 'Password tidak cocok';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _cyanBtn('Daftar sebagai Alumni', _registerAlumni),
              const SizedBox(height: 16),

              _switchLink(
                text: 'Sudah punya akun? ',
                link: 'Masuk',
                onTap: () => _switchTab(0),
              ),
            ],
          ),
        ),
      );

  // ── Shared helpers ────────────────────────────────────────────────────────
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  static const _inputStyle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    color: AppColors.onSurface,
  );

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.05,
        ),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: _inputStyle,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        ),
        validator: validator,
      );

  Widget _dropdown(
    String hint,
    IconData icon,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
  ) =>
      DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.surfaceContainerHigh,
        style: _inputStyle,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      );

  Widget _eyeBtn(bool obscure, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
        onPressed: onTap,
      );

  Widget _chip(String label, bool isEmail) => Container(
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

  Widget _cyanBtn(String label, VoidCallback onTap) => Consumer<AuthProvider>(
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

  Widget _switchLink({
    required String text,
    required String link,
    required VoidCallback onTap,
  }) =>
      Center(
        child: GestureDetector(
          onTap: onTap,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              children: [
                TextSpan(text: text),
                TextSpan(
                  text: link,
                  style: const TextStyle(
                    color: AppColors.tertiaryAlt,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ── Info Hint ─────────────────────────────────────────────────────────────
  Widget _buildHint() => Container(
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
                      text: 'Admin: ',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondary),
                    ),
                    TextSpan(text: 'Masuk dengan email.\n'),
                    TextSpan(
                      text: 'Alumni: ',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
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

// ── Tab Item ──────────────────────────────────────────────────────────────────
class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({required this.label, required this.isActive, required this.onTap});

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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.tertiaryAlt : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
