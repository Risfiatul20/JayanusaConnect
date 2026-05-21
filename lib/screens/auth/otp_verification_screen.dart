import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// OTP Verification Screen
/// Muncul setelah alumni berhasil daftar
/// Alumni harus kirim OTP ke admin via WA untuk aktivasi akun
class OtpVerificationScreen extends StatefulWidget {
  final String otpCode;
  final String waLink;
  final String userName;
  final String phone;
  final String expiresAt;

  const OtpVerificationScreen({
    super.key,
    required this.otpCode,
    required this.waLink,
    required this.userName,
    required this.phone,
    required this.expiresAt,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  int _countdown = 30 * 60; // 30 menit dalam detik
  bool _waSent = false;
  bool _isPolling = false;
  bool _isResending = false;
  String _currentOtp = '';
  String _currentWaLink = '';

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otpCode;
    _currentWaLink = widget.waLink;
    _startCountdown();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 0) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  // Polling setiap 5 detik cek apakah admin sudah verifikasi
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted || _isPolling) return;
      _isPolling = true;
      await _checkVerification();
      _isPolling = false;
    });
  }

  Future<void> _checkVerification() async {
    final auth = context.read<AuthProvider>();
    final verified = await auth.checkVerification();
    if (verified && mounted) {
      _pollingTimer?.cancel();
      _countdownTimer?.cancel();
      _showSuccess();
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.tertiary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Akun Terverifikasi!',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Akun alumni Anda sudah aktif. Selamat bergabung di JAYANUSA Connect!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const HomeScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                  ),
                  (route) => false,
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.tertiaryAlt.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Masuk ke Aplikasi',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(_currentWaLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _waSent = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp. Pastikan WA terinstall.'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    final auth = context.read<AuthProvider>();
    final result = await auth.resendOtp();

    if (!mounted) return;
    setState(() => _isResending = false);

    if (result['success'] == true) {
      setState(() {
        _currentOtp = result['data']['otp_code'];
        _currentWaLink = result['data']['wa_link'];
        _countdown = 30 * 60;
        _waSent = false;
      });
      _countdownTimer?.cancel();
      _startCountdown();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP baru berhasil dibuat!'),
          backgroundColor: AppColors.tertiaryContainer,
        ),
      );
    }
  }

  String get _countdownText {
    final minutes = _countdown ~/ 60;
    final seconds = _countdown % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -100, left: -100,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF3B2FC9).withValues(alpha: 0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // ── Icon ──────────────────────────────────────────────
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(Icons.verified_user_outlined, size: 40, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Verifikasi Akun',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kirim kode OTP ke Admin BEM via WhatsApp untuk mengaktifkan akun alumni Anda.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // ── OTP Code Card ─────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'KODE OTP ANDA',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // OTP digits
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _currentOtp.split('').map((digit) {
                            return Container(
                              width: 44,
                              height: 52,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryAlt.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.tertiaryAlt.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  digit,
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // Countdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: _countdown < 300
                                  ? AppColors.error
                                  : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Berlaku $_countdownText',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: _countdown < 300
                                    ? AppColors.error
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Steps ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cara Verifikasi:',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _step('1', 'Tap tombol "Kirim via WhatsApp" di bawah'),
                        _step('2', 'WhatsApp akan terbuka dengan pesan otomatis ke Admin BEM'),
                        _step('3', 'Kirim pesan tersebut'),
                        _step('4', 'Tunggu Admin BEM memverifikasi kode Anda'),
                        _step('5', 'Akun otomatis aktif setelah diverifikasi'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── WA Button ─────────────────────────────────────────
                  GestureDetector(
                    onTap: _openWhatsApp,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366), // WA green
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF25D366).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_rounded, color: Colors.white, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            _waSent ? 'Kirim Ulang via WhatsApp' : 'Kirim via WhatsApp',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_waSent) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryAlt.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.tertiaryAlt.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.tertiaryAlt,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Menunggu verifikasi dari Admin BEM...',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                color: AppColors.tertiaryAlt,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Resend OTP ────────────────────────────────────────
                  if (_countdown == 0)
                    GestureDetector(
                      onTap: _isResending ? null : _resendOtp,
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.glassSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Center(
                          child: _isResending
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Text(
                                  'OTP Expired — Buat Kode Baru',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              color: AppColors.tertiaryAlt.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.tertiaryAlt.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.tertiaryAlt,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
