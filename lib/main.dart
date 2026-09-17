import 'package:flutter/material.dart';
import 'package:saturn_app/auth/account.dart';
import 'package:saturn_app/auth/asset_detail.dart';
import 'package:saturn_app/auth/create_listing.dart';
import 'package:saturn_app/auth/dashboard.dart';
import 'package:saturn_app/auth/income.dart';
import 'package:saturn_app/auth/login.dart';
import 'package:saturn_app/auth/market.dart';
import 'package:saturn_app/auth/portfolio.dart';
import 'package:saturn_app/auth/register.dart';
import 'package:saturn_app/auth/secondary_asset.dart';
import 'package:saturn_app/auth/trade.dart';
import 'package:saturn_app/services/auth_service.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/welcome.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';
import 'package:saturn_app/widgets/placeholder_screen.dart';
import 'package:saturn_app/widgets/saturn_theme.dart';

void main() {
  runApp(const SaturnApp());
}

class SaturnApp extends StatelessWidget {
  const SaturnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saturn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthCheckScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/market': (context) => const MarketScreen(),
        '/portfolio': (context) => const PortfolioScreen(),
        '/activity': (context) => const PlaceholderScreen(
              title: 'Activity',
              subtitle: 'Send ActivityController + the activity Blade view and this gets wired up next.',
              bottomNav: SaturnBottomNav(currentIndex: 3),
            ),
        '/account': (context) => const AccountScreen(),
        '/income': (context) => const IncomeScreen()
      },
      // Routes that need an argument (an asset id) go through
      // onGenerateRoute instead of the simple `routes` map, which only
      // supports zero-argument builders.
      onGenerateRoute: (settings) {
        final id = settings.arguments as int?;

        switch (settings.name) {
          case '/asset':
            if (id == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Invalid Asset ID')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => AssetDetailScreen(assetId: id),
            );
          case '/trade':
            if (id == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Invalid Asset ID')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => TradeScreen(assetId: id)
            );
          case '/secondary-asset':
            if (id == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Invalid Asset ID')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => SecondaryAssetScreen(assetId: id)
            );
          case '/listing-create':
            if (id == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Invalid Asset ID')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => CreateListingScreen(assetId: id)
            );
          default:
            return null;
        }
      },
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _authService.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.midnight,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        // Logged-in user -> Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }

        // Unauthenticated -> Welcome choice screen
        return const WelcomeScreen();
      },
    );
  }
}