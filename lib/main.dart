import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'core/route/app_pages.dart';

void main() {
  runApp(const PromiseGuardApp());
}

class PromiseGuardApp extends StatelessWidget {
  const PromiseGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PromiseGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
    );
  }
}