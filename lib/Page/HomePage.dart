import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pencatatan_keuangan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'DetailTransaksi.dart';
import 'TambahTransaksi.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _refreshData() async {
    await Future.wait([
      _balanceSectionKey.currentState?.fetchTotalBalance() ?? Future.value(),
      _monthlyReportKey.currentState?.fetchMonthlyData() ?? Future.value(),
      _transaksiKey.currentState?.fetchTransactions() ?? Future.value(),
    ]);
  }

  final GlobalKey<_BalanceSectionState> _balanceSectionKey = GlobalKey();
  final GlobalKey<_MonthlyReportSectionState> _monthlyReportKey = GlobalKey();
  final GlobalKey<_TransaksiState> _transaksiKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF252B48),
      body: SafeArea(
        child: Column(
          children: [
            AdBanner(),
            Expanded(
              child: RefreshIndicator(
                color: WarnaUtama,
                backgroundColor: WarnaSecondary,
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BalanceSection(key: _balanceSectionKey),
                        SizedBox(height: 20),
                        WalletSection(),
                        SizedBox(height: 20),
                        MonthlyReportSection(key: _monthlyReportKey),
                        SizedBox(height: 20),
                        Pengeluaran(),
                        SizedBox(height: 20),
                        Transaksi(key: _transaksiKey),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PersistentBottomNavBar(),
    );
  }
}

class AdBanner extends StatefulWidget {
  @override
  _AdBannerState createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = Platform.isAndroid
        // ? 'ca-app-pub-3940256099942544/6300978111'
        // : 'ca-app-pub-3940256099942544/2934735716';
        ? 'ca-app-pub-3564069642095127/5462088626'
        : 'ca-app-pub-3564069642095127/9209761947';

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Ad failed to load: $error');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      return Container(
        height: 60,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return SizedBox(height: 5);
    }
  }
}

class BalanceSection extends StatefulWidget {
  const BalanceSection({Key? key}) : super(key: key);

  @override
  _BalanceSectionState createState() => _BalanceSectionState();
}

class _BalanceSectionState extends State<BalanceSection> {
  final supabase = Supabase.instance.client;
  double totalBalance = 0;
  bool isBalanceVisible = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    fetchTotalBalance();
  }
  Future<void> _getUserInfo() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _username = user.userMetadata?['display_name'] ?? '';
      });
    }
  }

  Future<void> fetchTotalBalance() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('transaksi')
          .select('jenis, nilai')
          .eq('user_id', user.id);

      final transactions = List<Map<String, dynamic>>.from(response);

      double balance = 0;
      for (var transaction in transactions) {
        if (transaction['jenis'] == 'pemasukan') {
          balance += transaction['nilai'] as double;
        } else if (transaction['jenis'] == 'pengeluaran') {
          balance -= transaction['nilai'] as double;
        }
      }

      setState(() {
        totalBalance = balance;
      });
    } catch (error) {
      print('Error fetching total balance: $error');
    }
  }

  void toggleBalanceVisibility() {
    setState(() {
      isBalanceVisible = !isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, $_username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(Icons.notifications, color: Colors.white, size: 24),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Jumlah Saldo',
          style: TextStyle(
              color: Color(0xFF8E7AA9),
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              isBalanceVisible ? 'Rp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalBalance)}' : 'Rp. ***.***',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: toggleBalanceVisibility,
              child: Icon(
                isBalanceVisible ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WalletSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2F243D),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dompet Saya',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 10),
          Divider(color: Colors.grey.withOpacity(0.4)),
          SizedBox(height: 10),
          WalletItem(title: 'Tunai', amount: 'Rp. 500,000'),
          SizedBox(height: 10),
          Divider(color: Colors.grey.withOpacity(0.4)),
          SizedBox(height: 10),
          WalletItem(title: 'Kartu Kredit', amount: 'Rp. 500,000'),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  final String title;
  final String amount;

  const WalletItem({Key? key, required this.title, required this.amount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
        Text(amount, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class MonthlyReportSection extends StatefulWidget {
  const MonthlyReportSection({Key? key}) : super(key: key);

  @override
  _MonthlyReportSectionState createState() => _MonthlyReportSectionState();
}

class _MonthlyReportSectionState extends State<MonthlyReportSection> {
  final supabase = Supabase.instance.client;
  double totalPengeluaran = 0;
  double totalPemasukan = 0;
  List<FlSpot> chartData = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    fetchMonthlyData();
  }

  Future<void> fetchMonthlyData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    try {
      final response = await supabase
          .from('transaksi')
          .select()
          .eq('user_id', user.id)
          .gte('tanggal', startOfMonth.toIso8601String())
          .lte('tanggal', endOfMonth.toIso8601String());

      final transactions = List<Map<String, dynamic>>.from(response);

      double pengeluaran = 0;
      double pemasukan = 0;
      Map<int, double> dailyBalance = {};

      for (var transaction in transactions) {
        final amount = transaction['nilai'] as double;
        final date = DateTime.parse(transaction['tanggal']);
        final day = date.day;

        if (transaction['jenis'] == 'pengeluaran') {
          pengeluaran += amount;
          dailyBalance[day] = (dailyBalance[day] ?? 0) - amount;
        } else if (transaction['jenis'] == 'pemasukan') {
          pemasukan += amount;
          dailyBalance[day] = (dailyBalance[day] ?? 0) + amount;
        }
      }

      List<FlSpot> spots = [];
      double cumulativeBalance = 0;
      for (int i = 1; i <= endOfMonth.day; i++) {
        cumulativeBalance += dailyBalance[i] ?? 0;
        spots.add(FlSpot(i.toDouble(), cumulativeBalance));
      }

      setState(() {
        totalPengeluaran = pengeluaran;
        totalPemasukan = pemasukan;
        chartData = spots;
      });
    } catch (error) {
      print('Error fetching monthly data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Laporan Bulanan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F253D),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total pengeluaran',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalPengeluaran),
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total pemasukan',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalPemasukan),
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(color: Colors.grey.withOpacity(0.4)),
              SizedBox(height: 16),
              Container(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            const titles = [];
                            final index = value.toInt();
                            if (index >= 0 && index < titles.length) {
                              return Text(
                                titles[index],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            }
                            return Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}M',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 2,
                    minY: 0,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 1.5),
                          FlSpot(1, 3),
                          FlSpot(2, 2),
                        ],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 2),
                          FlSpot(1, 1.5),
                          FlSpot(2, 4),
                        ],
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.white,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;
                            return LineTooltipItem(
                              '${flSpot.y}m',
                              TextStyle(
                                color: barSpot.bar.color,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Pengeluaran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pengeluaran Teratas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F253D),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ToggleButtons(),
              SizedBox(height: 16),
              ExpenseItem(
                title: 'Belanja',
                amount: '5 September 2024',
                value: 'Rp. 4,000,000',
                isIncome: false,
              ),
              SizedBox(height: 12),
              ExpenseItem(
                title: 'Investasi',
                amount: '20 September 2024',
                value: 'Rp. 4,000,000',
                isIncome: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ToggleButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF32374F),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text('Minggu',
                  style: TextStyle(color: Color(0xFF6D759E), fontSize: 12)),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color(0xFF495071),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text('Bulan',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class Transaksi extends StatefulWidget {
  const Transaksi({Key? key}) : super(key: key);

  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<Transaksi> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('transaksi')
          .select()
          .eq('user_id', user.id)
          .order('tanggal', ascending: false); // Urutkan berdasarkan tanggal terbaru

      setState(() {
        transactions = List<Map<String, dynamic>>.from(response);
      });
    } catch (error) {
      print('Error fetching transactions: $error');
    }
  }

  void _navigateToDetailTransaksi(
      BuildContext context, Map<String, dynamic> transactionData) {
    final transaction = Transaction(
      id: transactionData['id'],
      kategori: transactionData['kategori'] ?? 'Uncategorized',
      nilai: transactionData['nilai'] ?? 0,
      jenis: transactionData['jenis'] ?? '',
      tanggal: transactionData['tanggal'] != null
          ? DateTime.parse(transactionData['tanggal'])
          : DateTime.now(),
      catatan: transactionData['catatan'] ?? '',
      imageUrl: transactionData['image_url'],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTransaksi(transaction: transaction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaksi Terkini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: WarnaSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (transactions.isNotEmpty)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2F253D),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: transactions.asMap().entries.map((entry) {
                int index = entry.key;
                var transaction = entry.value;
                String formattedDate = 'No date';
                if (transaction['tanggal'] != null) {
                  DateTime date = DateTime.parse(transaction['tanggal']);
                  formattedDate =
                      DateFormat('dd MMM yyyy', 'id_ID').format(date);
                }
                bool isIncome = transaction['jenis'] == 'pemasukan';
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _navigateToDetailTransaksi(context, transaction),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2F253D),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: ExpenseItem(
                            title: transaction['kategori'] ?? 'Uncategorized',
                            amount: formattedDate,
                            value: transaction['nilai'] != null
                                ? 'Rp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(transaction['nilai'])}'
                                : 'N/A',
                            isIncome: isIncome,
                          ),
                        ),
                      ),
                    ),
                    if (index < transactions.length - 1)
                      Divider(
                        color: Colors.white.withOpacity(0.2),
                        height: 1,
                        thickness: 1,
                      ),
                  ],
                );
              }).toList(),
            ),
          )
        else
          Center(
            child: Text(
              'Tidak ada transaksi',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
      ],
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String title;
  final String amount;
  final String value;
  final bool isIncome;

  const ExpenseItem({
    Key? key,
    required this.title,
    required this.amount,
    required this.value,
    required this.isIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 12)),
            SizedBox(height: 4),
            Text(amount,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isIncome ? Colors.green : Color(0xFFFF2F2F),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class PersistentBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF4E4062),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavBarItem(icon: Icons.home, label: 'Beranda', isSelected: true),
              NavBarItem(icon: Icons.history_outlined, label: 'Transaksi'),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WarnaSecondary,
                ),
                child: FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TambahTransaksi()),
                    );
                  },
                  child: Icon(Icons.add, color: WarnaUtama),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
              NavBarItem(icon: Icons.account_balance_wallet_rounded, label: 'Dompet'),
              NavBarItem(icon: Icons.person, label: 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
        ),
        SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}