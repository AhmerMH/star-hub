import 'package:flutter/material.dart';
import 'package:starhub/services/iptv_service.dart';
import 'package:starhub/widgets/loader/loader.dart';
import 'package:starhub/widgets/movies/movies.dart';

// Colors for easy customization
const Color welcomeTextColor = Colors.white;
final Color inputBackgroundColor = Colors.grey[800]!;
const Color inputTextColor = Colors.white;
const Color inputIconColor = Colors.white;
const Color inputBorderColor = Colors.white;
const Color inputFocusColor = Colors.white;
final Color buttonBackgroundColor = Colors.red[500]!;
const Color buttonTextColor = Colors.white;
const Color copyrightTextColor = Colors.white;
const Color dialogBackgroundColor = Colors.black;
const Color dialogTextColor = Colors.white;
const Color dialogButtonColor = Colors.white;
final Color dialogButtonBackgroundColor = Colors.grey[800]!;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _autoLoginFailed = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _autoLogin() async {
    final credentials = await IptvService.getSavedCredentials();
    final username = credentials['username'];
    final password = credentials['password'];

    if (username == null ||
        password == null ||
        username == '' ||
        password == '') {
      setState(() {
        _autoLoginFailed = true;
      });
      return;
    }

    final success = await IptvService.login(username, password);

    _handleSuccessOrError(success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width > 600
                            ? 500
                            : MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Welcome Back!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: welcomeTextColor,
                              ),
                            ),
                            _autoLoginFailed
                                ? _buildLoginForm()
                                : const SizedBox(
                                    height: 100,
                                    child: LoaderOverlay(),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 16,
            child: Text(
              '© Star Hub',
              style: TextStyle(
                  color: copyrightTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  dynamic _buildLoginForm() {
    return Column(children: [
      const SizedBox(height: 30),
      TextField(
        controller: _usernameController,
        style: const TextStyle(color: inputTextColor),
        decoration: InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
          filled: true,
          fillColor: inputBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: inputFocusColor),
          ),
          prefixIcon: const Icon(Icons.person, color: inputIconColor),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _passwordController,
        style: const TextStyle(color: inputTextColor),
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
          filled: true,
          fillColor: inputBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: inputFocusColor),
          ),
          prefixIcon: const Icon(Icons.lock, color: inputIconColor),
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _handleLogin(),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 18,
              color: buttonTextColor,
            ),
          ),
        ),
      ),
    ]);
  }

  Future<void> _handleLogin() async {
    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoaderOverlay();
      },
    );

    final username = _usernameController.text;
    final password = _passwordController.text;

    final success = await IptvService.login(username, password);

    // Hide loader
    if (mounted) {
      Navigator.of(context).pop();
    }

    _handleSuccessOrError(success);
  }

  _handleSuccessOrError(success) {
    if (!success && mounted) {
      setState(() {
        _autoLoginFailed = true;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: dialogBackgroundColor,
            title: const Text(
              'Invalid Credentials',
              style: TextStyle(
                color: dialogTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Login Failed. Please check the details entered and try again',
              style: TextStyle(
                color: dialogTextColor,
                fontSize: 16,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: dialogButtonColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MoviesScreen(),
          ),
        );
      }
    }
  }
}
