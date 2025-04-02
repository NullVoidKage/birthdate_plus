import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'viewmodels/age_calculator_viewmodel.dart';
import 'screens/main_page.dart';
import 'services/preferences_service.dart';

void main() async {
  try {
    print('Starting app initialization...');
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    // Initialize AdMob
    await MobileAds.instance.initialize();
    print('AdMob initialized');

    // Initialize providers
    print('Creating language provider...');
    final languageProvider = LanguageProvider();
    print('Initializing language provider...');
    await languageProvider.initializeAsync(); // Wait for initial load
    print('Language provider initialization completed');
    
    print('Running app with initialized providers...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider.value(value: languageProvider),
          ChangeNotifierProvider(create: (_) => AgeCalculatorViewModel()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    // Run app with default providers in case of error
    print('Running app with default providers...');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) {
            print('Creating fallback language provider...');
            final provider = LanguageProvider();
            provider.initializeAsync().then((_) => print('Fallback language provider initialized'));
            return provider;
          }),
          ChangeNotifierProvider(create: (_) => AgeCalculatorViewModel()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Building MyApp widget');
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        print('MyApp Consumer2 builder called. Language provider initialized: ${languageProvider.isInitialized}');
        
        if (!languageProvider.isInitialized) {
          print('Language provider not initialized, showing loading screen');
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing...', 
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        print('Building main MaterialApp with locale: ${languageProvider.currentLocale.languageCode}');
        return MaterialApp(
          title: 'Birthdate+',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('es'), // Spanish
            Locale('hi'), // Hindi
            Locale('pt'), // Portuguese
            Locale('zh'), // Chinese
            Locale('ko'), // Korean
            Locale('ja'), // Japanese
          ],
          locale: languageProvider.currentLocale,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) {
              return supportedLocales.first;
            }
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          builder: (context, child) {
            // Ensure AppLocalizations is initialized
            if (AppLocalizations.of(context) == null) {
              return Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return child!;
          },
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.purple,
            scaffoldBackgroundColor: const Color(0xFF1A1A1A),
            useMaterial3: true,
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const MainPage(),
        );
      },
    );
  }
}
