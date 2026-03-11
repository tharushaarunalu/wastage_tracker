import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/wastage_item.dart';

class PdfService {
  static Future<void> generateDailyReport(List<WastageItem> items, DateTime date) async {
    final pdf = pw.Document();
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    double totalWeight = 0;
    for (var item in items) {
      totalWeight += item.weight;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Supermarket Daily Wastage Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Date: $dateString", style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            items.isEmpty 
              ? pw.Text("No wastage recorded for this date.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic))
              : pw.TableHelper.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  headers: ['Item Name', 'Category', 'Weight (kg)', 'Time'],
                  data: items.map((item) => [
                    item.name,
                    item.category,
                    item.weight.toStringAsFixed(2),
                    DateFormat('HH:mm').format(item.date),
                  ]).toList(),
                ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text("Total Items: ${items.length}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(width: 20),
                pw.Text("Total Weight: ${totalWeight.toStringAsFixed(2)} kg", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ]
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Wastage_Report_$dateString.pdf'
    );
  }
}
