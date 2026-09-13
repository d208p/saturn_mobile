import 'package:flutter/material.dart';
import 'package:saturn_app/models/portfolio_service.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/widgets/app_card.dart';
import 'package:saturn_app/widgets/async_view.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';
import 'package:saturn_app/widgets/stat_tile.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Portfolio'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.slate,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Holdings'),
              Tab(text: 'Allocation'),
              Tab(text: 'Performance'),
            ],
          ),
        ),
        bottomNavigationBar: const SaturnBottomNav(currentIndex: 2),
        body: AsyncView<PortfolioData>(
          future: _future,
          onRetry: _reload,
          builder: (context, data) => TabBarView(
            children: [
              _OverviewTab(data: data),
              _HoldingsTab(data: data),
              _AllocationTab(data: data),
              const _PerformanceTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- OVERVIEW TAB ---
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data});
  final PortfolioData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StatTile(
          label: 'Portfolio value',
          value: '€${data.portfolioValue.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Invested',
                value: '€${data.investedTotal.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Available cash',
                value: '€${data.availableCash.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Portfolio risk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Moderate · 6.4 / 10', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _RiskRow(label: 'Diversification', value: 'Good', color: AppColors.green),
              const _RiskRow(label: 'Liquidity', value: 'Moderate', color: AppColors.gold),
              const _RiskRow(label: 'Asset concentration', value: 'Low', color: AppColors.green),
              const _RiskRow(label: 'Geographic exposure', value: 'Moderate', color: AppColors.gold),
              const _RiskRow(label: 'Development exposure', value: 'Low', color: AppColors.green),
              const SizedBox(height: 12),
              const Text(
                'This score reflects how your current positions are calculated to behave together — it is not a recommendation and does not guarantee any outcome.',
                style: TextStyle(color: AppColors.slate, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ],
      ),
    );
  }
}

// --- HOLDINGS TAB ---
class _HoldingsTab extends StatelessWidget {
  const _HoldingsTab({required this.data});
  final PortfolioData data;

  @override
  Widget build(BuildContext context) {
    if (data.holdings.isEmpty) {
      return const Center(
        child: Text("You don't own any equity positions yet.", style: TextStyle(color: AppColors.slate)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: data.holdings.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1),
      itemBuilder: (context, index) {
        final h = data.holdings[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            if (h.asset?.id != null) {
              Navigator.pushNamed(context, '/asset', arguments: h.asset!.id);
            }
          },
          title: Text(h.asset?.title ?? 'Unknown asset', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            '${h.asset?.category ?? 'General'} · ${h.sharesOwned} shares',
            style: const TextStyle(color: AppColors.slate),
          ),
          trailing: Text(
            '€${h.currentValue.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      },
    );
  }
}

// --- ALLOCATION TAB ---
class _AllocationTab extends StatelessWidget {
  const _AllocationTab({required this.data});
  final PortfolioData data;

  @override
  Widget build(BuildContext context) {
    final categories = data.categoryAllocation;
    final holdingsValue = data.holdingsValue;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('By asset type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 16),
              if (categories.isEmpty)
                const Text('No holdings available to calculate allocation.', style: TextStyle(color: AppColors.slate))
              else
                ...categories.entries.map((entry) {
                  final percent = holdingsValue > 0 ? ((entry.value / holdingsValue) * 100).round() : 0;
                  return _AllocationRow(label: entry.key, percent: percent);
                }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Geographic allocation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              SizedBox(height: 16),
              _AllocationRow(label: 'Romania', percent: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _AllocationRow extends StatelessWidget {
  const _AllocationRow({required this.label, required this.percent});
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text('$percent%')],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PERFORMANCE TAB ---
class _PerformanceTab extends StatelessWidget {
  const _PerformanceTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Returns by period', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              const _ReturnRow(period: '1 month', value: '+0.0%'),
              const Divider(color: AppColors.cardBorder),
              const _ReturnRow(period: '6 months', value: '+0.0%'),
              const Divider(color: AppColors.cardBorder),
              const _ReturnRow(period: '1 year', value: '+0.0%'),
              const Divider(color: AppColors.cardBorder),
              const _ReturnRow(period: 'All time', value: '+0.0%'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReturnRow extends StatelessWidget {
  const _ReturnRow({required this.period, required this.value});
  final String period;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period),
          Text(value, style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}