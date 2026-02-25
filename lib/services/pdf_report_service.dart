import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfReportService {
  static Future<void> generateAttendanceReport({
    required String name,
    required String rollNumber,
    required String department,
    required String semester,
    required Map<String, dynamic> attendance,
    required double percentage,
  }) async {
    final pdf = pw.Document();

    final sortedDates = attendance.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('EduPresence Attendance Report',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Student Name: $name',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('Roll Number: $rollNumber',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('Department: $department',
                    style: pw.TextStyle(fontSize: 14)),
                pw.Text('Semester: $semester',
                    style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Total Attendance Percentage: ${percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900)),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Status'],
              data:
                  sortedDates.map((date) => [date, attendance[date]]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
