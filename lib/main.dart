import 'package:elragol_el3nab_rest/features/orders/presentation/views/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/utils/app_colors/app_colors.dart';
import 'core/utils/constants/app_constants.dart';
import 'features/splash/presentation/views/splash_screen.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  const MyApp({super.key, });

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar', 'AR')],
          title: AppConstants.appTitle,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Cairo-Regular',
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mainColor),
            textTheme: TextTheme(
              displaySmall: GoogleFonts.cairo(fontSize: 32),
              headlineSmall: GoogleFonts.cairo(fontSize: 20),
              titleLarge: GoogleFonts.cairo(fontSize: 18),
              titleMedium: GoogleFonts.cairo(fontSize: 16),
              titleSmall: GoogleFonts.cairo(fontSize: 14),
              bodyLarge: GoogleFonts.cairo(fontSize: 14),
              bodySmall: GoogleFonts.cairo(fontSize: 12),
            ),
          ),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,

          home:  SplashScreen(),
        );
      },
    );
  }
}

