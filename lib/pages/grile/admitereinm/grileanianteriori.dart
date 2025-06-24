import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrileAniAnterioriPage extends StatefulWidget {
  const GrileAniAnterioriPage({Key? key}) : super(key: key);

  @override
  State<GrileAniAnterioriPage> createState() => _GrileAniAnterioriPageState();
}

class _GrileAniAnterioriPageState extends State<GrileAniAnterioriPage> {
  final List<String> _tests = [
    'Test INM 2021',
    'Test INM 2022',
    'Test INM 2023',
  ];

  void _clearTests() {
    setState(() => _tests.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toate testele au fost șterse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Grile ani anteriori',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.black),
            tooltip: 'Șterge toate testele',
            onPressed: _tests.isEmpty ? null : _clearTests,
          ),
        ],
      ),
      body: _tests.isEmpty
          ? Center(
              child: Text(
                'Nu există teste',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _tests.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(
                  _tests[index],
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),
    );
  }
}