import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Model representing a saved login credential for fast autofill / switching.
class SavedAccount {
  final String email;
  final String password;
  final String? name;
  final DateTime lastUsed;

  const SavedAccount({
    required this.email,
    required this.password,
    this.name,
    required this.lastUsed,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
        'lastUsed': lastUsed.toIso8601String(),
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        name: json['name'] as String?,
        lastUsed:
            DateTime.tryParse(json['lastUsed'] as String? ?? '') ?? DateTime.now(),
      );

  SavedAccount copyWith({
    String? email,
    String? password,
    String? name,
    DateTime? lastUsed,
  }) =>
      SavedAccount(
        email: email ?? this.email,
        password: password ?? this.password,
        name: name ?? this.name,
        lastUsed: lastUsed ?? this.lastUsed,
      );
}

/// Service to securely store, retrieve, update, and manage multiple saved accounts.
class SavedAccountsService {
  final FlutterSecureStorage _storage;
  static const String _storageKey = 'labella_saved_accounts_v1';

  SavedAccountsService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  /// Retrieve all saved accounts, sorted by last used descending.
  Future<List<SavedAccount>> getSavedAccounts() async {
    try {
      final raw = await _storage.read(key: _storageKey);
      if (raw == null || raw.isEmpty) return [];
      final List decoded = jsonDecode(raw) as List;
      final accounts = decoded
          .map((e) => SavedAccount.fromJson(e as Map<String, dynamic>))
          .where((a) => a.email.isNotEmpty)
          .toList();
      accounts.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      return accounts;
    } catch (_) {
      return [];
    }
  }

  /// Find an account by email (case-insensitive).
  Future<SavedAccount?> findAccount(String email) async {
    final accounts = await getSavedAccounts();
    final normalized = email.trim().toLowerCase();
    for (final a in accounts) {
      if (a.email.trim().toLowerCase() == normalized) {
        return a;
      }
    }
    return null;
  }

  /// Save or update an account.
  Future<void> saveOrUpdateAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    final accounts = await getSavedAccounts();
    final normalized = email.trim().toLowerCase();
    final index = accounts.indexWhere(
      (a) => a.email.trim().toLowerCase() == normalized,
    );

    final updated = SavedAccount(
      email: email.trim(),
      password: password,
      name: name,
      lastUsed: DateTime.now(),
    );

    if (index >= 0) {
      accounts[index] = updated;
    } else {
      accounts.insert(0, updated);
    }

    await _persist(accounts);
  }

  /// Remove an account by email.
  Future<void> removeAccount(String email) async {
    final accounts = await getSavedAccounts();
    final normalized = email.trim().toLowerCase();
    accounts.removeWhere((a) => a.email.trim().toLowerCase() == normalized);
    await _persist(accounts);
  }

  /// Clear all saved accounts.
  Future<void> clearAll() async {
    await _storage.delete(key: _storageKey);
  }

  Future<void> _persist(List<SavedAccount> accounts) async {
    final jsonString = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await _storage.write(key: _storageKey, value: jsonString);
  }
}
