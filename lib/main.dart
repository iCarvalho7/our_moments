import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/firebase_options.dart';

import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/time_line/presenter/bloc/time_line_bloc.dart';

import 'modules/moment/presenter/bloc/add_date_bloc.dart';
import 'modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'modules/moment/presenter/bloc/photos_bloc.dart';
import 'modules/moment/presenter/bloc/select_type_bloc.dart';

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
        BlocProvider<TimeLineBloc>(
          create: (_) => getIt<TimeLineBloc>(),
        ),
        BlocProvider<AddOrEditMomentBloc>(
          create: (_) => getIt<AddOrEditMomentBloc>(),
        ),
        BlocProvider<SelectTypeBloc>(
          create: (_) => getIt<SelectTypeBloc>(),
        ),
        BlocProvider<PhotosBloc>(
          create: (_) => getIt<PhotosBloc>(),
        ),
        BlocProvider<AddDateBloc>(
          create: (_) => getIt<AddDateBloc>(),
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
          textTheme: GoogleFonts.interTextTheme(),
        ),
        routes: AppRoute.allRoutes,
        initialRoute: AppRoute.timeLine.tag,
      ),
    );
  }
}
