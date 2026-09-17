import 'package:flutter/material.dart';
import 'package:saturn_app/models/create_listing_data.dart';
import 'package:saturn_app/services/api_client.dart';

class CreateListingScreen extends StatefulWidget {
  final int assetId;

  const CreateListingScreen({Key? key, required this.assetId}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final ApiClient _client = ApiClient();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _sharesController = TextEditingController(text: '1');
  final TextEditingController _priceController = TextEditingController();

  Future<CreateListingData>? _dataFuture;
  // ignore: unused_field
  CreateListingData? _data;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchListingDetails();
  }

  void _fetchListingDetails() {
    setState(() {
      _dataFuture = _client.get('/listings/create/${widget.assetId}').then((json) {
        final data = CreateListingData.fromJson(json as Map<String, dynamic>);
        _data = data;
        _priceController.text = data.sharePrice.toStringAsFixed(2);
        return data;
      });
    });
  }

  double get _totalListingValue {
    final shares = int.tryParse(_sharesController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    return shares * price;
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await _client.post(
        '/listings/store/${widget.assetId}',
        body: {
          'shares': int.parse(_sharesController.text),
          'price_per_share': double.parse(_priceController.text),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Listing created!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
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
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Asset for Sale'),
      ),
      body: FutureBuilder<CreateListingData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchListingDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || (snapshot.data?.userShares ?? 0) < 1) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'You do not own any shares of this asset available for listing.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'List Shares for Sale',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set your desired price and quantity to list on the secondary market.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Asset Overview Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Asset Name', value: data.assetTitle, isBold: true),
                          const Divider(),
                          _InfoRow(label: 'Your Total Position', value: '${data.userShares} units'),
                          const Divider(),
                          _InfoRow(
                            label: 'Primary Share Price',
                            value: '€${data.sharePrice.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Field
                  TextFormField(
                    controller: _sharesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity to List',
                      helperText: 'Maximum available: ${data.userShares} units',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      final parsed = int.tryParse(val ?? '');
                      if (parsed == null || parsed < 1) {
                        return 'Enter a valid number of shares';
                      }
                      if (parsed > data.userShares) {
                        return 'Cannot exceed available units (${data.userShares})';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Ask Price per Share (€)',
                      helperText: 'Set any custom price unit for the secondary market',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid price greater than 0';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),

                  // Dynamic Summary Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Units to sell',
                          value: _sharesController.text.isEmpty ? '0' : _sharesController.text,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Price per unit',
                          value: '€${(double.tryParse(_priceController.text) ?? 0.0).toStringAsFixed(2)}',
                        ),
                        const Divider(height: 20),
                        _SummaryRow(
                          label: 'Total Listing Value',
                          value: '€${_totalListingValue.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitListing,
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
                          : const Text('Publish Listing', style: TextStyle(fontWeight: FontWeight.bold)),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
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