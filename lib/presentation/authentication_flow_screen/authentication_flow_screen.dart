import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/forgot_password_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/social_login_widget.dart';
import './widgets/two_factor_auth_widget.dart';

class AuthenticationFlowScreen extends StatefulWidget {
  const AuthenticationFlowScreen({super.key});

  @override
  State<AuthenticationFlowScreen> createState() =>
      _AuthenticationFlowScreenState();
}

class _AuthenticationFlowScreenState extends State<AuthenticationFlowScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _showTwoFactorAuth = false;
  bool _showForgotPassword = false;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showTwoFactorDialog(String email) {
    setState(() {
      _userEmail = email;
      _showTwoFactorAuth = true;
    });
  }

  void _showForgotPasswordDialog() {
    setState(() {
      _showForgotPassword = true;
    });
  }

  void _hideTwoFactorDialog() {
    setState(() {
      _showTwoFactorAuth = false;
    });
  }

  void _hideForgotPasswordDialog() {
    setState(() {
      _showForgotPassword = false;
    });
  }

  void _onAuthenticationSuccess() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.homeDashboard);
  }

  void _onBiometricAuthSuccess() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, AppRoutes.homeDashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(26),
                  Theme.of(context).colorScheme.secondary.withAlpha(13),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 40),
                    _buildTabSection(),
                    const SizedBox(height: 32),
                    _buildSocialLoginSection(),
                    const SizedBox(height: 24),
                    _buildOrDivider(),
                    const SizedBox(height: 24),
                    _buildBiometricAuthSection(),
                    const SizedBox(height: 32),
                    _buildPrivacyPolicySection(),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
          if (_showTwoFactorAuth) _buildTwoFactorOverlay(),
          if (_showForgotPassword) _buildForgotPasswordOverlay(),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.security_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Secure Authentication',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Access your personalized learning journey with enterprise-grade security and multiple authentication options.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(51),
                width: 1,
              ),
            ),
            margin: const EdgeInsets.all(8),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
              tabs: const [
                Tab(
                  text: 'Sign In',
                  icon: Icon(Icons.login_rounded, size: 20),
                  height: 60,
                ),
                Tab(
                  text: 'Register',
                  icon: Icon(Icons.person_add_rounded, size: 20),
                  height: 60,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 450,
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                LoginFormWidget(
                  onLoading: _setLoading,
                  onSuccess: _onAuthenticationSuccess,
                  onTwoFactorRequired: _showTwoFactorDialog,
                  onForgotPassword: _showForgotPasswordDialog,
                ),
                RegistrationFormWidget(
                  onLoading: _setLoading,
                  onSuccess: _onAuthenticationSuccess,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return SocialLoginWidget(
      onLoading: _setLoading,
      onSuccess: _onAuthenticationSuccess,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {},
              textColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withAlpha(77),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.outline.withAlpha(77),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricAuthSection() {
    return BiometricAuthWidget(
      onLoading: _setLoading,
      onSuccess: _onBiometricAuthSuccess,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildPrivacyPolicySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Privacy & Terms',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                  ),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(
                    text:
                        '. Your data is protected with enterprise-grade encryption and GDPR compliance.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withAlpha(77),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Authenticating...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTwoFactorOverlay() {
    return Container(
      color: Colors.black.withAlpha(128),
      child: Center(
        child: TwoFactorAuthWidget(
          email: _userEmail,
          onClose: _hideTwoFactorDialog,
          onSuccess: _onAuthenticationSuccess,
          onLoading: _setLoading,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordOverlay() {
    return Container(
      color: Colors.black.withAlpha(128),
      child: Center(
        child: ForgotPasswordWidget(
          onClose: _hideForgotPasswordDialog,
          onLoading: _setLoading,
        ),
      ),
    );
  }
}
