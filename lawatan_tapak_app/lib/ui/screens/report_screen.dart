import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../services/report_service.dart';
import '../../state/lawatan_app_state.dart';

class ReportScreen extends StatelessWidget {
  ReportScreen({super.key, required this.state});

  final LawatanAppState state;
  final ReportService _reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Preview laporan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: PdfPreview(
            canChangeOrientation: true,
            canChangePageFormat: true,
            canDebug: false,
            build: (format) {
              return _reportService.buildProjectReport(state.project, format);
            },
          ),
        ),
      ],
    );
  }
}
