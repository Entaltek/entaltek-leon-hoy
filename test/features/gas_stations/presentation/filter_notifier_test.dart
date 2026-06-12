import 'package:flutter_test/flutter_test.dart';

import 'package:leon_hoy/features/gas_stations/presentation/widgets/filter_bottom_sheet.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('FilterNotifier', () {
    test('estado inicial tiene valores por defecto', () {
      final container = createContainer();
      final state = container.read(filterNotifierProvider);

      expect(state.fuelType, FuelType.regular);
      expect(state.maxPrice, 30.0);
      expect(state.onlyOpen, isFalse);
      expect(state.sortByPrice, isTrue);
    });

    test('setFuelType cambia el tipo de combustible', () {
      final container = createContainer();
      final notifier = container.read(filterNotifierProvider.notifier);

      notifier.setFuelType(FuelType.premium);

      expect(
        container.read(filterNotifierProvider).fuelType,
        FuelType.premium,
      );
    });

    test('setMaxPrice actualiza el precio máximo', () {
      final container = createContainer();
      container.read(filterNotifierProvider.notifier).setMaxPrice(25.0);

      expect(container.read(filterNotifierProvider).maxPrice, 25.0);
    });

    test('toggleOnlyOpen alterna el valor', () {
      final container = createContainer();
      final notifier = container.read(filterNotifierProvider.notifier);

      notifier.toggleOnlyOpen();
      expect(container.read(filterNotifierProvider).onlyOpen, isTrue);

      notifier.toggleOnlyOpen();
      expect(container.read(filterNotifierProvider).onlyOpen, isFalse);
    });

    test('toggleSortByPrice alterna el valor', () {
      final container = createContainer();
      final notifier = container.read(filterNotifierProvider.notifier);

      notifier.toggleSortByPrice();
      expect(container.read(filterNotifierProvider).sortByPrice, isFalse);
    });

    test('reset restaura todos los valores por defecto', () {
      final container = createContainer();
      final notifier = container.read(filterNotifierProvider.notifier);

      notifier.setFuelType(FuelType.diesel);
      notifier.setMaxPrice(20.0);
      notifier.toggleOnlyOpen();
      notifier.reset();

      final state = container.read(filterNotifierProvider);
      expect(state.fuelType, FuelType.regular);
      expect(state.maxPrice, 30.0);
      expect(state.onlyOpen, isFalse);
      expect(state.sortByPrice, isTrue);
    });
  });
}
