import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/themes/theme_provider.dart';
import '../../core/themes/app_theme.dart';
import '../../core/screens/shell_screen.dart';
import '../templates/dynamic_template_page.dart';
import '../../testing/cards_demo_screen.dart';
import '../../testing/components_demo_screen.dart';
import '../../testing/gemini_demo_screen.dart';
import '../../core/themes/spacing_theme.dart';

/// Demo screen that preserves all the original home page functionality
/// This is accessed via /demo route for development and testing
class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  static const String routeName = '/demo';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloom App Demo'),
        actions: [
          PopupMenuButton<ThemeVariant>(
            icon: const Icon(Icons.palette),
            onSelected: (ThemeVariant variant) {
              themeProvider.setTheme(variant);
            },
            itemBuilder: (BuildContext context) {
              return ThemeVariant.values.map((ThemeVariant variant) {
                return PopupMenuItem<ThemeVariant>(
                  value: variant,
                  child: Row(children: [Icon(themeProvider.currentVariant == variant ? Icons.radio_button_checked : Icons.radio_button_unchecked), SizedBox(width: context.spacing.sm), Text(themeProvider.getVariantDisplayName(variant))]),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.xl),
                child: Column(
                  children: [
                    Text('Bloom App Demo', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    SizedBox(height: context.spacing.lg),
                    Text('Current theme: ${themeProvider.getVariantDisplayName(themeProvider.currentVariant)}', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.spacing.xxl),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ShellScreen()),
                );

                // If a session was created, navigate to sessions list
                if (result != null && context.mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ShellScreen()),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Session'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShellScreen()));
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading sessions: $e'), backgroundColor: Theme.of(context).colorScheme.error));
                  }
                }
              },
              icon: const Icon(Icons.list),
              label: const Text('View Sessions'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Theme.of(context).colorScheme.onSecondary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const DynamicTemplatePage(sessionId: 1)));
              },
              icon: const Icon(Icons.favorite),
              label: const Text('Check-in Template'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary, foregroundColor: Theme.of(context).colorScheme.onTertiary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(CardsDemoScreen.routeName);
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Cards'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary, foregroundColor: Theme.of(context).colorScheme.onTertiary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(ComponentsDemoScreen.routeName);
              },
              icon: const Icon(Icons.widgets),
              label: const Text('Other Components'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, foregroundColor: Theme.of(context).colorScheme.onSecondary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(GeminiDemoScreen.routeName);
              },
              icon: const Icon(Icons.psychology),
              label: const Text('Gemini AI Demo'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(height: context.spacing.lg),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/gif-test');
              },
              icon: const Icon(Icons.gif),
              label: const Text('Dynamic GIF Test'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.tertiary, foregroundColor: Theme.of(context).colorScheme.onTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
