import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pencatatan_keuangan/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math' as math;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF252B48),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdBannerSection(),
                SizedBox(height: 20),
                BalanceSection(),
                SizedBox(height: 20),
                WalletSection(),
                SizedBox(height: 20),
                MonthlyReportSection(),
                SizedBox(height: 20),
                Pengeluaran(),
                SizedBox(height: 20),
                Transaksi(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class AdBannerSection extends StatefulWidget {
  @override
  _AdBannerSectionState createState() => _AdBannerSectionState();
}

class _AdBannerSectionState extends State<AdBannerSection> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
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
        height: 50,
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return SizedBox(height: 50);
    }
  }
}

class BalanceSection extends StatefulWidget {
  @override
  _BalanceSectionState createState() => _BalanceSectionState();
}

class _BalanceSectionState extends State<BalanceSection> {
  final supabase = Supabase.instance.client;
  double totalBalance = 0;
  bool isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    fetchTotalBalance();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  isBalanceVisible ? 'Rp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(totalBalance)}' : 'Rp. ******',
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
        ),
        Icon(Icons.notifications, color: Colors.white, size: 24),
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
                height: 220, // Tinggi ditambah untuk memberi ruang pada label tanggal
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            if (value % 5 == 0) {
                              final date = DateTime(DateTime.now().year, DateTime.now().month, value.toInt());
                            }
                            return Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 1,
                    maxX: 31,
                    minY: chartData.isEmpty ? 0 : chartData.map((spot) => spot.y).reduce(math.min),
                    maxY: chartData.isEmpty ? 30000 : chartData.map((spot) => spot.y).reduce(math.max),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final flSpot = barSpot;
                            final date = DateTime(DateTime.now().year, DateTime.now().month, flSpot.x.toInt());
                            return LineTooltipItem(
                              '${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(flSpot.y)}',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: '\n${DateFormat("dd - MMM", 'id_ID').format(date)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
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
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2F253D),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: transactions.map((transaction) {
              // Ubah format tanggal di sini
              String formattedDate = 'No date';
              if (transaction['tanggal'] != null) {
                DateTime date = DateTime.parse(transaction['tanggal']);
                formattedDate = DateFormat('dd-MMM-yyyy', 'id_ID').format(date);
              }
              
              return Column(
                children: [
                  ExpenseItem(
                    title: transaction['kategori'] ?? 'Uncategorized',
                    amount: formattedDate,
                    value: transaction['nilai'] != null
                        ? 'Rp. ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(transaction['nilai'])}'
                        : 'N/A',
                    isIncome: transaction['jenis'] == 'pemasukan',
                  ),
                  SizedBox(height: 12),
                ],
              );
            }).toList(),
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

class CustomBottomNavBar extends StatefulWidget {
  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Transaksi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle),
          label: 'Tambah',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Dompet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey.withOpacity(0.8),
      onTap: _onItemTapped,
      backgroundColor: Color(0xFF4E4062),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
    );
  }
}