import 'package:flutter/material.dart';

import '../../state/lawatan_app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.state});

  final LawatanAppState state;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final TextEditingController _projectNameController;
  late final TextEditingController _clientController;
  late final TextEditingController _locationController;
  late final TextEditingController _officerController;
  late final TextEditingController _weatherController;
  late final TextEditingController _notesController;
  late final TextEditingController _conclusionController;
  late final TextEditingController _offsetController;

  @override
  void initState() {
    super.initState();
    final project = widget.state.project;
    final visit = widget.state.activeVisit;
    _projectNameController = TextEditingController(text: project.projectName);
    _clientController = TextEditingController(text: project.clientName);
    _locationController = TextEditingController(text: project.locationName);
    _officerController = TextEditingController(text: visit.officerName);
    _weatherController = TextEditingController(text: visit.weather);
    _notesController = TextEditingController(text: visit.generalNotes);
    _conclusionController = TextEditingController(text: visit.conclusion);
    _offsetController = TextEditingController(
      text: project.levelOffsetMeters.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _clientController.dispose();
    _locationController.dispose();
    _officerController.dispose();
    _weatherController.dispose();
    _notesController.dispose();
    _conclusionController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.state.project;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'Projek lawatan',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _StatTile(
              icon: Icons.photo_library_outlined,
              label: 'Jumlah gambar',
              value: project.totalPhotos.toString(),
            ),
            _StatTile(
              icon: Icons.pin_drop_outlined,
              label: 'Ada koordinat',
              value: project.totalPhotosWithCoordinate.toString(),
            ),
            _StatTile(
              icon: Icons.height,
              label: 'Offset level',
              value: '${project.levelOffsetMeters.toStringAsFixed(2)} m',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'Maklumat projek',
          children: <Widget>[
            TextField(
              controller: _projectNameController,
              decoration: const InputDecoration(
                labelText: 'Nama projek',
                prefixIcon: Icon(Icons.business_center_outlined),
              ),
              onChanged: (value) => widget.state.updateProject(projectName: value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: 'Klien',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              onChanged: (value) => widget.state.updateProject(clientName: value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi tapak',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (value) => widget.state.updateProject(locationName: value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Maklumat lawatan',
          children: <Widget>[
            TextField(
              controller: _officerController,
              decoration: const InputDecoration(
                labelText: 'Pegawai',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              onChanged: (value) => widget.state.updateVisit(officerName: value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weatherController,
              decoration: const InputDecoration(
                labelText: 'Cuaca',
                prefixIcon: Icon(Icons.wb_sunny_outlined),
              ),
              onChanged: (value) => widget.state.updateVisit(weather: value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Catatan umum',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => widget.state.updateVisit(generalNotes: value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conclusionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Kesimpulan laporan',
                alignLabelWithHint: true,
              ),
              onChanged: (value) => widget.state.updateVisit(conclusion: value),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'Tetapan level',
          children: <Widget>[
            TextField(
              controller: _offsetController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Offset level / benchmark (m)',
                prefixIcon: Icon(Icons.straighten),
              ),
              onSubmitted: _saveOffset,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => _saveOffset(_offsetController.text),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan offset'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveOffset(String value) {
    final offset = double.tryParse(value.trim());
    if (offset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai offset yang sah.')),
      );
      return;
    }
    widget.state.updateLevelOffset(offset);
    _offsetController.text = offset.toStringAsFixed(2);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Icon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    Text(value, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
