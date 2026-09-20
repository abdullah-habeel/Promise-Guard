import 'package:get/get.dart';
import 'package:promise_guard/core/route/app_route.dart';
import 'package:promise_guard/features/agreement_record/binding/agreement_record_binding.dart';
import 'package:promise_guard/features/agreement_record/view/agreement_record_screen.dart';
import 'package:promise_guard/features/auth/binding/auth_binding.dart';
import 'package:promise_guard/features/auth/view/auth_screen.dart';
import 'package:promise_guard/features/drift_alert/binding/drift_alert_binding.dart';
import 'package:promise_guard/features/drift_alert/view/drift_alert_screen.dart';
import 'package:promise_guard/features/home/binding/home_binding.dart';
import 'package:promise_guard/features/home/view/home_screen.dart';
import 'package:promise_guard/features/live_call/binding/live_call_binding.dart';
import 'package:promise_guard/features/live_call/view/live_call_screen.dart';
import 'package:promise_guard/features/process/binding/process_binding.dart';
import 'package:promise_guard/features/process/view/process_screen.dart';
import 'package:promise_guard/features/transcript/binding/transcript_binding.dart';
import 'package:promise_guard/features/transcript/view/transcript_screen.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.auth;

  static final pages = [
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.processing,
      page: () => const ProcessingScreen(),
      binding: ProcessingBinding(),
    ),
    GetPage(
      name: AppRoutes.transcript,
      page: () => const TranscriptScreen(),
      binding: TranscriptBinding(),
    ),
    GetPage(
      name: AppRoutes.driftAlert,
      page: () => const DriftAlertScreen(),
      binding: DriftAlertBinding(),
    ),
    GetPage(
      name: AppRoutes.agreementRecord,
      page: () => const AgreementRecordScreen(),
      binding: AgreementRecordBinding(),
    ),
    GetPage(
  name: AppRoutes.liveCall,
  page: () => const LiveCallScreen(),
  binding: LiveCallBinding(),
),
  ];
}