import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'Pemasukan.dart';

// Add this extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimationPemasukan;
  late Animation<Offset> _slideAnimationPengeluaran;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600), // Increased duration
    );

    _slideAnimationPemasukan = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOutCubic), // Adjusted interval and curve
    ));

    _slideAnimationPengeluaran = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0, curve: Curves.easeOutCubic), // Adjusted interval and curve
    ));

    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await Supabase.instance.client
          .from('transaksi')
          .select()
          .eq('user_id', user.id)
          .order('tanggal', ascending: false);

      setState(() {
        _transactions = (response as List<dynamic>)
            .map((json) => Transaction.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaUtama,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: WarnaSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Doughnut chart
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 120,
                          child: SfCircularChart(
                            margin: EdgeInsets.zero,
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: [
                                  ChartData('Pemasukan', 50, Colors.green),
                                  ChartData('Pengeluaran', 50, Colors.red),
                                ],
                                pointColorMapper: (ChartData data, _) => data.color,
                                xValueMapper: (ChartData data, _) => data.category,
                                yValueMapper: (ChartData data, _) => data.value,
                                innerRadius: '50%',
                              )
                            ],
                          ),
                        ),
                      ),
                      // Teks pemasukan dan pengeluaran
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pemasukan: Rp. 20.000',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Pengeluaran: Rp. 20.000',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Total: Rp. 0',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Pemasukan button and label
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Visibility(
                visible: _isExpanded || _animationController.status == AnimationStatus.reverse,
                child: SlideTransition(
                  position: _slideAnimationPemasukan,
                  child: _buildActionButton(
                    label: 'Pemasukan',
                    icon: CupertinoIcons.arrow_up_right,
                    color: Colors.green,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Pemasukan()),
                      );
                      if (result == true) {
                        // Refresh the transactions list
                        _fetchTransactions();
                      }
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10),
          // Pengeluaran button and label
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Visibility(
                visible: _isExpanded || _animationController.status == AnimationStatus.reverse,
                child: SlideTransition(
                  position: _slideAnimationPengeluaran,
                  child: _buildActionButton(
                    label: 'Pengeluaran',
                    icon: CupertinoIcons.arrow_down_right,
                    color: Colors.red,
                    onPressed: () {
                      print('Pengeluaran button clicked');
                    },
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 10),
          // Main FAB
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 600),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns: animation,
                  child: child,
                );
              },
              child: _isExpanded
                  ? Icon(Icons.close, key: ValueKey('close'))
                  : Icon(Icons.add, key: ValueKey('add')),
            ),
            backgroundColor: WarnaSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 10),
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          child: Icon(icon, size: 24), // Reduced size from 36 to 24
          backgroundColor: color,
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              transaction.jenis == 'pemasukan' ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right,
              color: transaction.jenis == 'pemasukan' ? Colors.green : Colors.red,
            ),
            title: Text(
              '${transaction.jenis.capitalize()}: Rp ${NumberFormat('#,##0.00').format(transaction.nilai)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kategori: ${transaction.kategori}'),
                Text('Catatan: ${transaction.catatan}'),
                Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(transaction.tanggal)}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}

class Transaction {
  final int id;
  final double nilai;
  final String kategori;
  final String catatan;
  final DateTime tanggal;
  final String jenis;
  final String userId;

  Transaction({
    required this.id,
    required this.nilai,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
    required this.jenis,
    required this.userId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      nilai: json['nilai'].toDouble(),
      kategori: json['kategori'],
      catatan: json['catatan'],
      tanggal: DateTime.parse(json['tanggal']),
      jenis: json['jenis'],
      userId: json['user_id'],
    );
  }
}
