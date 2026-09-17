import 'package:flutter/material.dart';
import 'package:saturn_app/models/assets.dart';
import 'package:saturn_app/services/market_service.dart';
import 'package:saturn_app/models/sellorder.dart';
import 'package:saturn_app/theme/colors.dart';
import 'package:saturn_app/widgets/app_card.dart';
import 'package:saturn_app/widgets/async_view.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _service = MarketService();
  late Future<MarketData> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMarket();
  }

  void _reload() => setState(() => _future = _service.getMarket());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Market'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.slate,
            tabs: [
              Tab(text: 'Discover'),
              Tab(text: 'New Projects'),
              Tab(text: 'Secondary Market'),
              Tab(text: 'Watchlist'),
              Tab(text: 'My Listings'),
            ],
          ),
        ),
        bottomNavigationBar: const SaturnBottomNav(currentIndex: 1),
        body: AsyncView<MarketData>(
          future: _future,
          onRetry: _reload,
          builder: (context, data) => TabBarView(
            children: [
              const _DiscoverTab(),
              _NewProjectsTab(assets: data.newProjects),
              _SecondaryMarketTab(assets: data.secondaryAssets),
              _WatchlistTab(assets: data.watchlist),
              _MyListingsTab(listings: data.userListings, onChanged: _reload),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DISCOVER TAB ---
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  static const _categories = [
    {
      'tag': 'Hospitality',
      'title': 'Hotel positions',
      'desc': 'Operating hotels with established occupancy and revenue history.'
    },
    {
      'tag': 'Energy',
      'title': 'Solar & wind',
      'desc': 'Long-term power purchase agreements with predictable output.'
    },
    {
      'tag': 'Agriculture',
      'title': 'Vineyards & orchards',
      'desc': 'Land-backed assets with seasonal, harvest-linked cash flow.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Trending categories',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        for (final c in _categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c['tag']!.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.slate,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(c['title']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(c['desc']!, style: const TextStyle(color: AppColors.slate, fontSize: 13)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// --- NEW PROJECTS TAB ---
class _NewProjectsTab extends StatelessWidget {
  const _NewProjectsTab({required this.assets});
  final List<Asset> assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('No new projects available.', style: TextStyle(color: AppColors.slate)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final a = assets[index];
        final totalValuation = a.totalValuation ?? 0.0;
        final fundedAmount = (a.totalShares != null && a.availableShares != null)
            ? (a.totalShares! - a.availableShares!) * a.sharePrice
            : 0.0;
        final progress = totalValuation > 0 ? (fundedAmount / totalValuation).clamp(0.0, 1.0) : 0.0;
        final percentFormatted = (progress * 100).round();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(a.category ?? 'General', style: const TextStyle(color: AppColors.slate, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (a.status != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        a.status![0].toUpperCase() + a.status!.substring(1),
                        style: const TextStyle(color: AppColors.slate, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Raised €${fundedAmount.toStringAsFixed(2)} of €${totalValuation.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.slate, fontSize: 12),
                  ),
                  Text('$percentFormatted%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.cardBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Share Price', style: TextStyle(color: AppColors.slate, fontSize: 11)),
                          Text('€${a.sharePrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Available Shares', style: TextStyle(color: AppColors.slate, fontSize: 11)),
                          Text('${a.availableShares ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/trade', arguments: a.id),
                    child: const Text('Invest'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- SECONDARY MARKET TAB ---
class _SecondaryMarketTab extends StatelessWidget {
  const _SecondaryMarketTab({required this.assets});
  final List<Asset> assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('No active secondary market listings available.', style: TextStyle(color: AppColors.slate)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final a = assets[index];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(
                          'Category: ${a.category ?? 'General'} · ${a.activeListingsCount ?? 0} Active Seller Offer(s)',
                          style: const TextStyle(color: AppColors.slate, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Secondary Market', style: TextStyle(fontSize: 11, color: AppColors.slate)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Starting From', style: TextStyle(color: AppColors.slate, fontSize: 11)),
                          Text(
                            '€${(a.minPrice ?? 0.0).toStringAsFixed(2)} / share',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Units Available', style: TextStyle(color: AppColors.slate, fontSize: 11)),
                          Text('${a.totalSecondaryShares ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/secondary-asset', arguments: a.id),
                    child: const Text(style: TextStyle(fontSize: 11), 'View Market & Buy'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- WATCHLIST TAB ---
class _WatchlistTab extends StatelessWidget {
  const _WatchlistTab({required this.assets});
  final List<Asset> assets;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(child: Text('Your watchlist is currently empty.', style: TextStyle(color: AppColors.slate)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: assets.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1),
      itemBuilder: (context, index) {
        final a = assets[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('€${a.sharePrice.toStringAsFixed(2)} / unit', style: const TextStyle(color: AppColors.slate)),
        );
      },
    );
  }
}

// --- MY LISTINGS TAB ---
class _MyListingsTab extends StatefulWidget {
  const _MyListingsTab({required this.listings, required this.onChanged});
  final List<SellOrder> listings;
  final VoidCallback onChanged;

  @override
  State<_MyListingsTab> createState() => _MyListingsTabState();
}

class _MyListingsTabState extends State<_MyListingsTab> {
  final _service = MarketService();
  int? _cancellingId;

  Future<void> _cancel(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Listing'),
        content: const Text('Are you sure you want to cancel this listing? The shares will be returned to your portfolio.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _cancellingId = id);
    try {
      await _service.cancelListing(id);
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not cancel listing: $e')));
      }
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listings.isEmpty) {
      return const Center(child: Text('You have no active or previous listings.', style: TextStyle(color: AppColors.slate)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.listings.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1),
      itemBuilder: (context, index) {
        final listing = widget.listings[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(listing.asset?.title ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(
            '${listing.shares} units · €${listing.pricePerShare.toStringAsFixed(2)} / unit',
            style: const TextStyle(color: AppColors.slate, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: listing.status == 'active' ? AppColors.green.withOpacity(0.15) : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  listing.status[0].toUpperCase() + listing.status.substring(1),
                  style: TextStyle(
                    color: listing.status == 'active' ? AppColors.green : AppColors.slate,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (listing.status == 'active') ...[
                const SizedBox(width: 8),
                _cancellingId == listing.id
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red),
                      )
                    : TextButton(
                        onPressed: () => _cancel(listing.id),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.red)),
                      ),
              ]
            ],
          ),
        );
      },
    );
  }
}