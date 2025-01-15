import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starhub/services/credentials_service.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/base/base_screen.dart';
import 'package:starhub/widgets/login/login.dart';
import 'package:starhub/widgets/settings/widgets/account-info.dart';

// Colors for easy customization
const Color usernameColor = Colors.white;
const Color dateColor = Colors.yellow;
const Color listItemColor = Colors.white;
const Color dividerColor = Colors.white24;
const Color listItemIconColor = Colors.white;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await CredentialsService.getUserInfo();
    setState(() {
      username = userInfo['username'] ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTV = MediaQuery.of(context).size.width > 1200;
          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTV ? 100 : 20,
                vertical: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      'assets/images/user_placeholder_no_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: isTV ? 40 : 20),
                  Text(
                    username,
                    style: TextStyle(
                      color: usernameColor,
                      fontSize: isTV ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isTV ? 20 : 10),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                    style: TextStyle(
                        color: dateColor,
                        fontSize: isTV ? 18 : 14,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: isTV ? 60 : 40),
                  Container(
                      width: isTV
                          ? constraints.maxWidth * 0.4
                          : constraints.maxWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _settingItems(context, isTV, isLandscape)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _settingItems(context, isTV, isLandscape) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.account_circle,
            color: listItemIconColor,
            size: isTV ? 32 : 24,
          ),
          title: Text(
            'Account Info',
            style: TextStyle(
              color: listItemColor,
              fontSize: isTV ? 24 : 16,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountInfoScreen(),
              ),
            );
          },
        ),
        const Divider(color: dividerColor),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: listItemIconColor,
            size: isTV ? 32 : 24,
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: listItemColor,
              fontSize: isTV ? 24 : 16,
            ),
          ),
          onTap: () async {
            await IptvService.logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
}
