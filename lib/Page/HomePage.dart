import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import 'DetailTransaksi.dart';
import 'Pemasukan.dart';
import 'Pengeluaran.dart';
import '../Login Register/LoginPage.dart';

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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimationPemasukan;
  late Animation<Offset> _slideAnimationPengeluaran;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  bool _isAppBarExpanded = true;

  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _totalSaldo = 0;

  String _username = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideAnimationPemasukan = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6,
          curve: Curves.easeOutCubic),
    ));

    _slideAnimationPengeluaran = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0,
          curve: Curves.easeOutCubic),
    ));

    _ambilTransaksi();
    _hitungTotal();
    _getUserInfo();

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = true;
        });
      } else if (_scrollController.offset <= 100 && _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = false;
        });
      }

      setState(() {
        _isAppBarExpanded = _scrollController.hasClients &&
            _scrollController.offset < (200 - kToolbarHeight);
      });
    });
  }

  Future<void> _ambilTransaksi() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Pengguna belum masuk');
      }

      final response = await supabase
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

      // Tambahkan ini untuk debugging
      _transactions.forEach((transaction) {
        print('Transaction ID: ${transaction.id}, Image URL: ${transaction.imageUrl}');
      });

    } catch (e) {
      print('Kesalahan saat mengambil transaksi: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hitungTotal() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Pengguna belum masuk');
      }

      final responsePemasukan = await Supabase.instance.client
          .from('transaksi')
          .select('nilai')
          .eq('user_id', user.id)
          .eq('jenis', 'pemasukan');

      final responsePengeluaran = await Supabase.instance.client
          .from('transaksi')
          .select('nilai')
          .eq('user_id', user.id)
          .eq('jenis', 'pengeluaran');

      double totalPemasukan = (responsePemasukan as List<dynamic>)
          .fold(0, (sum, item) => sum + (item['nilai'] as num));
      double totalPengeluaran = (responsePengeluaran as List<dynamic>)
          .fold(0, (sum, item) => sum + (item['nilai'] as num));

      setState(() {
        _totalPemasukan = totalPemasukan;
        _totalPengeluaran = totalPengeluaran;
        _totalSaldo = _totalPemasukan - _totalPengeluaran;
      });
    } catch (e) {
      print('Kesalahan saat mengambil total: $e');
    }
  }

  Future<void> _getUserInfo() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '';
        _username = user.userMetadata?['username'] ?? '';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaUtama,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: _isAppBarExpanded ? WarnaUtama : WarnaSecondary,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              title: _isHeaderCollapsed ? Text('Ringkasan Keuangan') : null,
            ),
            SliverToBoxAdapter(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: WarnaSecondary))
                  : _buildTransactionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WarnaSecondary,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang, $_username',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: WarnaUtama,
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _logout(context),
            child: Text(
              'Ringkasan Keuangan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: WarnaUtama,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: SfCircularChart(
                    margin: EdgeInsets.zero,
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: [
                          ChartData('Pemasukan', _totalPemasukan, Colors.green),
                          ChartData('Pengeluaran', _totalPengeluaran, Colors.red),
                        ],
                        pointColorMapper: (ChartData data, _) => data.color,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.value,
                        innerRadius: '60%',
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFinanceSummaryItem(
                      'Pemasukan',
                      '+ Rp. ${NumberFormat('#,##0').format(_totalPemasukan)}',
                      Colors.green
                    ),
                    SizedBox(height: 10),
                    _buildFinanceSummaryItem(
                      'Pengeluaran',
                      '- Rp. ${NumberFormat('#,##0').format(_totalPengeluaran)}',
                      Colors.red
                    ),
                    SizedBox(height: 10),
                    _buildFinanceSummaryItem(
                      'Saldo',
                      'Rp. ${NumberFormat('#,##0').format(_totalSaldo)}',
                      WarnaUtama
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceSummaryItem(String label, String amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: WarnaUtama.withOpacity(0.7),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: WarnaUtama,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var transaction in _transactions) {
      String dateKey = DateFormat('dd MMM yyyy').format(transaction.tanggal);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        String dateKey = groupedTransactions.keys.elementAt(index);
        List<Transaction> dayTransactions = groupedTransactions[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ...dayTransactions
                .map((transaction) => _buildTransactionItem(transaction))
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    bool isIncome = transaction.jenis == 'pemasukan';
    Color transactionColor = isIncome ? Colors.green : Colors.red;
    IconData transactionIcon = isIncome
        ? CupertinoIcons.arrow_up_right
        : CupertinoIcons.arrow_down_right;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      color: WarnaSecondary,
      child: InkWell(  // Tambahkan ini
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTransaksi(transaction: transaction),
            ),
          );
        },
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: transactionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transactionIcon,
              color: transactionColor,
              size: 28,
            ),
          ),
          title: Text(
            transaction.kategori,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: WarnaUtama),
          ),
          subtitle: Text(
            transaction.catatan,
            style: TextStyle(color: WarnaUtama.withOpacity(0.6)),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'} Rp. ${NumberFormat('#,##0').format(transaction.nilai)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transactionColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Visibility(
              visible: _isExpanded ||
                  _animationController.status == AnimationStatus.reverse,
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
                      _ambilTransaksi();
                      _hitungTotal();
                    }
                  },
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Visibility(
              visible: _isExpanded ||
                  _animationController.status == AnimationStatus.reverse,
              child: SlideTransition(
                position: _slideAnimationPengeluaran,
                child: _buildActionButton(
                  label: 'Pengeluaran',
                  icon: CupertinoIcons.arrow_down_right,
                  color: Colors.red,
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Pengeluaran()),
                    );
                    if (result == true) {
                      _ambilTransaksi();
                      _hitungTotal();
                    }
                  },
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10),
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
          child: Icon(icon, size: 24),
          backgroundColor: color,
        ),
      ],
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
  final String? imageUrl;

  Transaction({
    required this.id,
    required this.nilai,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
    required this.jenis,
    required this.userId,
    this.imageUrl,
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
      imageUrl: json['image_url'] as String?,
    );
  }
}