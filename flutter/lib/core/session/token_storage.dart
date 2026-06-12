import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<({String access, String refresh})?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return (access: access, refresh: refresh);
  }

  Future<void> write({required String access, required String refresh}) =>
      Future.wait([
        _storage.write(key: _accessKey, value: access),
        _storage.write(key: _refreshKey, value: refresh),
      ]);

  Future<void> clear() => Future.wait([
        _storage.delete(key: _accessKey),
        _storage.delete(key: _refreshKey),
      ]);
}
