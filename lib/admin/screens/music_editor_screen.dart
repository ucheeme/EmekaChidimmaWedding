import 'package:audioplayers/audioplayers.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/firebase/firebase_content_datasource.dart';

/// Lets the admin choose, preview, and clear the looping background-music track
/// guests hear while browsing.
class MusicEditorScreen extends StatefulWidget {
  const MusicEditorScreen({super.key});

  @override
  State<MusicEditorScreen> createState() => _MusicEditorScreenState();
}

class _MusicEditorScreenState extends State<MusicEditorScreen> {
  final AudioPlayer _preview = AudioPlayer();
  late final FirebaseContentDataSource _dataSource;

  String? _url;
  bool _loading = true;
  bool _busy = false;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    _dataSource = context.read<FirebaseContentDataSource>();
    _preview.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _previewing = s == PlayerState.playing);
    });
    _load();
  }

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final url = await _dataSource.fetchMusicUrl();
    if (!mounted) return;
    setState(() {
      _url = url;
      _loading = false;
    });
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    final path = picked.path;
    if (path == null) return;

    setState(() => _busy = true);
    try {
      final url = await _dataSource.uploadAudio(
        file: XFile(path),
        fileName: picked.name,
      );
      await _dataSource.saveMusicUrl(url);
      if (!mounted) return;
      setState(() {
        _url = url;
        _busy = false;
      });
      _snack('Music saved — guests will hear it.', AppColors.olive);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Upload failed. Please try again.', AppColors.wine);
    }
  }

  Future<void> _togglePreview() async {
    if (_url == null) return;
    if (_previewing) {
      await _preview.pause();
    } else {
      await _preview.play(UrlSource(_url!));
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await _preview.stop();
      await _dataSource.saveMusicUrl('');
      if (!mounted) return;
      setState(() {
        _url = null;
        _busy = false;
      });
      _snack('Music removed.', AppColors.olive);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Could not remove music.', AppColors.wine);
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final hasTrack = _url != null && _url!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Background Music')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.roseGold))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Upload a song that loops softly while guests browse the app. '
                  'It starts after a guest taps to enter, and they can mute it any '
                  'time from the speaker icon.',
                  style: TextStyle(color: AppColors.champagne, height: 1.5),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A130C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasTrack ? Icons.music_note : Icons.music_off,
                        color: hasTrack ? AppColors.mint : AppColors.champagne,
                        size: 36,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          hasTrack ? 'A track is set.' : 'No music yet.',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (hasTrack)
                        IconButton(
                          iconSize: 34,
                          icon: Icon(
                            _previewing
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: AppColors.roseGold,
                          ),
                          onPressed: _busy ? null : _togglePreview,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.roseGold,
                    foregroundColor: AppColors.noir,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _busy ? null : _pickAndUpload,
                  icon: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.noir),
                        )
                      : const Icon(Icons.upload_file),
                  label: Text(hasTrack ? 'Replace track' : 'Choose audio file'),
                ),
                if (hasTrack) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _busy ? null : _remove,
                    icon: const Icon(Icons.delete_outline, color: AppColors.wine),
                    label: const Text('Remove music',
                        style: TextStyle(color: AppColors.wine)),
                  ),
                ],
              ],
            ),
    );
  }
}
