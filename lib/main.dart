import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// ignore_for_file: camel_case_types

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rysolve/habits/habits_manager.dart';
import 'package:rysolve/navigation/app_router.dart';
import 'package:rysolve/navigation/app_state_manager.dart';
import 'package:rysolve/notifications.dart';
import 'package:rysolve/settings/settings_manager.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> setupFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

 FirebaseMessaging.onMessage.listen((RemoteMessage message) {
   final notification = message.notification;

   if (notification != null) {
     showPushNotification(
       notification.title ?? 'Rysolve',
       notification.body ?? '',
     );
   }
 });
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

await MobileAds.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  await setupFirebaseMessaging();

  addLicenses();

  runApp(
    const rysolve(),
  );
}

class rysolve extends StatefulWidget {
  const rysolve({Key? key}) : super(key: key);

  @override
  State<rysolve> createState() => _rysolveState();
}

class _rysolveState extends State<rysolve> {
  final _appStateManager = AppStateManager();
  final _settingsManager = SettingsManager();
  final _habitManager = HabitsManager();
  late AppRouter _appRouter;

  @override
  void initState() {
    _settingsManager.initialize();
    _habitManager.initialize();
    initializeNotifications();
    GoogleFonts.config.allowRuntimeFetching = false;
    _appRouter = AppRouter(
      appStateManager: _appStateManager,
      settingsManager: _settingsManager,
      habitsManager: _habitManager,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _appStateManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _settingsManager,
        ),
        ChangeNotifierProvider(
          create: (context) => _habitManager,
        ),
      ],
      child: Consumer<SettingsManager>(builder: (context, counter, _) {
        return MaterialApp(
          title: 'Rysolve',
          scaffoldMessengerKey:
              Provider.of<HabitsManager>(context).getScaffoldKey,
          theme: Provider.of<SettingsManager>(context).getLight,
          darkTheme: Provider.of<SettingsManager>(context).getDark,
          home: Router(
            routerDelegate: _appRouter,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
        );
      }),
    );
  }
}

void addLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}
