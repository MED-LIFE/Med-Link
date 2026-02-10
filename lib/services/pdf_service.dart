import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateAndPrintClinicalHistory(String patientName, String dni, List<Map<String, String>> records) async {
    final pdf = pw.Document();

    // Load Zanoo Logo (Placeholder logic - assuming you have the asset, otherwise use text)
    // final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/logo_zanoo_blue.png')).buffer.asUint8List());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          _buildPatientInfo(patientName, dni),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 20),
          pw.Text("Historia Clínica Digital", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.SizedBox(height: 10),
          ...records.map((r) => _buildRecordItem(r)),
          pw.SizedBox(height: 40), 
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Zanoo Logo Text (since asset might fail if not loaded correctly in async)
        pw.Text("ZANOO", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold, color: PdfColors.blueAccent700)),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text("Instituto de Oncología Ángel H. Roffo", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            pw.Text("Av. San Martín 5481, CABA", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Text("+54 11 5287-5000", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        )
      ],
    );
  }

  pw.Widget _buildPatientInfo(String name, String dni) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
           pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
             pw.Text("PACIENTE", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
             pw.Text(name, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
           ])),
           pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
             pw.Text("DNI", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
             pw.Text(dni, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
           ])),
           pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
             pw.Text("FECHA EMISIÓN", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
             pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.now()), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
           ])),
        ],
      )
    );
  }

  pw.Widget _buildRecordItem(Map<String, String> record) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 80,
            child: pw.Text(record['date'] ?? '', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
          ),
          pw.Container(width: 1, height: 30, color: PdfColors.grey300, margin: const pw.EdgeInsets.symmetric(horizontal: 12)),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(record['title'] ?? 'Consulta', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(record['description'] ?? '', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              ],
            )
          )
        ],
      )
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.Text("Generado por Plataforma Zanoo - Salud Digital", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text("Page ${context.pageNumber} of ${context.pagesCount}", style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      )
    );
  }
}
