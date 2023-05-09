import 'package:flutter/material.dart';
import 'package:rysolve/constants.dart';
import 'package:rysolve/habits/habits_manager.dart';
import 'package:rysolve/navigation/routes.dart';
import 'package:rysolve/statistics/empty_statistics_image.dart';
import 'package:rysolve/statistics/overall_statistics_card.dart';
import 'package:rysolve/statistics/statistics.dart';
import 'package:rysolve/statistics/statistics_card.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  static MaterialPage page() {
    return MaterialPage(
      name: Routes.statisticsPath,
      key: ValueKey(Routes.statisticsPath),
      child: const StatisticsScreen(),
    );
  }

  const StatisticsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
        ),
        backgroundColor: Colors.transparent,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: FutureBuilder(
          future: Provider.of<HabitsManager>(context).getFutureStatsData(),
          builder:
              (BuildContext context, AsyncSnapshot<AllStatistics> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.habitsData.isEmpty) {
                return const EmptyStatisticsImage();
              } else {
                return ListView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    OverallStatisticsCard(
                      total: snapshot.data!.total,
                      habits: snapshot.data!.habitsData.length,
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.habitsData
                          .map(
                            (index) => Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: StatisticsCard(data: index),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  color: HabitColors.primary,
                ),
              );
            }
          }),
    );
  }
}
