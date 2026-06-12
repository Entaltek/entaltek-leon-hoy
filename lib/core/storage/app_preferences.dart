import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_preferences.g.dart';

const _boxName = 'app_prefs';
const _keyOnboardingSeen = 'onboarding_seen';

/// Preferencias simples de la app almacenadas en Hive.
/// No requiere cifrado, por eso va separado de SecureStorage.
class AppPreferences {
  Future<bool> hasSeenOnboarding() async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_keyOnboardingSeen, defaultValue: false) ?? false;
  }

  Future<void> markOnboardingSeen() async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_keyOnboardingSeen, true);
  }
}

@Riverpod(keepAlive: true)
AppPreferences appPreferences(AppPreferencesRef ref) => AppPreferences();
