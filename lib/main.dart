import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/firebase_options.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import 'modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting();
  configureDependencies();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddOrEditMomentBloc>(
          create: (_) => getIt<AddOrEditMomentBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: Strings.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routes: AppRoute.allRoutes,
        initialRoute: AppRoute.login.tag,
      ),
    );
  }
}
