import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starhub/services/credentials_service.dart';

// Colors for easy customization
const Color backgroundColor = Colors.black;
const Color borderColor = Colors.white;
final Color iconColor = Colors.yellow[700]!;
const Color keyTextColor = Colors.white;
const Color valueTextColor = Colors.white;
const Color appBarColor = Colors.black;
const Color appBarTextColor = Colors.white;
const Color appBarIconColor = Colors.white;
const Color borderColor2 = Colors.yellow;
final Color cardBackgroundColor = Colors.black.withOpacity(0.7);

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  dynamic userInfo = {};

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final info = await CredentialsService.getUserInfo();
    setState(() {
      userInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appBarIconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account Info',
          style: TextStyle(
            color: appBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: borderColor2, width: .5),
            right: BorderSide(color: borderColor2, width: .5),
            bottom: BorderSide(color: borderColor2, width: .5),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: .5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoTile(
                      'Username',
                      userInfo['username'] ?? '',
                      Icons.person,
                    ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Status',
                      userInfo['status'] ?? '',
                      Icons.info,
                    ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Expiration Date',
                      formatDate(userInfo['expirationDate']),
                      Icons.calendar_today,
                    ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Is Trial Account',
                      userInfo['isTrialAccount']?.toString() == '0'
                          ? 'No'
                          : 'Yes',
                      Icons.new_releases,
                    ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Active Connections',
                      userInfo['activeConnections']?.toString() == '0'
                          ? 'No'
                          : 'Yes',
                      Icons.device_hub,
                    ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Max Connections',
                      userInfo['maxConnections']?.toString() ?? '',
                      Icons.group,
                    ),
                    // const Divider(color: borderColor),
                    // _buildInfoTile(
                    //   'Allowed Format',
                    //   userInfo['allowedFormat'] ?? '',
                    //   Icons.format_list_bulleted,
                    // ),
                    const Divider(color: borderColor),
                    _buildInfoTile(
                      'Created At',
                      formatDate(userInfo['createdAt']),
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  formatDate(date) {
    return DateFormat('MMMM dd, yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(int.parse(date ?? '0') * 1000));
  }

  Widget _buildInfoTile(String key, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(
              key,
              style: const TextStyle(
                color: keyTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: valueTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
