import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/site_photo.dart';
import '../models/site_project.dart';

class ReportService {
  Future<Uint8List> buildProjectReport(
    SiteProject project,
    PdfPageFormat pageFormat,
  ) async {
    final document = pw.Document(title: 'Laporan Lawatan Tapak');
    final visit = project.visits.isEmpty ? null : project.visits.first;
    final photos = visit?.photos ?? const <SitePhoto>[];
    final photoWidgets = await _photoPages(photos);

    document.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => <pw.Widget>[
          _header(project),
          pw.SizedBox(height: 16),
          _projectSummary(project),
          if (visit != null) ...<pw.Widget>[
            pw.SizedBox(height: 16),
            _visitSummary(visit.officerName, visit.weather, visit.generalNotes),
          ],
          pw.SizedBox(height: 18),
          _photoTable(photos),
          pw.SizedBox(height: 18),
          ...photoWidgets,
          if (visit != null && visit.conclusion.trim().isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Kesimpulan'),
            pw.Text(visit.conclusion),
          ],
        ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(SiteProject project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Laporan Lawatan Tapak',
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Text(project.projectName, style: const pw.TextStyle(fontSize: 15)),
        pw.Text(project.locationName),
      ],
    );
  }

  pw.Widget _projectSummary(SiteProject project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          _line('Klien', project.clientName),
          _line('Tarikh laporan', _dateText(DateTime.now())),
          _line('Offset level', '${project.levelOffsetMeters.toStringAsFixed(2)} m'),
          _line('Jumlah gambar', project.totalPhotos.toString()),
          _line(
            'Gambar berkoordinat',
            project.totalPhotosWithCoordinate.toString(),
          ),
        ],
      ),
    );
  }

  pw.Widget _visitSummary(String officerName, String weather, String notes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Header(level: 1, text: 'Maklumat Lawatan'),
        _line('Pegawai', officerName),
        if (weather.trim().isNotEmpty) _line('Cuaca', weather),
        if (notes.trim().isNotEmpty) ...<pw.Widget>[
          pw.SizedBox(height: 8),
          pw.Text('Catatan umum', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(notes),
        ],
      ],
    );
  }

  pw.Widget _photoTable(List<SitePhoto> photos) {
    if (photos.isEmpty) {
      return pw.Text('Belum ada gambar untuk laporan.');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Header(level: 1, text: 'Jadual Gambar'),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: const <int, pw.TableColumnWidth>{
            0: pw.FixedColumnWidth(24),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(2),
          },
          headers: const <String>['No', 'Koordinat', 'Level', 'Catatan'],
          data: List<List<String>>.generate(photos.length, (index) {
            final photo = photos[index];
            return <String>[
              '${index + 1}',
              photo.coordinateText,
              photo.adjustedLevelText,
              photo.caption.trim().isEmpty ? '-' : photo.caption,
            ];
          }),
        ),
      ],
    );
  }

  Future<List<pw.Widget>> _photoPages(List<SitePhoto> photos) async {
    final widgets = <pw.Widget>[];

    for (var index = 0; index < photos.length; index += 1) {
      final photo = photos[index];
      final image = await _imageProvider(photo.filePath);
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                'Gambar ${index + 1}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),
              if (image != null)
                pw.Container(
                  height: 210,
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                )
              else
                pw.Container(
                  height: 90,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Text('Fail gambar tidak ditemui'),
                ),
              pw.SizedBox(height: 8),
              _line('Koordinat', photo.coordinateText),
              _line('Altitude', photo.altitudeText),
              _line('Adjusted level', photo.adjustedLevelText),
              if (photo.observation.trim().isNotEmpty)
                _paragraph('Pemerhatian', photo.observation),
              if (photo.recommendation.trim().isNotEmpty)
                _paragraph('Cadangan', photo.recommendation),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Future<pw.MemoryImage?> _imageProvider(String filePath) async {
    if (filePath.trim().isEmpty) {
      return null;
    }
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }
    return pw.MemoryImage(await file.readAsBytes());
  }

  pw.Widget _line(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: <pw.TextSpan>[
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  pw.Widget _paragraph(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  String _dateText(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }
}
