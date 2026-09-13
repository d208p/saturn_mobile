import 'package:flutter/material.dart';
import 'package:saturn_app/models/holding.dart';
import 'package:saturn_app/models/portfolio_service.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/widgets/app_card.dart';
import 'package:saturn_app/widgets/async_view.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';
import 'package:saturn_app/widgets/stat_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = PortfolioService();
  late Future<PortfolioData> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPortfolio();
  }

  void _reload() => setState(() => _future = _service.getPortfolio());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      bottomNavigationBar: const SaturnBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        color: AppColors.gold,
        child: AsyncView<PortfolioData>(
          future: _future,
          onRetry: _reload,
          builder: (context, data) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Total portfolio value', style: TextStyle(color: AppColors.slate, fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                '€${data.portfolioValue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.ivory),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: StatTile(label: 'Invested', value: '€${data.investedTotal.toStringAsFixed(2)}')),
                  const SizedBox(width: 12),
                  Expanded(child: StatTile(label: 'Available cash', value: '€${data.availableCash.toStringAsFixed(2)}')),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Your holdings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ivory)),
              const SizedBox(height: 12),
              if (data.holdings.isEmpty)
                const AppCard(child: Text("You don't own any positions yet.", style: TextStyle(color: AppColors.slate)))
              else
                AppCard(
                  child: Column(
                    children: [for (final h in data.holdings) _HoldingRow(holding: h)],
                  ),
                ),
              const SizedBox(height: 24),
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Explore the market', style: TextStyle(fontWeight: FontWeight.w700))),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/market'),
                      child: const Text('Market'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldingRow extends StatelessWidget {
  const _HoldingRow({required this.holding});
  final Holding holding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(holding.asset?.title ?? 'Unknown asset', style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(holding.asset?.category ?? '', style: const TextStyle(color: AppColors.slate, fontSize: 12)),
              ],
            ),
          ),
          Text('€${holding.currentValue.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}