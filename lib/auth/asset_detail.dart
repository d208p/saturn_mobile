import 'package:flutter/material.dart';
import 'package:saturn_app/models/asset_detail_data.dart';
import 'package:saturn_app/services/api_client.dart';

class AssetDetailScreen extends StatefulWidget {
  final int assetId;

  const AssetDetailScreen({Key? key, required this.assetId}) : super(key: key);

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final ApiClient _client = ApiClient();
  Future<AssetDetailData>? _assetFuture;
  String _selectedRange = '1Y';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchAssetData();
  }

  void _fetchAssetData() {
    setState(() {
      _assetFuture = _client.get('/asset/${widget.assetId}').then((json) {
        final data = AssetDetailData.fromJson(json as Map<String, dynamic>);
        _isFavorite = data.asset.isFavorited;
        return data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Detail'),
      ),
      body: FutureBuilder<AssetDetailData>(
        future: _assetFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading asset: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchAssetData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Asset non-existent or deleted.'));
          }

          final data = snapshot.data!;
          final asset = data.asset;
          final holding = data.holding;

          return RefreshIndicator(
            onRefresh: () async => _fetchAssetData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header & Favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          asset.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    '${asset.location} · ${asset.category}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  // Header Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: '€${asset.totalValuation.toStringAsFixed(0)} asset value',
                        backgroundColor: Colors.grey[200]!,
                        textColor: Colors.black,
                      ),
                      _Badge(
                        label: '${asset.targetYield.toStringAsFixed(1)}% target yield',
                        backgroundColor: Colors.grey[200]!,
                        textColor: Colors.black,
                      ),
                      _Badge(
                        label: '+${asset.totalReturn.toStringAsFixed(1)}% total return',
                        backgroundColor: Colors.green[50]!,
                        textColor: Colors.green[800]!,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Unit Price Chart Placeholder Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Unit price',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: ['1M', '6M', '1Y', 'ALL'].map((range) {
                                  final isActive = _selectedRange == range;
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: ChoiceChip(
                                      label: Text(range, style: const TextStyle(fontSize: 10)),
                                      selected: isActive,
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedRange = range);
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.grey[100],
                            alignment: Alignment.center,
                            child: Icon(Icons.show_chart, size: 64, color: Colors.amber[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Position Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your position',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'Units owned', value: holding.unitsOwned.toStringAsFixed(0)),
                          _DetailRow(label: 'Current value', value: '€${holding.currentValue.toStringAsFixed(2)}'),
                          _DetailRow(label: 'Avg. purchase price', value: '€${holding.avgPurchasePrice.toStringAsFixed(2)}'),
                          _DetailRow(label: 'Current price', value: '€${asset.sharePrice.toStringAsFixed(2)}'),
                          _DetailRow(
                            label: 'Unrealized gain',
                            value: '${holding.unrealizedGain >= 0 ? '+' : ''}€${holding.unrealizedGain.toStringAsFixed(2)}',
                            valueColor: holding.unrealizedGain >= 0 ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/trade',
                                      arguments: widget.assetId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber[700],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Buy'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/listing-create',
                                      arguments: widget.assetId,
                                    );
                                  },
                                  child: const Text('Sell'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('About this asset', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(
                            asset.description,
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Asset Performance Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Asset performance', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _DetailRow(label: 'Revenue (TTM)', value: '€${asset.revenueTtm.toStringAsFixed(0)}'),
                          _DetailRow(label: 'Occupancy', value: '${asset.occupancyRate.toStringAsFixed(0)}%'),
                          _DetailRow(
                            label: 'NOI',
                            value: '€${asset.noi.toStringAsFixed(0)}',
                            valueColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Distribution History
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distribution history', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          if (data.distributions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No distribution history found.', style: TextStyle(color: Colors.grey)),
                            )
                          else
                            ...data.distributions.map((dist) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(dist.date, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(dist.type, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                    Text('€${dist.amountPerShare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Liquidity Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Liquidity', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          _Badge(
                            label: 'High',
                            backgroundColor: Colors.green[50]!,
                            textColor: Colors.green[800]!,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Available units on secondary market: ${asset.availableShares}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}