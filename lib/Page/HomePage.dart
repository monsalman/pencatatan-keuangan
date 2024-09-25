import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';

import '../main.dart';
import 'Pemasukan.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: WarnaUtama,
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      print('Pengeluaran button clicked');
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.arrow_down_right, size: 24, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text('Pengeluaran', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(width: 32),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Pemasukan()),);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(CupertinoIcons.arrow_up_right, size: 24, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text('Pemasukan', style: TextStyle(fontSize: 12, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
