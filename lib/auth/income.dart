import 'package:flutter/material.dart';
import 'package:saturn_app/models/income_data.dart';
import 'package:saturn_app/services/api_client.dart';
import 'package:saturn_app/widgets/bottom_nav_bar.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _client = ApiClient();
  Future<IncomeData>? _incomeFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchIncomeData();
  }

  void _fetchIncomeData() {
    setState(() {
      _incomeFuture = _client.get('/income').then((data) {
        return IncomeData.fromJson(data as Map<String, dynamic>);
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext meContext) {
    final currentYear = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Distributions'),
            Tab(text: 'Cash Flow'),
          ],
        ),
      ),
      bottomNavigationBar: const SaturnBottomNav(currentIndex: 3),
      body: FutureBuilder<IncomeData>(
        future: _incomeFuture,
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
                    onPressed: _fetchIncomeData,
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No income data available.'));
          }

          final data = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              // Distributions Tab
              RefreshIndicator(
                onRefresh: () async => _fetchIncomeData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stat Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total income ($currentYear)',
                              value: '€${data.totalIncome.toStringAsFixed(2)}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              label: 'Average monthly income',
                              value:
                                  '€${data.averageMonthlyIncome.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bar Chart Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly income · $currentYear',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 160,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: data.chartData.map((bar) {
                                    return Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '€${bar.value.toInt()}',
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width: 18,
                                                height: (120 * (bar.height / 100)),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                    top: Radius.circular(4),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            bar.label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Upcoming Distributions Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upcoming distributions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              if (data.upcomingDistributions.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'No upcoming distributions scheduled.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              else
                                ...data.upcomingDistributions.map((dist) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dist.assetName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Scheduled payout · ${dist.date}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '€${dist.payout.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Cash Flow Tab
              RefreshIndicator(
                onRefresh: () async => _fetchIncomeData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Available balance',
                          value: '€${data.balance.toStringAsFixed(2)}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Income ($currentYear)',
                          value: '+€${data.totalIncome.toStringAsFixed(2)}',
                          valueColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'Fees ($currentYear)',
                          value: '-€0.00',
                          valueColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}