import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/wedding_content.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/datasources/firebase/firebase_content_datasource.dart';

class ContentState {
  const ContentState({required this.bundle, this.loadedRemote = false});

  final WeddingContentBundle bundle;
  final bool loadedRemote;
}

/// Provides curated guest content. Emits the bundled defaults immediately so
/// the UI never waits, then refreshes from Firestore in the background. The
/// visual layout is unchanged — only the data source differs.
class ContentCubit extends Cubit<ContentState> {
  ContentCubit({FirebaseContentDataSource? dataSource})
      : _dataSource = dataSource,
        super(const ContentState(bundle: WeddingContentBundle.defaults));

  final FirebaseContentDataSource? _dataSource;

  Future<void> load() async {
    final dataSource = _dataSource;
    if (dataSource == null) return; // No backend: keep bundled defaults.
    try {
      final bundle = await dataSource.fetchBundle();
      emit(ContentState(bundle: bundle, loadedRemote: true));
    } catch (e, stack) {
      AppLogger.error(
        'Content load failed; using bundled defaults',
        tag: 'Content',
        error: e,
        stackTrace: stack,
      );
      // Keep showing defaults — never break the guest experience.
    }
  }
}
