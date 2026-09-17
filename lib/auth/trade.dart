import 'package:flutter/material.dart';
import 'package:saturn_app/models/trade_data.dart';
import 'package:saturn_app/services/api_client.dart';

class TradeScreen extends StatefulWidget {
  final int assetId;
  final String initialSide; // 'buy' or 'sell'

  const TradeScreen({
    Key? key,
    required this.assetId,
    this.initialSide = 'buy',
  }) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> with SingleTickerProviderStateMixin {
  final ApiClient _client = ApiClient();
  late TabController _tabController;

  Future<TradeData>? _tradeFuture;
  // ignore: unused_field
  TradeData? _tradeData;

  final TextEditingController _buySharesController = TextEditingController(text: '1');
  final TextEditingController _sellSharesController = TextEditingController(text: '1');

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSide == 'sell' ? 1 : 0,
    );
    _fetchTradeDetails();
  }

  void _fetchTradeDetails() {
    setState(() {
      _tradeFuture = _client.get('/trade/${widget.assetId}').then((json) {
        final data = TradeData.fromJson(json as Map<String, dynamic>);
        _tradeData = data;

        // Initialize sell quantity safely
        int initialSell = data.userShares > 0 ? 1 : 0;
        _sellSharesController.text = initialSell.toString();

        return data;
      });
    });
  }

  int _clampValue(int val, int maxVal) {
    if (maxVal <= 0) return 0;
    if (val < 1) return 1;
    if (val > maxVal) return maxVal;
    return val;
  }

  Future<void> _executeTrade(String side) async {
    final sharesText = side == 'buy' ? _buySharesController.text : _sellSharesController.text;
    final shares = int.tryParse(sharesText) ?? 0;

    if (shares <= 0) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _client.post(
        '/trade/${widget.assetId}',
        body: {
          'side': side,
          'shares': shares,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Order executed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _fetchTradeDetails();
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
    _tabController.dispose();
    _buySharesController.dispose();
    _sellSharesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Asset'),
      ),
      body: FutureBuilder<TradeData>(
        future: _tradeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading trade info: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchTradeDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Asset trade details unavailable.'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tab Selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.amber[700],
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey[600],
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: 'Buy'),
                              Tab(text: 'Sell'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tab Content
                        SizedBox(
                          height: 380,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // BUY PANEL
                              _buildTradeForm(
                                side: 'buy',
                                assetTitle: data.asset.title,
                                subtitle: 'Secondary market listing',
                                primaryRowLabel: 'Price',
                                primaryRowValue: '€${data.asset.sharePrice.toStringAsFixed(2)} / unit',
                                secondaryRowLabel: 'Available',
                                secondaryRowValue: '${data.asset.availableShares} units',
                                controller: _buySharesController,
                                maxShares: data.asset.availableShares,
                                pricePerShare: data.asset.sharePrice,
                                estimateLabel: 'Estimated total',
                                buttonText: 'Buy',
                                isDisabled: data.asset.availableShares < 1 || data.asset.status != 'active',
                              ),

                              // SELL PANEL
                              _buildTradeForm(
                                side: 'sell',
                                assetTitle: data.asset.title,
                                subtitle: 'List units from your position for sale',
                                primaryRowLabel: 'Your position',
                                primaryRowValue: '${data.userShares} units',
                                secondaryRowLabel: 'Current market price',
                                secondaryRowValue: '€${data.asset.sharePrice.toStringAsFixed(2)}',
                                controller: _sellSharesController,
                                maxShares: data.userShares,
                                pricePerShare: data.asset.sharePrice,
                                estimateLabel: 'Estimated proceeds',
                                buttonText: 'List for sale',
                                isDisabled: data.userShares < 1,
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32),
                        Text(
                          'Prices shown reflect the last matched trade, not a guaranteed execution price.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTradeForm({
    required String side,
    required String assetTitle,
    required String subtitle,
    required String primaryRowLabel,
    required String primaryRowValue,
    required String secondaryRowLabel,
    required String secondaryRowValue,
    required TextEditingController controller,
    required int maxShares,
    required double pricePerShare,
    required String estimateLabel,
    required String buttonText,
    required bool isDisabled,
  }) {
    final currentQty = int.tryParse(controller.text) ?? 0;
    final estimatedTotal = currentQty * pricePerShare;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assetTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        _ListRow(label: primaryRowLabel, value: primaryRowValue),
        const SizedBox(height: 8),
        _ListRow(label: secondaryRowLabel, value: secondaryRowValue),
        const SizedBox(height: 16),

        const Text('Quantity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),

        // Stepper Control
        Row(
          children: [
            _StepperButton(
              icon: Icons.remove,
              onPressed: isDisabled || currentQty <= 1
                  ? null
                  : () {
                      int newQty = _clampValue(currentQty - 1, maxShares);
                      setState(() => controller.text = newQty.toString());
                    },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                enabled: !isDisabled,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  int parsed = int.tryParse(val) ?? 0;
                  int clamped = _clampValue(parsed, maxShares);
                  setState(() {
                    if (val.isNotEmpty && parsed != clamped) {
                      controller.text = clamped.toString();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            _StepperButton(
              icon: Icons.add,
              onPressed: isDisabled || currentQty >= maxShares
                  ? null
                  : () {
                      int newQty = _clampValue(currentQty + 1, maxShares);
                      setState(() => controller.text = newQty.toString());
                    },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Estimated Amount Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(estimateLabel, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              Text(
                '€${estimatedTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isDisabled || _isSubmitting ? null : () => _executeTrade(side),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  final String label;
  final String value;

  const _ListRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Icon(icon, size: 20),
    );
  }
}