import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/bluetooth_pairing_wizard/bluetooth_pairing_wizard.dart';
import '../presentation/assessment_screen/assessment_screen.dart';
import '../presentation/lesson_player/lesson_player.dart';
import '../presentation/modules_overview_screen/modules_overview_screen.dart';
import '../presentation/social_hub_screen/social_hub_screen.dart';
import '../presentation/authentication_flow_screen/authentication_flow_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String onboardingFlow = '/onboarding-flow';
  static const String bluetoothPairingWizard = '/bluetooth-pairing-wizard';
  static const String assessment = '/assessment-screen';
  static const String lessonPlayer = '/lesson-player';
  static const String modulesOverviewScreen = '/modules-overview-screen';
  static const String socialHubScreen = '/social-hub-screen';
  static const String authenticationFlowScreen = '/authentication-flow-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    onboardingFlow: (context) => const OnboardingFlow(),
    bluetoothPairingWizard: (context) => const BluetoothPairingWizard(),
    assessment: (context) => const AssessmentScreen(),
    lessonPlayer: (context) => const LessonPlayer(),
    modulesOverviewScreen: (context) => const ModulesOverviewScreen(),
    socialHubScreen: (context) => const SocialHubScreen(),
    authenticationFlowScreen: (context) => const AuthenticationFlowScreen(),
    // TODO: Add your other routes here
  };
}
