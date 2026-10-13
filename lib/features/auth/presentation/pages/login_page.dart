import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  Future<void> _onGooglePressed() async {
    // Let the web preview continue into the app without Firebase Web setup.
    // Release builds and native platforms always use real Google sign-in.
    if (kDebugMode && kIsWeb) {
      widget.onAuthenticated();
      return;
    }
    await _signIn(_authService.signInWithGoogle);
  }

  Future<void> _signIn(Future<UserCredential> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      if (mounted) widget.onAuthenticated();
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseMessage(error));
    } on AuthException catch (error) {
      _showMessage(_isArabic
          ? (kIsWeb
              ? 'تسجيل الدخول من الويب محتاج تسجيل تطبيق Web في Firebase.'
              : 'Firebase غير مهيأ للمنصة الحالية.')
          : error.message);
    } catch (error) {
      if (error is SignInWithAppleAuthorizationException &&
          error.code == AuthorizationErrorCode.canceled) {
        return;
      }
      _showMessage(_isArabic
          ? 'حصلت مشكلة أثناء تسجيل الدخول. راجع إعدادات Firebase.'
          : 'Sign-in failed. Check the Firebase provider setup and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _firebaseMessage(FirebaseAuthException error) {
    if (error.code == 'account-exists-with-different-credential') {
      return _isArabic
          ? 'الحساب موجود بطريقة تسجيل دخول مختلفة.'
          : 'This account already exists with a different sign-in method.';
    }
    return _isArabic
        ? 'تعذر تسجيل الدخول. تأكد من تفعيل الطريقة في Firebase.'
        : 'Could not sign in. Make sure this provider is enabled in Firebase.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: _isArabic ? Alignment.centerRight : Alignment.centerLeft,
                    child: _BrandMark(color: colors.primary),
                  ),
                  const SizedBox(height: 58),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.link_rounded, size: 36, color: colors.primary),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isArabic ? 'كل روابطك، في مكان واحد.' : 'Your links, all in one place.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          height: 1.15,
                          letterSpacing: -1.1,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isArabic
                        ? 'سجّل دخولك وابدأ في بناء صفحتك ومشاركة اللي يهمك.'
                        : 'Sign in to build your page and share what matters to you.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: appColors.secondaryText,
                          height: 1.55,
                        ),
                  ),
                  const SizedBox(height: 36),
                  _ProviderButton(
                    label: _isArabic ? 'المتابعة باستخدام Google' : 'Continue with Google',
                    onPressed: _isLoading ? null : _onGooglePressed,
                    isLoading: _isLoading,
                    leading: const _GoogleMark(),
                    background: colors.surface,
                    foreground: colors.onSurface,
                    border: colors.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  _ProviderButton(
                    label: _isArabic ? 'المتابعة باستخدام Apple' : 'Continue with Apple',
                    onPressed: _isLoading ? null : () => _signIn(_authService.signInWithApple),
                    isLoading: _isLoading,
                    leading: const Icon(Icons.apple, size: 22),
                    background: isDark ? const Color(0xFFF5F5F5) : const Color(0xFF111114),
                    foreground: isDark ? const Color(0xFF111114) : Colors.white,
                    border: Colors.transparent,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isArabic
                        ? 'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية.'
                        : 'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appColors.secondaryText,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_rounded, color: color, size: 24),
          const SizedBox(width: 7),
          Text('link', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: color, letterSpacing: -0.7)),
        ],
      );
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) => const Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
          children: [
            TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFDB4437))),
            TextSpan(text: 'o', style: TextStyle(color: Color(0xFFF4B400))),
            TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
            TextSpan(text: 'l', style: TextStyle(color: Color(0xFF0F9D58))),
            TextSpan(text: 'e', style: TextStyle(color: Color(0xFFDB4437))),
          ],
        ),
      );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget leading;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 58,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            side: BorderSide(color: border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.3, color: foreground),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [leading, const SizedBox(width: 12), Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))],
                ),
        ),
      );
}
