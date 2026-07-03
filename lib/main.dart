import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/scheme_list_screen.dart';
import 'services/secure_storage_service.dart';
import 'viewmodels/login_view_model.dart';
import 'viewmodels/scheme_list_view_model.dart';
import 'viewmodels/scheme_detail_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the entire app to portrait mode at the Flutter engine level.
  // Combined with android:screenOrientation="portrait" in the Manifest,
  // this prevents any screen from rotating — even on orientation change.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final secureStorage = SecureStorageService();
  final hasToken = await secureStorage.hasToken();

  runApp(
    MyApp(
      hasToken: hasToken,
      secureStorage: secureStorage,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasToken;
  final SecureStorageService? secureStorage;

  const MyApp({
    super.key,
    required this.hasToken,
    this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(
            storageService: secureStorage ?? SecureStorageService(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SchemeListViewModel()),
        ChangeNotifierProvider(create: (_) => SchemeDetailViewModel()),
      ],
      child: MaterialApp(
        title: 'FundBrowser',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Adapts to system dark/light mode automatically
        home: hasToken ? const SchemeListScreen() : const LoginScreen(),
      ),
    );
  }
}
