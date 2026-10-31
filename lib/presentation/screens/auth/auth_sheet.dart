import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/haptic_feedback.dart';
import '../../widgets/aesthetic_button.dart';

class AuthBottomSheet extends StatefulWidget {
  final AuthService authService;

  const AuthBottomSheet({
    super.key,
    required this.authService,
  });

  static Future<void> show(BuildContext context, AuthService authService) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuthBottomSheet(authService: authService),
    );
  }

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  bool _isSignUp = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password');
      return;
    }

    setState(() => _errorMessage = null);
    AppHaptics.lightTap();

    bool success;
    if (_isSignUp) {
      final name = _nameController.text.trim();
      success = await widget.authService.registerWithEmail(email, password, name.isNotEmpty ? name : 'Creator');
    } else {
      success = await widget.authService.signInWithEmail(email, password);
    }

    if (success && mounted) {
      AppHaptics.success();
      Navigator.pop(context);
    } else if (mounted) {
      setState(() => _errorMessage = 'Authentication failed. Please check credentials.');
    }
  }

  Future<void> _googleSignIn() async {
    AppHaptics.lightTap();
    final success = await widget.authService.signInWithGoogle();
    if (success && mounted) {
      AppHaptics.success();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center pill drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.softPink,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎀', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSignUp ? 'Create Digicam Account' : 'Welcome to Digicam',
                      style: AppTypography.headingSmall(),
                    ),
                    Text(
                      _isSignUp ? 'Save presets & back up your aesthetic portfolio' : 'Sign in to access saved aesthetic shoots',
                      style: AppTypography.bodyMedium(color: AppColors.textMuted).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)),
              ),
            ],

            const SizedBox(height: 20),

            if (_isSignUp) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name or Aesthetic Alias',
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.deepPlum),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                filled: true,
                fillColor: AppColors.offWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.deepPlum),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: AppColors.offWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.deepPlum),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: widget.authService.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepPlum))
                  : AestheticButton(
                      onPressed: _submit,
                      label: _isSignUp ? 'Create Account' : 'Sign In',
                      icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                      backgroundColor: AppColors.deepPlum,
                      foregroundColor: AppColors.pureWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      borderRadius: 20,
                    ),
            ),

            const SizedBox(height: 12),

            // Google Sign In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _googleSignIn,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 28),
                label: const Text('Continue with Google', style: TextStyle(color: AppColors.deepPlum, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 16),

            // Toggle between Sign In / Sign Up & Guest Mode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _isSignUp = !_isSignUp);
                  },
                  child: Text(
                    _isSignUp ? 'Already have an account? Sign in' : 'New here? Create account',
                    style: const TextStyle(color: AppColors.deepPlum, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.authService.continueAsGuest();
                    Navigator.pop(context);
                  },
                  child: const Text('Guest Mode →', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
