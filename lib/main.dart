import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/themes/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/navigation_provider.dart';
import 'core/widgets/auth_wrapper.dart';
import 'core/screens/shell_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/demo/demo_screen.dart';
import 'features/templates/dynamic_template_page.dart';
import 'features/results/dynamic_results_page.dart';
import 'testing/cards_demo_screen.dart';
import 'testing/components_demo_screen.dart';
import 'testing/gemini_demo_screen.dart';
import 'testing/gif_test_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: Container(
        // Root container with solid dark background to prevent white flash
        color: const Color(0xFF141218), // Matches dark theme background
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Bloom App',
          theme: themeProvider.currentTheme,
          home: const ConditionalAuthWrapper(routeName: '/', child: ShellScreen()),
          debugShowCheckedModeBanner: false,
          routes: {
            // Public routes
            LoginScreen.routeName: (context) => const LoginScreen(),
            SignupScreen.routeName: (context) => const SignupScreen(),
            DemoScreen.routeName: (context) => const DemoScreen(),

            // Private routes - redirect to sessions list as landing page
            '/dashboard': (context) => const ConditionalAuthWrapper(routeName: '/sessions', child: ShellScreen()),

            // I think these are just demo routes
            DynamicTemplatePage.routeName: (context) => const ConditionalAuthWrapper(routeName: DynamicTemplatePage.routeName, child: DynamicTemplatePage(sessionId: 1)),
            CardsDemoScreen.routeName: (context) => const ConditionalAuthWrapper(routeName: CardsDemoScreen.routeName, child: CardsDemoScreen()),
            ComponentsDemoScreen.routeName: (context) => const ConditionalAuthWrapper(routeName: ComponentsDemoScreen.routeName, child: ComponentsDemoScreen()),
            GeminiDemoScreen.routeName: (context) => const ConditionalAuthWrapper(routeName: GeminiDemoScreen.routeName, child: GeminiDemoScreen()),
            GifTestScreen.routeName: (context) => const ConditionalAuthWrapper(routeName: GifTestScreen.routeName, child: GifTestScreen()),

          },
          onGenerateRoute: (settings) {
            // Handle dynamic routes
            final uri = Uri.parse(settings.name ?? '');

            // Handle user-specific demo routes: /demo/user/{user-id} or /demo/superadmin
            if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'demo') {
              if (uri.pathSegments.length == 2 && uri.pathSegments[1] == 'superadmin') {
                // Superadmin route - no restrictions, just show demo
                return MaterialPageRoute(
                  builder: (context) => const DemoScreen(),
                  settings: settings,
                );
              } else if (uri.pathSegments.length == 3 && uri.pathSegments[1] == 'user') {
                final userId = uri.pathSegments[2];
                // Only allow access for the specific user ID from your Supabase users table
                if (userId == 'ac1e1ecf-4244-4064-95e2-dbe6a862ac62') {
                  return MaterialPageRoute(
                    builder: (context) => const DemoScreen(),
                    settings: settings,
                  );
                } else {
                  // Return a not found page or redirect to login for unauthorized users
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                    settings: settings,
                  );
                }
              }
            }

            // Handle session results routes: /session/results/1
            // These are for facilitators, so require auth
            if (uri.pathSegments.length == 3 && uri.pathSegments[0] == 'session' && uri.pathSegments[1] == 'results') {
              final sessionIdString = uri.pathSegments[2];
              final sessionId = int.tryParse(sessionIdString);

              if (sessionId != null) {
                return MaterialPageRoute(
                  builder: (context) => ConditionalAuthWrapper(routeName: settings.name, child: DynamicResultsPage(sessionId: sessionId)),
                  settings: settings,
                );
              }
            }

            // Handle email confirmation: /auth/confirm
            if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'auth' && uri.pathSegments[1] == 'confirm') {
              // Email confirmation automatically handled by Supabase
              // Just redirect to login page
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
                settings: settings,
              );
            }

            // Handle session template routes: /session/1 or /session/ABC123
            // These are for PARTICIPANTS - NO AUTH REQUIRED
            if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'session') {
              final sessionIdOrCode = uri.pathSegments[1];
              final sessionId = int.tryParse(sessionIdOrCode);

              if (sessionId != null) {
                // Numeric session ID - direct access (no auth required)
                return MaterialPageRoute(
                  builder: (context) => DynamicTemplatePage(sessionId: sessionId),
                  settings: settings,
                );
              } else {
                // Session code - need to look up session ID (no auth required)
                return MaterialPageRoute(
                  builder: (context) => DynamicTemplatePageByCode(sessionCode: sessionIdOrCode),
                  settings: settings,
                );
              }
            }

            // Return null to let the normal route handling take over
            return null;
          },
          builder: (context, widget) {
            // Add error handling wrapper
            return widget ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
