import 'package:firebase_core/firebase_core.dart';
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
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'GrandHotel',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontFamily: 'GrandHotel',
              fontSize: 35,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: BorderSide.none,
              backgroundColor: AppColors.timeLineColor,
              minimumSize: Size(MediaQuery.of(context).size.width, 55),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding:
                EdgeInsets.symmetric(vertical: 16.0, horizontal: 64.0),
            fillColor: Color(0xFFF8EEEE),
            filled: true,
            isDense: true,
            hintStyle: TextStyle(
              fontFamily: 'GrandHotel',
              fontSize: 20,
              color: Color(0xFFB6B6B6),
            ),
            prefixIconColor: Color(0xFF605D5D),
            suffixIconColor: Color(0xFF605D5D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Color(0xFF9B9191)),
            ),
          ),
        ),
        routes: AppRoute.allRoutes,
        initialRoute: AppRoute.login.tag,
      ),
    );
  }
}
