import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/app_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class SampleGetXApp extends StatelessWidget {
  const SampleGetXApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D9488),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F7F5),
    );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GetXDrop Sample',
      theme: theme,
      initialBinding: AppBinding(),
      initialRoute: AppRoutes.splash,
      defaultTransition: Transition.cupertino,
      getPages: AppPages.pages,
    );
  }
}
