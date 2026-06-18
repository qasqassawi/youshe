import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      final role = authProvider.userRole;
      if (role != null) {
        context.go(role == UserRole.shopOwner ? '/owner/dashboard' : '/customer/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final t = (String key) => AppLocalizations.t(key, locale);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.checkroom, size: 80, color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(t('appName'), style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 8),
                Text(t('tagline'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    )),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return t('fieldRequired');
                    if (!v.contains('@')) return t('invalidEmail');
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: t('password'),
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return t('fieldRequired');
                    if (v.length < 6) return t('passwordTooShort');
                    return null;
                  },
                ),
                if (authProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(authProvider.error!, style: const TextStyle(color: AppTheme.error)),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    child: authProvider.isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(t('login')),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(t('dontHaveAccount')),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: authProvider.isLoading ? null : () async {
                      final authProvider = context.read<AuthProvider>();
                      final success = await authProvider.signInWithGoogle();
                      if (success && context.mounted) {
                        final role = authProvider.userRole;
                        if (role != null) {
                          context.go(role == UserRole.shopOwner ? '/owner/dashboard' : '/customer/home');
                        }
                      }
                    },
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Text(t('signInWithGoogle')),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: authProvider.isLoading ? null : () async {
                    final authProvider = context.read<AuthProvider>();
                    final success = await authProvider.signInAnonymously();
                    if (success && context.mounted) {
                      final role = authProvider.userRole;
                      if (role != null) {
                        context.go(role == UserRole.shopOwner ? '/owner/dashboard' : '/customer/home');
                      }
                    }
                  },
                  icon: const Icon(Icons.person_outline, size: 18),
                  label: Text(t('continueAsGuest')),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.store_outlined, size: 14, color: AppTheme.accent),
                    const SizedBox(width: 6),
                    Text(
                      t('shopOwnerLogin'),
                      style: TextStyle(color: AppTheme.accent, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
