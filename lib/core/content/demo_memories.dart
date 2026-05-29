import '../../domain/entities/memory.dart';
import '../../domain/enums/media_type.dart';
import '../config/wedding_config.dart';

/// Sample memories when Firebase is not configured (UI preview / dev).
abstract final class DemoMemories {
  static List<Memory> get gallery => [
        Memory(
          id: 'demo-1',
          imageUrl:
              'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&q=80',
          timestamp: DateTime.now(),
          mediaType: MediaType.photo,
          weddingId: WeddingConfig.weddingId,
          guestName: 'Sarah',
          message: 'So much love in this room!',
        ),
        Memory(
          id: 'demo-2',
          imageUrl:
              'https://images.unsplash.com/photo-1464366400600-7168b8d9bb62?w=400&q=80',
          timestamp: DateTime.now(),
          mediaType: MediaType.photo,
          weddingId: WeddingConfig.weddingId,
          guestName: 'James',
          message: 'Congratulations!',
        ),
        Memory(
          id: 'demo-3',
          imageUrl:
              'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400&q=80',
          timestamp: DateTime.now(),
          mediaType: MediaType.photo,
          weddingId: WeddingConfig.weddingId,
          guestName: 'Amina',
          tableNumber: '7',
        ),
      ];

  static List<Memory> get weddingWall => [
        Memory(
          id: 'demo-w1',
          imageUrl:
              'https://images.unsplash.com/photo-1519741497674-611481863552?w=1200&q=80',
          timestamp: DateTime.now(),
          mediaType: MediaType.photo,
          weddingId: WeddingConfig.weddingId,
          guestName: 'Guest',
          message: WeddingConfig.coupleDisplayName,
        ),
        Memory(
          id: 'demo-w2',
          imageUrl:
              'https://images.unsplash.com/photo-1464366400600-7168b8d9bb62?w=1200&q=80',
          timestamp: DateTime.now(),
          mediaType: MediaType.photo,
          weddingId: WeddingConfig.weddingId,
          message: 'Forever begins today',
        ),
      ];
}
