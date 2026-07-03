import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/firebase_options.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';
import 'package:nossos_momentos/modules/core/feature_toggles/feature_toggle_manager.dart';
import 'package:nossos_momentos/modules/premium/config/revenue_cat_config.dart';
import 'package:nossos_momentos/modules/premium/entitlement_sync_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'modules/moment/presenter/bloc/add_or_edit_moment_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting();
  configureDependencies();
  await _initializeFeatureToggles();
  await _configurePurchases();
  await _configureNotifications();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(const MyApp());
}

/// Fetches Remote Config values so feature toggles are ready before any
/// subsystem checks them. Must run after [configureDependencies].
Future<void> _initializeFeatureToggles() async {
  await getIt<FeatureToggleManager>().initialize();
}

/// Initializes RevenueCat (`purchases_flutter`). The SDK only supports iOS and
/// Android, so we skip it on web/desktop to keep those builds working. We also
/// skip when the API keys are still placeholders (see [RevenueCatConfig]) or
/// when the [AppFeatureToggle.revenueCat] toggle is disabled.
Future<void> _configurePurchases() async {
  if (!getIt<FeatureToggleManager>().isEnabled(AppFeatureToggle.revenueCat)) return;
  if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;
  if (!RevenueCatConfig.isConfigured) return;

  final apiKey = Platform.isAndroid
      ? RevenueCatConfig.androidApiKey
      : RevenueCatConfig.iosApiKey;

  await Purchases.configure(PurchasesConfiguration(apiKey));

  // Global listener: keep Firestore + premium gates in sync on renewals,
  // expirations and Customer Center changes. Fire-and-forget; DI is already
  // configured at this point (configureDependencies ran above).
  Purchases.addCustomerInfoUpdateListener((_) {
    getIt<EntitlementSyncService>().refresh();
  });
}

/// Initializes local notifications (`flutter_local_notifications` + timezone)
/// for the premium "Neste dia" reminder. Skipped on web (the plugin is
/// mobile/desktop only). Reconciles the OS schedule with the current premium
/// status + user preference at startup.
Future<void> _configureNotifications() async {
  if (kIsWeb) return;
  final service = getIt<NotificationService>();
  await service.init();
  await service.syncSchedule();
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
        navigatorKey: kIsWeb ? null : getIt<NotificationService>().navigatorKey,
        title: Strings.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routes: AppRoute.allRoutes,
        initialRoute: AppRoute.login.tag,
      ),
    );
  }
}
