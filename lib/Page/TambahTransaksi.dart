import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../main.dart';
import '../services/notification_service.dart';

class TaambahTransaksi extends StatefulWidget {
  @override
  _TaambahTransaksiState createState() => _TaambahTransaksiState();
}

class _TaambahTransaksiState extends State<TaambahTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final _kontrolerNilai = TextEditingController();
  final _kontrolerCatatan = TextEditingController();
  final _kontrolerKategori = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  String _selectedTransactionType = 'pemasukan';

  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: WarnaSecondary,
              surface: WarnaUtama,
            ),
            dialogBackgroundColor: Color(0xFF2F3855),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: WarnaSecondary,
              ),
            ),
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF252B48),
      appBar: AppBar(
        title: Text('Input Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF252B48),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTransactionTypeSelector(),
                SizedBox(height: 16),
                _buildAmountInput(),
                SizedBox(height: 16),
                _buildCategoryInput(),
                SizedBox(height: 16),
                _buildNoteInput(),
                SizedBox(height: 16),
                _buildDatePicker(context),
                SizedBox(height: 16),
                _buildImagePicker(),
                SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2F3855),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTransactionType = 'pemasukan'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTransactionType == 'pemasukan' ? Color(0xFF4E9F3D) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Pemasukan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTransactionType == 'pemasukan' ? Colors.white : Color(0xFFADB5BD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTransactionType = 'pengeluaran'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTransactionType == 'pengeluaran' ? Colors.red : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Pengeluaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTransactionType == 'pengeluaran' ? Colors.white : Color(0xFFADB5BD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2F3855),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _kontrolerNilai,
        style: TextStyle(color: Colors.white),
        cursorColor: WarnaSecondary,
        decoration: InputDecoration(
          labelText: 'Nilai',
          labelStyle: TextStyle(color: Color(0xFFADB5BD)),
          prefixText: 'Rp. ',
          prefixStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
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
    );
  }

  Widget _buildCategoryInput() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2F3855),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _kontrolerKategori,
        style: TextStyle(color: Colors.white),
        cursorColor: WarnaSecondary,
        decoration: InputDecoration(
          labelText: 'Kategori',
          labelStyle: TextStyle(color: Color(0xFFADB5BD)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2F3855),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: _kontrolerCatatan,
        style: TextStyle(color: Colors.white),
        cursorColor: WarnaSecondary,
        decoration: InputDecoration(
          labelText: 'Catatan',
          labelStyle: TextStyle(color: Color(0xFFADB5BD)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        maxLines: 3,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2F3855),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          'Tanggal',
          style: TextStyle(color: Color(0xFFADB5BD)),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
          style: TextStyle(color: Colors.white),
        ),
        trailing: Icon(Icons.calendar_today, color: Colors.white),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFF252B48),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFFADB5BD), width: 1),
              ),
              child: _image == null
                  ? Icon(Icons.add, color: Color(0xFFADB5BD), size: 40)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_image!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _image == null ? 'Pilih gambar' : path.basename(_image!.path),
            style: TextStyle(color: Color(0xFFADB5BD)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      child: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : Text(
              'Simpan',
              style: TextStyle(color: WarnaUtama),
            ),
      style: ElevatedButton.styleFrom(
        backgroundColor: WarnaSecondary,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = supabase.auth.currentUser;
        if (user == null) {
          throw Exception('Pengguna belum login');
        }

        String? imageUrl;
        if (_image != null) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_image!.path)}';
          final bytes = await _image!.readAsBytes();
          await supabase.storage
              .from('transaction_images')
              .uploadBinary(fileName, bytes);
          imageUrl = fileName;
          print('Saved Image URL: $imageUrl');
        }

        final response = await supabase.from('transaksi').insert({
          'nilai': double.parse(_kontrolerNilai.text),
          'kategori': _kontrolerKategori.text,
          'catatan': _kontrolerCatatan.text,
          'tanggal': _selectedDate.toIso8601String(),
          'jenis': _selectedTransactionType,
          'user_id': user.id,
          'image_url': imageUrl,
        });

        await NotificationService().showTransactionNotification(
          title: 'Transaksi Berhasil',
          body: 'Pemasukan sebesar Rp. ${_kontrolerNilai.text} telah disimpan.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan oleh ${user.email}')),
        );
        
        // Return to HomePage and trigger refresh
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _kontrolerNilai.dispose();
    _kontrolerCatatan.dispose();
    _kontrolerKategori.dispose();
    super.dispose();
  }
}