import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:rysolve/constants.dart';
import 'package:provider/provider.dart';
import 'package:rysolve/habits/calendar_column.dart';
import 'package:rysolve/habits/habits_manager.dart';
import 'package:rysolve/settings/settings_manager.dart';
import 'package:rysolve/navigation/navigation.dart';

class HabitsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.habitsPath,
      key: ValueKey(Routes.habitsPath),
      child: const HabitsScreen(),
    );
  }

  const HabitsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
    BannerAd? _bannerAd;
    bool _isBannerAdReady = false;
    @override
  void initState() {
    super.initState();
        _bannerAd = BannerAd(
          adUnitId: 'ca-app-pub-3940256099942544/6300978111',
          request: const AdRequest(),
          size: AdSize.banner,
          listener: BannerAdListener(
            onAdLoaded: (Ad ad) {
              setState(() {
                _isBannerAdReady = true;
              });
            },
            onAdFailedToLoad: (Ad ad, LoadAdError error) {
              ad.dispose();
              debugPrint('Banner ad failed to load: $error');
            },
          ),
        );

        _bannerAd!.load();
    Future.delayed(const Duration(seconds: 0), () async {
      showNotificationDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateManager>(
      builder: (
        context,
        appStateManager,
        child,
      ) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Rysolve",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: const Icon(
                  Icons.bar_chart,
                  semanticLabel: 'Statistics',
                ),
                color: Colors.grey[400],
                tooltip: 'Statistics',
                onPressed: () {
                  Provider.of<HabitsManager>(context, listen: false)
                      .hideSnackBar();
                  Provider.of<AppStateManager>(context, listen: false)
                      .goStatistics(true);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  semanticLabel: 'Settings',
                ),
                color: Colors.grey[400],
                tooltip: 'Settings',
                onPressed: () {
                  Provider.of<AppStateManager>(context, listen: false)
                      .goSettings(true);
                  Provider.of<HabitsManager>(context, listen: false)
                      .hideSnackBar();
                },
              ),
            ],
          ),
                    body: const CalendarColumn(),
                    bottomNavigationBar: _isBannerAdReady
                        ? SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          )
                        : null,
                    floatingActionButton: FloatingActionButton(
            onPressed: () {
              Provider.of<AppStateManager>(context, listen: false)
                  .goCreateHabit(true);
              Provider.of<HabitsManager>(context, listen: false).hideSnackBar();
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
              semanticLabel: 'Add',
              size: 35.0,
            ),
          ),
        );
      },
    );
  }

    @override
    void dispose() {
      _bannerAd?.dispose();
      super.dispose();
    }
  void showNotificationDialog(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showRestoreDialog(context);
      } else {
        resetNotifications();
      }
    });
  }

  void showRestoreDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.bottomSlide,
      title: "Notifications",
      desc: "Rysolve needs permission to send notifications to work properly.",
      btnOkText: "Allow",
      btnCancelText: "Cancel",
      btnCancelColor: Colors.grey,
      btnOkColor: HabitColors.primary,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        AwesomeNotifications()
            .requestPermissionToSendNotifications()
            .then((value) {
          resetNotifications();
        });
      },
    ).show();
  }

  void resetNotifications() {
    Provider.of<SettingsManager>(context, listen: false).resetAppNotification();
    Provider.of<HabitsManager>(context, listen: false)
        .resetHabitsNotifications();
  }
}
