import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

class BalanceSection extends StatelessWidget {
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
                  'Rp. 1,000,000',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 8),
                Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
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

class MonthlyReportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report this month',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Melihat laporan-laporan',
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
                        '9,100,000',
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
                        'Total income',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        '20,150,000',
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
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 6,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 3),
                          FlSpot(1, 1),
                          FlSpot(2, 4),
                          FlSpot(3, 2),
                          FlSpot(4, 5),
                          FlSpot(5, 3),
                          FlSpot(6, 4),
                        ],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                            show: true, color: Colors.green.withOpacity(0.2)),
                      ),
                    ],
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
              'Lihas Semua',
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
                  title: 'Belanja', amount: 'Rp. 4,000,000', percentage: '50%'),
              SizedBox(height: 12),
              ExpenseItem(
                  title: 'Investasi',
                  amount: 'Rp. 4,000,000',
                  percentage: '50%'),
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

class Transaksi extends StatelessWidget {
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
              'Lihas Semua',
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
              ExpenseItem(
                  title: 'Belanja',
                  amount: '5 September 2024',
                  percentage: 'Rp. 4,000,000'),
              SizedBox(height: 12),
              ExpenseItem(
                  title: 'Investasi',
                  amount: '20 September 2024',
                  percentage: 'Rp. 4,000,000'),
            ],
          ),
        ),
      ],
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;

  const ExpenseItem(
      {Key? key,
      required this.title,
      required this.amount,
      required this.percentage})
      : super(key: key);

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
        Text(percentage,
            style: TextStyle(color: Color(0xFFFF2F2F), fontSize: 12)),
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
