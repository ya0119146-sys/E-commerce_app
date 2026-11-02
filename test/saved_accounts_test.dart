import 'package:e_commerce/features/auth/data/services/saved_accounts_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SavedAccount Model & Logic', () {
    test('Serializes and deserializes correctly', () {
      final now = DateTime.now();
      final account = SavedAccount(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        lastUsed: now,
      );

      final json = account.toJson();
      expect(json['email'], equals('test@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['name'], equals('Test User'));

      final reconstructed = SavedAccount.fromJson(json);
      expect(reconstructed.email, equals(account.email));
      expect(reconstructed.password, equals(account.password));
      expect(reconstructed.name, equals(account.name));
    });

    test('CopyWith creates updated copy preserving other properties', () {
      final account = SavedAccount(
        email: 'user@labella.com',
        password: 'oldPassword',
        name: 'User',
        lastUsed: DateTime(2025, 1, 1),
      );

      final updated = account.copyWith(password: 'newPassword123');
      expect(updated.email, equals('user@labella.com'));
      expect(updated.password, equals('newPassword123'));
      expect(updated.name, equals('User'));
    });
  });
}
