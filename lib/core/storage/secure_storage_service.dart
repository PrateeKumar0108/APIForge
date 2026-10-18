import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for storing and retrieving sensitive credentials in hardware-backed secure storage.
abstract interface class ISecureStorageService {
  Future<void> writeSecret(String refId, String secret);
  Future<String?> readSecret(String refId);
  Future<void> deleteSecret(String refId);
  Future<void> deleteAllSecrets();
}

/// Production implementation of [ISecureStorageService] using [FlutterSecureStorage].
/// Uses Android EncryptedSharedPreferences and iOS Keychain services.
class SecureStorageService implements ISecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> writeSecret(String refId, String secret) async {
    await _storage.write(key: 'secret_$refId', value: secret);
  }

  @override
  Future<String?> readSecret(String refId) async {
    return _storage.read(key: 'secret_$refId');
  }

  @override
  Future<void> deleteSecret(String refId) async {
    await _storage.delete(key: 'secret_$refId');
  }

  @override
  Future<void> deleteAllSecrets() async {
    await _storage.deleteAll();
  }
}
