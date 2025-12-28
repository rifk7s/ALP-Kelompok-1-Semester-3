import 'package:go_router/go_router.dart';
import 'package:frontend/core/router/route_constants.dart';
import 'package:frontend/features/shared/screens/notification_screen.dart';
import 'package:frontend/features/shared/screens/chat_detail_page.dart';

/// Shared routes (used by both pembeli and bumdes)
class SharedRoutes {
  static List<GoRoute> routes = [
    GoRoute(
      path: RoutePaths.notifications,
      name: RouteNames.notifications,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: RoutePaths.chat,
      name: RouteNames.chat,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final id = state.pathParameters['id'] ?? '';
        final chatId = extra != null && extra['chatId'] != null
            ? extra['chatId'] as String
            : id;
        final name = extra != null && extra['name'] != null
            ? extra['name'] as String
            : (extra?['name'] ?? '');
        final image = extra != null && extra['image'] != null
            ? extra['image'] as String
            : (extra?['image'] ?? 'assets/images/logo.png');
        final recipientId = extra != null && extra['recipientId'] != null
            ? extra['recipientId'] as String
            : (extra?['recipientId'] ?? '');
        return ChatDetailPage(
          chatId: chatId,
          name: name,
          image: image,
          recipientId: recipientId,
        );
      },
    ),
  ];
}
