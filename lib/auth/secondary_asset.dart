import 'package:flutter/material.dart';
import 'package:saturn_app/models/secondary_market_data.dart';
import 'package:saturn_app/services/api_client.dart';

class SecondaryAssetScreen extends StatefulWidget {
  final int assetId;

  const SecondaryAssetScreen({Key? key, required this.assetId}) : super(key: key);

  @override
  State<SecondaryAssetScreen> createState() => _SecondaryAssetScreenState();
}

class _SecondaryAssetScreenState extends State<SecondaryAssetScreen> {
  final ApiClient _client = ApiClient();
  final TextEditingController _sharesController = TextEditingController(text: '1');
  
  Future<SecondaryMarketData>? _marketFuture;
  SecondaryMarketData? _marketData;

  double _subtotal = 0.0;
  double _platformFee = 0.0;
  double _totalCost = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchMarketListings();
  }

  void _fetchMarketListings() {
    setState(() {
      _marketFuture = _client.get('/secondary/asset/${widget.assetId}').then((json) {
        final data = SecondaryMarketData.fromJson(json as Map<String, dynamic>);
        _marketData = data;
        _recalculateOrderBook();
        return data;
      });
    });
  }

  void _recalculateOrderBook() {
    if (_marketData == null) return;

    int requestedShares = int.tryParse(_sharesController.text) ?? 0;
    double currentSubtotal = 0.0;

    for (var listing in _marketData!.listings) {
      if (requestedShares <= 0) break;
      int take = requestedShares < listing.shares ? requestedShares : listing.shares;
      currentSubtotal += take * listing.pricePerShare;
      requestedShares -= take;
    }

    double fee = currentSubtotal * 0.033;
    double total = currentSubtotal + fee;

    setState(() {
      _subtotal = currentSubtotal;
      _platformFee = fee;
      _totalCost = total;
    });
  }

  Future<void> _executePurchase() async {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    if (shares <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _client.post(
        '/secondary/asset/${widget.assetId}/buy',
        body: {
          'shares': shares,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Purchase completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _fetchMarketListings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _sharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Listings'),
      ),
      body: FutureBuilder<SecondaryMarketData>(
        future: _marketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading listings: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchMarketListings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No asset listings available.'));
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _fetchMarketListings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.asset.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    data.asset.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Order Execution Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buy Shares', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Cheapest available listings are automatically matched first.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _sharesController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantity to Buy',
                              helperText: 'Max available: ${data.totalAvailableShares} units',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) => _recalculateOrderBook(),
                          ),
                          const SizedBox(height: 16),

                          // Price Breakdown Container
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _CostRow(
                                  label: 'Subtotal',
                                  value: '€${_subtotal.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 6),
                                _CostRow(
                                  label: 'Platform Fee (3.3%)',
                                  value: '€${_platformFee.toStringAsFixed(2)}',
                                ),
                                const Divider(),
                                _CostRow(
                                  label: 'Total Cost',
                                  value: '€${_totalCost.toStringAsFixed(2)}',
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting || data.totalAvailableShares == 0
                                  ? null
                                  : _executePurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Buy Now', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Order Book Listings Table
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Market Listings', style: Theme.of(context).textTheme.titleMedium),
                              Text('Sorted by lowest price', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (data.listings.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text('No listings currently available for this asset.', style: TextStyle(color: Colors.grey)),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.listings.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final listing = data.listings[index];
                                final isCheapest = index == 0;

                                return Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  color: isCheapest ? Colors.amber.withOpacity(0.08) : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(listing.sellerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                if (isCheapest) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[100],
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      'Cheapest',
                                                      style: TextStyle(fontSize: 10, color: Colors.green[900], fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            Text(
                                              '${listing.shares} units available',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '€${listing.pricePerShare.toStringAsFixed(2)} / unit',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800]),
                                          ),
                                          Text(
                                            'Subtotal: €${listing.subtotal.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
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

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _CostRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.amber[800] : Colors.black,
          ),
        ),
      ],
    );
  }
}