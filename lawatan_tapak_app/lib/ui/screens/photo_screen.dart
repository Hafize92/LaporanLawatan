import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/site_photo.dart';
import '../../services/photo_intake_service.dart';
import '../../state/lawatan_app_state.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key, required this.state});

  final LawatanAppState state;

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final PhotoIntakeService _photoService = PhotoIntakeService();
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final photos = widget.state.photos;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Gambar tapak',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (_isBusy)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            FilledButton.icon(
              onPressed:
                  _isBusy ? null : () => _addPhoto(PhotoSourceMode.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Ambil gambar'),
            ),
            OutlinedButton.icon(
              onPressed:
                  _isBusy ? null : () => _addPhoto(PhotoSourceMode.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Import galeri'),
            ),
            OutlinedButton.icon(
              onPressed: _isBusy ? null : widget.state.addDemoPhoto,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Tambah demo'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (photos.isEmpty)
          const _EmptyPhotos()
        else
          ...photos.map(
            (photo) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PhotoCard(
                photo: photo,
                onChanged: widget.state.updatePhoto,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addPhoto(PhotoSourceMode mode) async {
    setState(() => _isBusy = true);
    try {
      final photo = await _photoService.pickPhoto(
        mode: mode,
        levelOffsetMeters: widget.state.project.levelOffsetMeters,
      );
      if (photo != null) {
        widget.state.addPhoto(photo);
      }
    } on PhotoIntakeFailure catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            Icon(Icons.add_a_photo_outlined, size: 40),
            SizedBox(height: 8),
            Text('Belum ada gambar. Ambil gambar atau import daripada galeri.'),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.onChanged,
  });

  final SitePhoto photo;
  final ValueChanged<SitePhoto> onChanged;

  @override
  Widget build(BuildContext context) {
    final imageExists =
        photo.filePath.trim().isNotEmpty && File(photo.filePath).existsSync();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final image = ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: imageExists
                    ? Image.file(File(photo.filePath), fit: BoxFit.cover)
                    : ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
              ),
            );

            final details = _PhotoDetails(photo: photo, onChanged: onChanged);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 260, child: image),
                  const SizedBox(width: 16),
                  Expanded(child: details),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                image,
                const SizedBox(height: 12),
                details,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhotoDetails extends StatelessWidget {
  const _PhotoDetails({
    required this.photo,
    required this.onChanged,
  });

  final SitePhoto photo;
  final ValueChanged<SitePhoto> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                photo.caption.trim().isEmpty ? 'Gambar tapak' : photo.caption,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Edit catatan',
              onPressed: () => _editPhoto(context),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _InfoLine(icon: Icons.place_outlined, text: photo.coordinateText),
        _InfoLine(icon: Icons.terrain_outlined, text: photo.altitudeText),
        _InfoLine(icon: Icons.height, text: photo.adjustedLevelText),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ActionChip(
              avatar: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Pemerhatian biasa'),
              onPressed: () => _appendObservation(
                'Keadaan tapak direkodkan semasa lawatan.',
              ),
            ),
            ActionChip(
              avatar: const Icon(Icons.build_outlined, size: 18),
              label: const Text('Perlu tindakan'),
              onPressed: () => _appendRecommendation(
                'Tindakan lanjut diperlukan di lokasi ini.',
              ),
            ),
          ],
        ),
        if (photo.observation.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          Text(
            photo.observation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  void _appendObservation(String sentence) {
    final current = photo.observation.trim();
    onChanged(
      photo.copyWith(
        observation: current.isEmpty ? sentence : '$current $sentence',
      ),
    );
  }

  void _appendRecommendation(String sentence) {
    final current = photo.recommendation.trim();
    onChanged(
      photo.copyWith(
        recommendation: current.isEmpty ? sentence : '$current $sentence',
      ),
    );
  }

  Future<void> _editPhoto(BuildContext context) async {
    final captionController = TextEditingController(text: photo.caption);
    final observationController = TextEditingController(text: photo.observation);
    final recommendationController =
        TextEditingController(text: photo.recommendation);

    final updated = await showDialog<SitePhoto>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit catatan gambar'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: captionController,
                    decoration: const InputDecoration(labelText: 'Tajuk gambar'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: observationController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Pemerhatian',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: recommendationController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Cadangan',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(
                  photo.copyWith(
                    caption: captionController.text.trim(),
                    observation: observationController.text.trim(),
                    recommendation: recommendationController.text.trim(),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    captionController.dispose();
    observationController.dispose();
    recommendationController.dispose();

    if (updated != null) {
      onChanged(updated);
    }
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
