import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/aspiration_service.dart';

class AspirationFormScreen extends StatefulWidget {
  const AspirationFormScreen({super.key});

  @override
  State<AspirationFormScreen> createState() => _AspirationFormScreenState();
}

class _AspirationFormScreenState extends State<AspirationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _service = AspirationService();

  String? _selectedCategory;
  bool _loading = false;
  int _charCount = 0;

  static const _categories = [
    _Category('Fasilitas',   Icons.apartment_outlined),
    _Category('Akademik',    Icons.school_outlined),
    _Category('Organisasi',  Icons.groups_outlined),
    _Category('Beasiswa',    Icons.payments_outlined),
    _Category('Lainnya',     Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await _service.createAspiration(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      category: _selectedCategory,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Aspirasi berhasil dikirim!',
                  style: TextStyle(fontFamily: 'PlusJakartaSans', fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: AppColors.tertiaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengirim aspirasi',
              style: const TextStyle(fontFamily: 'PlusJakartaSans')),
          backgroundColor: AppColors.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ────────────────────────────────────────────────────────
          Container(
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
                    const Text(
                      'Kirim Aspirasi',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar
                    _buildProgressBar(),
                    const SizedBox(height: 24),

                    // Category
                    const Text(
                      'Pilih Kategori',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Judul Aspirasi',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _titleCtrl,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Berikan judul singkat dan jelas...',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Judul wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Aspirasi',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          '$_charCount/500',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: _charCount >= 500
                                ? AppColors.error
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 7,
                      maxLength: 500,
                      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                          const SizedBox.shrink(),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ceritakan aspirasi atau kendala Anda secara detail...',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (v) => setState(() => _charCount = v.length),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Detail aspirasi wajib diisi';
                        if (v.trim().length < 20) return 'Minimal 20 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit button
                    GestureDetector(
                      onTap: _loading ? null : _submit,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: _loading
                              ? AppColors.tertiary.withValues(alpha: 0.55)
                              : AppColors.tertiary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _loading
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.tertiaryAlt.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.onTertiary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Kirim Aspirasi',
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onTertiary,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.send_rounded, color: AppColors.onTertiary, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Aspirasi Anda akan diproses oleh tim BEM JAYANUSA',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TAHAPAN PENGISIAN',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
            ),
            Text(
              _selectedCategory != null && _titleCtrl.text.isNotEmpty && _charCount >= 20
                  ? '3/3'
                  : _selectedCategory != null && _titleCtrl.text.isNotEmpty
                      ? '2/3'
                      : _selectedCategory != null
                          ? '1/3'
                          : '0/3',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
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
            value: _selectedCategory != null && _titleCtrl.text.isNotEmpty && _charCount >= 20
                ? 1.0
                : _selectedCategory != null && _titleCtrl.text.isNotEmpty
                    ? 0.66
                    : _selectedCategory != null
                        ? 0.33
                        : 0.0,
            backgroundColor: AppColors.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tertiaryAlt),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((cat) {
        final active = _selectedCategory == cat.label;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryContainer.withValues(alpha: 0.3)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 16,
                  color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
}
