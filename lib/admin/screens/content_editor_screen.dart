import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../data/datasources/firebase/firebase_content_datasource.dart';
import '../../presentation/widgets/app_image.dart';
import '../content/content_specs.dart';
import '../cubit/content_editor_cubit.dart';

class ContentEditorScreen extends StatelessWidget {
  const ContentEditorScreen({super.key, required this.spec});

  final ContentSectionSpec spec;

  @override
  Widget build(BuildContext context) {
    final dataSource = context.read<FirebaseContentDataSource>();
    return BlocProvider<ContentEditorCubit>(
      create: (_) => ContentEditorCubit(dataSource, spec)..load(),
      child: _EditorView(spec: spec, dataSource: dataSource),
    );
  }
}

class _EditorView extends StatelessWidget {
  const _EditorView({required this.spec, required this.dataSource});

  final ContentSectionSpec spec;
  final FirebaseContentDataSource dataSource;

  Future<void> _edit(BuildContext context, {int? index}) async {
    final cubit = context.read<ContentEditorCubit>();
    final current = index == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(cubit.state.items[index]);
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ContentItemFormScreen(
          spec: spec,
          dataSource: dataSource,
          initial: current,
        ),
      ),
    );
    if (result != null) cubit.upsertItem(index, result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContentEditorCubit, ContentEditorState>(
      listenWhen: (p, c) => c.message != null && p.message != c.message,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(state.message!),
            backgroundColor: AppColors.wine,
          ));
      },
      builder: (context, state) {
        final cubit = context.read<ContentEditorCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(spec.title),
            actions: [
              if (state.status == ContentEditorStatus.saving)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.roseGold),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: state.dirty
                      ? () async {
                          final ok = await cubit.save();
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('Saved — guests see this now.'),
                                backgroundColor: AppColors.olive,
                              ));
                          }
                        }
                      : null,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: state.dirty
                          ? AppColors.roseGold
                          : AppColors.champagne.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: state.status == ContentEditorStatus.ready
              ? FloatingActionButton.extended(
                  backgroundColor: AppColors.roseGold,
                  foregroundColor: AppColors.noir,
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                )
              : null,
          body: state.status == ContentEditorStatus.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.roseGold))
              : state.items.isEmpty
                  ? const Center(
                      child: Text('No items yet. Tap Add to create one.',
                          style: TextStyle(color: AppColors.champagne)),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                      itemCount: state.items.length,
                      onReorder: cubit.reorder,
                      itemBuilder: (context, i) {
                        final item = state.items[i];
                        return _ItemTile(
                          key: ValueKey('$i-${item[spec.titleKey]}'),
                          spec: spec,
                          item: item,
                          index: i,
                          onTap: () => _edit(context, index: i),
                          onDelete: () => _confirmDelete(context, cubit, i),
                        );
                      },
                    ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ContentEditorCubit cubit, int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A130C),
        title: const Text('Remove this item?'),
        content: const Text('It will be removed when you Save.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wine),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) cubit.removeItem(index);
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    super.key,
    required this.spec,
    required this.item,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final ContentSectionSpec spec;
  final Map<String, dynamic> item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final title = (item[spec.titleKey] ?? '').toString();
    return Card(
      color: const Color(0xFF1A130C),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: _leading(),
        title: Text(
          title.isEmpty ? '(untitled)' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: spec.media == ContentMediaKind.none
            ? null
            : Text(
                _mediaLabel(),
                style: const TextStyle(fontSize: 11, color: AppColors.champagne),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.wine),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: AppColors.champagne),
            ),
          ],
        ),
      ),
    );
  }

  String _mediaLabel() {
    final v = (item[spec.mediaKey] ?? '').toString();
    if (v.isEmpty) return 'No media set';
    return spec.isVideo ? 'Video attached' : 'Photo attached';
  }

  Widget _leading() {
    if (spec.media == ContentMediaKind.image) {
      final src = (item[spec.mediaKey] ?? '').toString();
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: src.isEmpty
              ? const ColoredBox(
                  color: Color(0xFF20281A),
                  child: Icon(Icons.image_outlined, color: AppColors.champagne))
              : AppImage(source: src),
        ),
      );
    }
    if (spec.media == ContentMediaKind.video) {
      return const CircleAvatar(
        backgroundColor: Color(0xFF20281A),
        child: Icon(Icons.movie_outlined, color: AppColors.mint),
      );
    }
    return const CircleAvatar(
      backgroundColor: Color(0xFF20281A),
      child: Icon(Icons.format_quote, color: AppColors.mint),
    );
  }
}

/// Form for creating/editing a single content item, including media upload.
class ContentItemFormScreen extends StatefulWidget {
  const ContentItemFormScreen({
    super.key,
    required this.spec,
    required this.dataSource,
    required this.initial,
  });

  final ContentSectionSpec spec;
  final FirebaseContentDataSource dataSource;
  final Map<String, dynamic> initial;

  @override
  State<ContentItemFormScreen> createState() => _ContentItemFormScreenState();
}

class _ContentItemFormScreenState extends State<ContentItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  String _mediaUrl = '';
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.spec.fields)
        f.key: TextEditingController(
            text: (widget.initial[f.key] ?? '').toString()),
    };
    if (widget.spec.hasMedia) {
      _mediaUrl = (widget.initial[widget.spec.mediaKey] ?? '').toString();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final XFile? file = widget.spec.isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file == null) return;

    setState(() => _uploading = true);
    try {
      final url = await widget.dataSource.uploadMedia(
        file: file,
        section: widget.spec.id,
        isVideo: widget.spec.isVideo,
      );
      if (!mounted) return;
      setState(() {
        _mediaUrl = url;
        _uploading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Upload failed. Please try again.'),
          backgroundColor: AppColors.wine,
        ));
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (widget.spec.hasMedia && _mediaUrl.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(widget.spec.isVideo
              ? 'Please add a video first.'
              : 'Please add a photo first.'),
          backgroundColor: AppColors.wine,
        ));
      return;
    }
    final result = <String, dynamic>{
      for (final f in widget.spec.fields)
        f.key: _controllers[f.key]!.text.trim(),
    };
    if (widget.spec.hasMedia) result[widget.spec.mediaKey] = _mediaUrl;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial.isEmpty ? 'Add item' : 'Edit item'),
        actions: [
          TextButton(
            onPressed: _uploading ? null : _submit,
            child: const Text('Done',
                style: TextStyle(
                    color: AppColors.roseGold, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.spec.hasMedia) ...[
              _MediaPicker(
                spec: widget.spec,
                url: _mediaUrl,
                uploading: _uploading,
                onPick: _pickMedia,
              ),
              const SizedBox(height: 20),
            ],
            for (final f in widget.spec.fields) ...[
              TextFormField(
                controller: _controllers[f.key],
                maxLines: f.multiline ? 5 : 1,
                minLines: f.multiline ? 3 : 1,
                decoration: InputDecoration(labelText: f.label),
                validator: f.required
                    ? (v) => (v == null || v.trim().isEmpty)
                        ? '${f.label} is required'
                        : null
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaPicker extends StatelessWidget {
  const _MediaPicker({
    required this.spec,
    required this.url,
    required this.uploading,
    required this.onPick,
  });

  final ContentSectionSpec spec;
  final String url;
  final bool uploading;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: const Color(0xFF20281A),
              child: uploading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.roseGold))
                  : _preview(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: uploading ? null : onPick,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.roseGold,
            side: const BorderSide(color: AppColors.roseGold),
            minimumSize: const Size.fromHeight(48),
          ),
          icon: Icon(spec.isVideo ? Icons.video_library : Icons.add_photo_alternate),
          label: Text(url.isEmpty
              ? (spec.isVideo ? 'Choose video' : 'Choose photo')
              : (spec.isVideo ? 'Replace video' : 'Replace photo')),
        ),
      ],
    );
  }

  Widget _preview() {
    if (url.isEmpty) {
      return Center(
        child: Icon(
          spec.isVideo ? Icons.movie_outlined : Icons.image_outlined,
          color: AppColors.champagne,
          size: 40,
        ),
      );
    }
    if (spec.isVideo) {
      return const Center(
        child: Icon(Icons.check_circle, color: AppColors.mint, size: 40),
      );
    }
    return AppImage(source: url);
  }
}
