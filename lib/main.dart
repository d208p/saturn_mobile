import 'package:flutter/material.dart';
import 'package:saturn_app/auth/dashboard.dart';
import 'package:saturn_app/auth/login.dart';
import 'package:saturn_app/auth/market.dart';
import 'package:saturn_app/auth/portfolio.dart';
import 'package:saturn_app/auth/register.dart';
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
        '/account': (context) => const PlaceholderScreen(
              title: 'Account',
              subtitle: 'AccountController already exists on the backend — send its Blade view and '
                  'this becomes Profile / Verification / Bank / Security / Documents tabs.',
              bottomNav: SaturnBottomNav(currentIndex: 4),
            ),
        '/income': (context) => const PlaceholderScreen(
              title: 'Income',
              subtitle: 'Send IncomeController + the income Blade view to wire this up.',
            ),
      },
      // Routes that need an argument (an asset id) go through
      // onGenerateRoute instead of the simple `routes` map, which only
      // supports zero-argument builders.
      onGenerateRoute: (settings) {
        final id = settings.arguments as int?;

        switch (settings.name) {
          case '/asset':
            return MaterialPageRoute(
              builder: (_) => PlaceholderScreen(
                title: 'Asset',
                subtitle: id != null
                    ? 'Asset #$id — send AssetController + asset.blade.php to build this out.'
                    : 'Send AssetController + asset.blade.php to build this out.',
              ),
            );
          case '/trade':
            return MaterialPageRoute(
              builder: (_) => PlaceholderScreen(
                title: 'Trade',
                subtitle: id != null
                    ? 'Trading asset #$id — send TradeController + trade.blade.php to build this out.'
                    : 'Send TradeController + trade.blade.php to build this out.',
              ),
            );
          case '/secondary-asset':
            return MaterialPageRoute(
              builder: (_) => PlaceholderScreen(
                title: 'Secondary Market',
                subtitle: id != null
                    ? 'Listings for asset #$id — send SecondaryMarketController to build this out.'
                    : 'Send SecondaryMarketController to build this out.',
              ),
            );
          case '/listing-create':
            return MaterialPageRoute(
              builder: (_) => PlaceholderScreen(
                title: 'List for Sale',
                subtitle: id != null
                    ? 'Listing asset #$id for sale — send ListingController to build this out.'
                    : 'Send ListingController to build this out.',
              ),
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