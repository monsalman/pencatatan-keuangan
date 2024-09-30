import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../notification_service.dart';

class Pengeluaran extends StatefulWidget {
  @override
  _PengeluaranState createState() => _PengeluaranState();
}

class _PengeluaranState extends State<Pengeluaran> {
  final _formKey = GlobalKey<FormState>();
  final _kontrolerNilai = TextEditingController();
  final _kontrolerCatatan = TextEditingController();
  final _kontrolerKategori = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: WarnaUtama),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _kontrolerNilai,
                cursorColor: WarnaSecondary,
                decoration: InputDecoration(
                  labelText: 'Nilai',
                  prefixText: 'Rp. ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.monetization_on, color: WarnaUtama),
                  labelStyle: TextStyle(color: WarnaUtama),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (nilai) {
                  if (nilai == null || nilai.isEmpty) {
                    return 'Mohon masukkan nilai';
                  }
                  if (double.tryParse(nilai) == null) {
                    return 'Mohon masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _kontrolerKategori,
                cursorColor: WarnaSecondary,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.note, color: WarnaUtama),
                  labelStyle: TextStyle(color: WarnaUtama),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _kontrolerCatatan,
                cursorColor: WarnaSecondary,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: WarnaUtama, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.note, color: WarnaUtama),
                  labelStyle: TextStyle(color: WarnaUtama),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                maxLines: 1,
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: WarnaUtama),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: WarnaUtama, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.calendar_today, color: WarnaUtama),
                    labelStyle: TextStyle(color: WarnaUtama),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Batal',
                        style: TextStyle(color: WarnaUtama),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final user = supabase.auth.currentUser;
                            if (user == null) {
                              throw Exception('Pengguna belum login');
                            }
                            final response = await supabase.from('transaksi').insert({
                              'nilai': double.parse(_kontrolerNilai.text),
                              'kategori': _kontrolerKategori.text,
                              'catatan': _kontrolerCatatan.text,
                              'tanggal': _selectedDate.toIso8601String(),
                              'jenis': 'pengeluaran',
                              'user_id': user.id,
                            });

                            // Tampilkan notifikasi transaksi
                            await NotificationService().showTransactionNotification(
                              title: 'Transaksi Berhasil',
                              body: 'Pengeluaran sebesar Rp. ${_kontrolerNilai.text} telah disimpan.',
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Data berhasil disimpan oleh ${user.email}')),
                            );
                            // Return to HomePage and refresh
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan data: $e')),
                            );
                          }
                        }
                      },
                      child: Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WarnaUtama,
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.5),
                      ),
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

  @override
  void dispose() {
    _kontrolerNilai.dispose();
    _kontrolerCatatan.dispose();
    _kontrolerKategori.dispose();
    super.dispose();
  }
}
