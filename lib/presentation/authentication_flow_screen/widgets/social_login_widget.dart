import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function(bool) onLoading;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const SocialLoginWidget({
    super.key,
    required this.onLoading,
    required this.onSuccess,
    required this.onError,
  });

  Future<void> _handleSocialLogin(String provider, BuildContext context) async {
    onLoading(true);
    HapticFeedback.lightImpact();

    try {
      // Simulate API call for social login
      await Future.delayed(const Duration(seconds: 1));

      // Mock different scenarios
      if (provider.toLowerCase() == 'google') {
        // Mock Google Sign-In success
        onSuccess();
      } else if (provider.toLowerCase() == 'facebook') {
        // Mock Facebook login with user cancellation
        throw Exception('User cancelled the login process');
      } else if (provider.toLowerCase() == 'apple') {
        // Mock Apple Sign-In success
        onSuccess();
      }
    } catch (e) {
      onError('$provider login failed: ${e.toString()}');
    } finally {
      onLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Social Login',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quick access with your existing accounts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildGoogleButton(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildFacebookButton(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildAppleButton(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSocialLoginFeatures(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _handleSocialLogin('Google', context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(77),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Google',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacebookButton(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _handleSocialLogin('Facebook', context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1877F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.facebook,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                'Facebook',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppleButton(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _handleSocialLogin('Apple', context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.apple,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                'Apple',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Secure OAuth 2.0 authentication with native SDK integration',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
