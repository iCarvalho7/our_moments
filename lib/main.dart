import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddOrEditMomentBloc>(
          create: (_) => getIt<AddOrEditMomentBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        supportedLocales: const [Locale('pt', 'BR')],
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: const ColorScheme.light(primary: AppColors.timeLineColor),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'GrandHotel',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        routes: AppRoute.allRoutes,
        initialRoute: AppRoute.timeLine.tag,
      ),
    );
  }
}
