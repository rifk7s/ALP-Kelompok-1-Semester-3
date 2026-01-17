import 'package:frontend/features/bumdes/service/bumdes_service.dart';

/// Repository layer for BUMDes operations.
/// Wraps BumdesService for unified BUMDes API.
class BumdesRepository {
  /// Get BUMDes info (cached)
  Future<BumdesInfo?> getBumdesInfo() async {
    return BumdesService.getBumdesInfo();
  }

  /// Clear cached BUMDes info
  void clearCache() {
    BumdesService.clearCache();
  }
}
