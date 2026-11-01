import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/security/oauth_service.dart';
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

  Future<void> _handleOAuthSignIn(OAuthProvider provider) async {
    AppHaptics.lightTap();
    final success = await widget.authService.signInWithOAuth(provider);
    if (success && mounted) {
      AppHaptics.success();
      Navigator.pop(context);
    }
  }

  void _showJwtInspectorDialog() {
    final jwt = widget.authService.activeJwt;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.digicamDarkChassis,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: AppColors.retroGreen, size: 20),
            const SizedBox(width: 8),
            Text('JWT Session Claims', style: AppTypography.headingSmall(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.retroGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jwt != null && !jwt.isExpired ? 'TOKEN STATUS: VALID & ACTIVE' : 'NO ACTIVE JWT TOKEN',
                  style: AppTypography.retroDotMatrix(
                    fontSize: 11,
                    color: jwt != null && !jwt.isExpired ? AppColors.retroGreen : Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (jwt != null) ...[
                _buildClaimRow('Subject (sub)', jwt.subject ?? 'N/A'),
                _buildClaimRow('Email', jwt.email ?? 'N/A'),
                _buildClaimRow('Issuer (iss)', jwt.issuer ?? 'N/A'),
                _buildClaimRow('Expires At', jwt.expiresAt?.toIso8601String() ?? 'N/A'),
                _buildClaimRow('TTL Remaining', '${jwt.timeUntilExpiry.inMinutes} minutes'),
                const Divider(color: Colors.white24),
                Text('RAW JWT ACCESS TOKEN', style: AppTypography.retroDotMatrix(fontSize: 10, color: AppColors.retroOrange)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    jwt.raw,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white70),
                  ),
                ),
              ] else ...[
                const Text(
                  'Sign in with OAuth 2.0 or Email to issue and inspect cryptographic JWT session tokens.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.blushPink)),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.authService.currentUser;
    final isUserLoggedIn = currentUser != null && !currentUser.isGuest;

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
            const SizedBox(height: 16),

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUserLoggedIn
                            ? 'Logged In as ${currentUser.displayName}'
                            : _isSignUp
                                ? 'Create Digicam Account'
                                : 'Welcome to Digicam',
                        style: AppTypography.headingSmall(),
                      ),
                      Text(
                        isUserLoggedIn
                            ? 'Auth Method: ${currentUser.authMethod}'
                            : _isSignUp
                                ? 'Issues secure JWT credentials & OAuth tokens'
                                : 'Sign in via OAuth 2.0 PKCE or JWT credentials',
                        style: AppTypography.bodyMedium(color: AppColors.textMuted).copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // JWT Token Inspector trigger
                IconButton(
                  onPressed: _showJwtInspectorDialog,
                  icon: const Icon(Icons.token_rounded, color: AppColors.deepPlum),
                  tooltip: 'Inspect Active JWT Token',
                ),
              ],
            ),

            if (isUserLoggedIn) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.lavender,
                        child: Icon(Icons.verified_user_rounded, color: AppColors.deepPlum),
                      ),
                      title: Text(currentUser.displayName, style: AppTypography.title()),
                      subtitle: Text(currentUser.email, style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('JWT VERIFIED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.deepPlum)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showJwtInspectorDialog,
                            icon: const Icon(Icons.visibility_rounded, size: 16),
                            label: const Text('View JWT Claims'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.deepPlum,
                              side: const BorderSide(color: AppColors.cardBorder),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await widget.authService.signOut();
                              if (context.mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: const Text('Sign Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red.shade700,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
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

              const SizedBox(height: 16),

              if (_isSignUp) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name or Alias',
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

              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: widget.authService.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.deepPlum))
                    : AestheticButton(
                        onPressed: _submit,
                        label: _isSignUp ? 'Create Account (JWT)' : 'Sign In (JWT)',
                        icon: _isSignUp ? Icons.person_add_rounded : Icons.login_rounded,
                        backgroundColor: AppColors.deepPlum,
                        foregroundColor: AppColors.pureWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        borderRadius: 20,
                      ),
              ),

              const SizedBox(height: 12),

              // OAuth 2.0 PKCE Providers Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleOAuthSignIn(OAuthProvider.google),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 26),
                      label: const Text('Google OAuth', style: TextStyle(color: AppColors.deepPlum, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleOAuthSignIn(OAuthProvider.apple),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: const Icon(Icons.apple_rounded, color: Colors.black, size: 20),
                      label: const Text('Apple Sign-In', style: TextStyle(color: AppColors.deepPlum, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Toggle between Sign In / Sign Up & Guest Mode
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
                    child: Text(
                      _isSignUp ? 'Already registered? Sign in' : 'New creator? Create account',
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
          ],
        ),
      ),
    );
  }
}
