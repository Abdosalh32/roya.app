// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/background_wrapper.dart';
import 'core/services/app_lifecycle.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل المتغيرات البيئية
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️  ملف .env غير موجود أو فشل التحميل');
  }

  // تهيئة الخدمات والاعتماديات الأولية قبل تشغيل التطبيق
  InitialBinding().dependencies();

  // تهيئة مراقب دورة حياة التطبيق
  initLifecycleObserver();

  // جلب اللغة المحفوظة
  final localizationService = Get.put(LocalizationService(), permanent: true);
  final savedLocale = await localizationService.getSavedLocale();

  runApp(RoyaApp(savedLocale: savedLocale));
}

class RoyaApp extends StatelessWidget {
  final Locale savedLocale;
  const RoyaApp({super.key, required this.savedLocale});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit يُهيّئ flutter_screenutil على مستوى التطبيق
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp.router(
          title: 'رويا',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routeInformationParser: AppRouter.router.routeInformationParser,
          routerDelegate: AppRouter.router.routerDelegate,
          routeInformationProvider: AppRouter.router.routeInformationProvider,
          translations: AppTranslations(),
          locale: savedLocale,
          fallbackLocale: LocalizationService.fallbackLocale,
          builder: (context, widget) {
            // ضمان اتجاه الواجهة حسب اللغة (LTR أو RTL)
            return BackgroundWrapper(child: Directionality(
              textDirection: Get.locale?.languageCode == 'en'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: widget ?? const SizedBox.shrink(),
            ),
            );
          },
        );
      },
    );
  }
}
