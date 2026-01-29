import 'package:go_router/go_router.dart';
import 'package:neuro_access/ui/screens/home_screen.dart';
import 'package:neuro_access/ui/screens/patient_info_screen.dart';
import 'package:neuro_access/ui/screens/screening_screen.dart';
import 'package:neuro_access/ui/screens/settings_screen.dart';
import 'package:neuro_access/ui/screens/splash_screen.dart';
import 'package:neuro_access/ui/screens/results_screen.dart';
import 'package:neuro_access/ui/shell/app_shell.dart';
import 'package:neuro_access/services/ml_inference_service.dart';

/// 앱 라우터 설정
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 스플래시 화면
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // 메인 앱 셸 (Bottom Navigation)
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/patient-info',
          builder: (context, state) => const PatientInfoScreen(),
        ),
        GoRoute(
          path: '/screening',
          builder: (context, state) {
            final patientInfo = state.extra as PatientInfo?;
            return ScreeningScreen(patientInfo: patientInfo);
          },
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    
    // 결과 화면 (모달)
    GoRoute(
      path: '/results',
      builder: (context, state) {
        final result = state.extra as InferenceResult;
        return ResultsScreen(result: result);
      },
    ),
  ],
);
