import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'HomePage.dart';

class DetailTransaksi extends StatelessWidget {
  final Transaction transaction;

  DetailTransaksi({required this.transaction});

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.jenis == 'pemasukan';
    Color transactionColor = isIncome ? Colors.green : Colors.red;
    IconData transactionIcon = isIncome
        ? CupertinoIcons.arrow_up_right
        : CupertinoIcons.arrow_down_right;

    // Get current user
    final User? currentUser = supabase.auth.currentUser;

    return Scaffold(
      backgroundColor: WarnaUtama,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(transaction.kategori),
              background: Container(
                color: transactionColor,
                child: Center(
                  child: Icon(
                    transactionIcon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'} Rp. ${NumberFormat('#,##0').format(transaction.nilai)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: transactionColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetailItem(Icons.category, 'Kategori', transaction.kategori),
                    _buildDetailItem(Icons.calendar_today, 'Tanggal', DateFormat('dd MMMM yyyy').format(transaction.tanggal)),
                    _buildDetailItem(Icons.note, 'Catatan', transaction.catatan),
                    _buildDetailItem(Icons.account_balance_wallet, 'Jenis', transaction.jenis.toLowerCase()),
                    if (currentUser != null)
                      _buildDetailItem(Icons.person, 'Pengguna', currentUser.email ?? 'Unknown'),
                    if (transaction.imageUrl != null && transaction.imageUrl!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        'Bukti Transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: WarnaUtama,
                        ),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder<String>(
                        future: getSignedUrl(transaction.imageUrl!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text('Gagal memuat gambar'),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: WarnaUtama, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: WarnaUtama,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDecodedUrl(String url) {
    try {
      return Uri.decodeFull(url);
    } catch (e) {
      return url;  // Jika gagal decode, kembalikan URL asli
    }
  }

  Future<String> getSignedUrl(String path) async {
    try {
      final response = await supabase.storage
          .from('transaction_images')
          .createSignedUrl(path, 60 * 60); // URL valid selama 1 jam
      return response;
    } catch (e) {
      print('Error getting signed URL: $e');
      return path;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}