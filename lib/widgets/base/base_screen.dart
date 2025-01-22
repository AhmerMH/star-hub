import 'package:flutter/material.dart';
import 'package:starhub/widgets/epg/epg.dart';
import 'package:starhub/widgets/livetv/live-tv.dart';
import 'package:starhub/widgets/movies/movies.dart';
import 'package:starhub/widgets/series/series.dart';
import 'package:starhub/widgets/settings/settings.dart';

// Colors for easy customization
const Color backgroundColor = Colors.black;
final Color selectedItemColor = Colors.red[600]!;
final Color unselectedItemColor = Colors.grey[400]!;
const Color appBarColor = Colors.black;
const Color appBarTextColor = Colors.white;
const Color appBarIconColor = Colors.white;

class BaseScreen extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const BaseScreen({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final navigationBarTheme = NavigationBarThemeData(
    labelTextStyle: WidgetStateProperty.all(
      TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: unselectedItemColor),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            const Text(
              'Star Hub',
              style: TextStyle(
                color: appBarTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: appBarIconColor),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: appBarIconColor),
            onPressed: () {
              // Favorites functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          final isTV = MediaQuery.of(context).size.width > 1200;
          const textStyle = TextStyle(fontSize: 16);
          const iconSize = 26.0;
          return Theme(
            data: ThemeData(
              navigationBarTheme: navigationBarTheme,
            ),
            child: NavigationBar(
                backgroundColor: appBarColor,
                selectedIndex: widget.currentIndex,
                onDestinationSelected: (index) {
                  if (index == 0) {
                    navigateToOtherScreen(context, const MoviesScreen());
                  } 
                  else if (index == 1) {
                    navigateToOtherScreen(context, const SeriesScreen());
                  }
                  else if (index == 2) {
                    navigateToOtherScreen(context, const LiveTvScreen());
                  }
                  else if (index == 3) {
                    navigateToOtherScreen(context, const EpgScreen());
                  }
                  else if (index == 4) {
                    navigateToOtherScreen(context, const SettingsScreen());
                  }
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.movie,
                      size: iconSize,
                      color: widget.currentIndex == 0
                          ? selectedItemColor
                          : unselectedItemColor,
                    ),
                    label: 'Movies',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.slow_motion_video,
                      size: iconSize,
                      color: widget.currentIndex == 1
                          ? selectedItemColor
                          : unselectedItemColor,
                    ),
                    label: 'Series',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.live_tv,
                      size: iconSize,
                      color: widget.currentIndex == 2
                          ? selectedItemColor
                          : unselectedItemColor,
                    ),
                    label: 'Live TV',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.calendar_month,
                      size: iconSize,
                      color: widget.currentIndex == 3
                          ? selectedItemColor
                          : unselectedItemColor,
                    ),
                    label: 'EPG',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.manage_accounts,
                      size: iconSize,
                      color: widget.currentIndex == 4
                          ? selectedItemColor
                          : unselectedItemColor,
                    ),
                    label: 'Settings',
                  ),
                ],
                height: isTV ? 80 : 60,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                indicatorColor: Colors.transparent),
          );
        },
      ),
    );
  }

  void navigateToOtherScreen(BuildContext context, Widget screen) {
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => screen),
        (route) => false,
      );
    }
  }
}
