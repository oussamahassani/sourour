import 'package:flutter/material.dart';
import 'package:frent/providers/paiement_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:nested/nested.dart';

import 'providers/devis_provider.dart';
import 'providers/fournisseur_provider.dart';
import 'providers/client_provider.dart';
import 'providers/article_provider.dart';
import 'screens/achat_direct.dart';
import 'services/achat_service.dart';
import 'services/devis_service.dart';
import 'services/fournisseur_service.dart';
import 'services/article_service.dart';
import 'screens/login.dart';
import 'screens/signup.dart';
import 'config.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              'Erreur critique',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              details.exceptionAsString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => runApp(const MyApp()),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),

        // Providers existants
        ChangeNotifierProvider(create: (_) => ClientProvider()),

        Provider<FournisseurService>(
          create:
              (context) => FournisseurService(
                baseUrl: '${AppConfig.baseUrl}',
                client: context.read<http.Client>(),
              ),
        ),

        ChangeNotifierProxyProvider<FournisseurService, FournisseurProvider>(
          create:
              (context) => FournisseurProvider(
                service: context.read<FournisseurService>(),
              ),
          update:
              (context, service, previous) => previous!..updateService(service),
        ),

        ChangeNotifierProvider(
          create:
              (context) => ArticleProvider(
                service: ArticleService(), // Initialisation correcte du service
              ),
        ),

        ChangeNotifierProvider(create: (_) => PaiementProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mon Application',
        theme: _buildAppTheme(),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder:
                (context) => Scaffold(
                  body: Center(
                    child: Text('Page non trouvée: ${settings.name}'),
                  ),
                ),
          );
        },
      ),
    );
  }

  ThemeData _buildAppTheme() {
    const primaryColor = Color(0xFF41B1A2);
    const secondaryColor = Color(0xFFE8A87C);

    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        color: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 18),
        bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}

// WelcomeScreen toujours inchangé
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 40),
                            Hero(
                              tag: 'app-logo',
                              child: Image.asset(
                                'images/logo.png',
                                width: constraints.maxWidth * 0.7,
                                height: constraints.maxHeight * 0.25,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'Bienvenue',
                              style: Theme.of(
                                context,
                              ).textTheme.displayMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
                                  child: const Text('Se connecter'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/signup',
                                      ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(
                                    'S\'inscrire',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            '© 2025 Mon Application',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
