import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/firebase/firebase_content_datasource.dart';
import '../content/content_specs.dart';

enum ContentEditorStatus { loading, ready, saving, error }

class ContentEditorState extends Equatable {
  const ContentEditorState({
    this.status = ContentEditorStatus.loading,
    this.items = const [],
    this.dirty = false,
    this.message,
  });

  final ContentEditorStatus status;
  final List<Map<String, dynamic>> items;
  final bool dirty;
  final String? message;

  ContentEditorState copyWith({
    ContentEditorStatus? status,
    List<Map<String, dynamic>>? items,
    bool? dirty,
    String? message,
  }) {
    return ContentEditorState(
      status: status ?? this.status,
      items: items ?? this.items,
      dirty: dirty ?? this.dirty,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, items, dirty, message];
}

/// Loads, mutates, and saves the ordered items for a single content section.
class ContentEditorCubit extends Cubit<ContentEditorState> {
  ContentEditorCubit(this._dataSource, this.spec)
      : super(const ContentEditorState());

  final FirebaseContentDataSource _dataSource;
  final ContentSectionSpec spec;

  Future<void> load() async {
    emit(state.copyWith(status: ContentEditorStatus.loading, message: null));
    try {
      final remote = await _dataSource.fetchSectionItems(spec.id);
      final items = remote ?? spec.defaults();
      emit(state.copyWith(
        status: ContentEditorStatus.ready,
        items: _clone(items),
        dirty: false,
      ));
    } catch (e, stack) {
      AppLogger.error('Content editor load failed',
          tag: 'ContentEditor', error: e, stackTrace: stack);
      // Fall back to current defaults so editing is always possible.
      emit(state.copyWith(
        status: ContentEditorStatus.ready,
        items: _clone(spec.defaults()),
        dirty: false,
      ));
    }
  }

  void upsertItem(int? index, Map<String, dynamic> item) {
    final items = _clone(state.items);
    if (index == null || index < 0 || index >= items.length) {
      items.add(item);
    } else {
      items[index] = item;
    }
    emit(state.copyWith(items: items, dirty: true));
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final items = _clone(state.items)..removeAt(index);
    emit(state.copyWith(items: items, dirty: true));
  }

  void reorder(int oldIndex, int newIndex) {
    final items = _clone(state.items);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    emit(state.copyWith(items: items, dirty: true));
  }

  Future<bool> save() async {
    emit(state.copyWith(status: ContentEditorStatus.saving, message: null));
    try {
      await _dataSource.saveSection(spec.id, state.items);
      emit(state.copyWith(status: ContentEditorStatus.ready, dirty: false));
      return true;
    } catch (e, stack) {
      AppLogger.error('Content save failed',
          tag: 'ContentEditor', error: e, stackTrace: stack);
      emit(state.copyWith(
        status: ContentEditorStatus.ready,
        message: 'Could not save changes. Please try again.',
      ));
      return false;
    }
  }

  List<Map<String, dynamic>> _clone(List<Map<String, dynamic>> items) =>
      items.map((e) => Map<String, dynamic>.from(e)).toList();
}
