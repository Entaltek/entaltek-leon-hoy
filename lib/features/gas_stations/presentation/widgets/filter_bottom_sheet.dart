import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_theme.dart';

part 'filter_bottom_sheet.g.dart';

// ── Estado del filtro ────────────────────────────────────────────────────────

enum FuelType { regular, premium, diesel }

class FilterState {
  const FilterState({
    this.fuelType = FuelType.regular,
    this.maxPrice = 30.0,
    this.onlyOpen = false,
    this.sortByPrice = true,
  });

  final FuelType fuelType;
  final double maxPrice;
  final bool onlyOpen;
  final bool sortByPrice;

  FilterState copyWith({
    FuelType? fuelType,
    double? maxPrice,
    bool? onlyOpen,
    bool? sortByPrice,
  }) =>
      FilterState(
        fuelType: fuelType ?? this.fuelType,
        maxPrice: maxPrice ?? this.maxPrice,
        onlyOpen: onlyOpen ?? this.onlyOpen,
        sortByPrice: sortByPrice ?? this.sortByPrice,
      );
}

@Riverpod(keepAlive: true)
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() => const FilterState();

  void setFuelType(FuelType type) =>
      state = state.copyWith(fuelType: type);

  void setMaxPrice(double price) =>
      state = state.copyWith(maxPrice: price);

  void toggleOnlyOpen() =>
      state = state.copyWith(onlyOpen: !state.onlyOpen);

  void toggleSortByPrice() =>
      state = state.copyWith(sortByPrice: !state.sortByPrice);

  void reset() => state = const FilterState();
}

// ── Bottom Sheet ─────────────────────────────────────────────────────────────

void showFilterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(filterNotifierProvider);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle.
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Contenido con scroll.
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.read(filterNotifierProvider.notifier).reset(),
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Tipo de combustible.
                  _SectionTitle(text: 'Tipo de combustible')
                      .animate(delay: 60.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 10),
                  Row(
                    children: FuelType.values.map((type) {
                      final isSelected = filter.fuelType == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOutCubic,
                          child: FilterChip(
                            label: Text(_fuelLabel(type)),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : null,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : null,
                            ),
                            onSelected: (_) => ref
                                .read(filterNotifierProvider.notifier)
                                .setFuelType(type),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 20),

                  // Precio máximo.
                  _SectionTitle(
                    text:
                        'Precio máximo: \$${filter.maxPrice.toStringAsFixed(0)}',
                  )
                      .animate(delay: 120.ms)
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.15),
                      inactiveTrackColor:
                          AppColors.primary.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: filter.maxPrice,
                      min: 15,
                      max: 35,
                      divisions: 20,
                      onChanged: (v) => ref
                          .read(filterNotifierProvider.notifier)
                          .setMaxPrice(v),
                    ),
                  ).animate(delay: 140.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),

                  // Switches.
                  _AnimatedSwitch(
                    label: 'Solo estaciones abiertas',
                    value: filter.onlyOpen,
                    delay: 180.ms,
                    onChanged: (_) => ref
                        .read(filterNotifierProvider.notifier)
                        .toggleOnlyOpen(),
                  ),
                  _AnimatedSwitch(
                    label: 'Ordenar por precio',
                    value: filter.sortByPrice,
                    delay: 220.ms,
                    onChanged: (_) => ref
                        .read(filterNotifierProvider.notifier)
                        .toggleSortByPrice(),
                  ),
                  const SizedBox(height: 24),

                  // Botón aplicar.
                  FilledButton.icon(
                    icon: const Icon(Icons.tune),
                    label: const Text('Aplicar filtros'),
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                      .animate(delay: 260.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fuelLabel(FuelType type) => switch (type) {
        FuelType.regular => 'Regular',
        FuelType.premium => 'Premium',
        FuelType.diesel => 'Diésel',
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
      );
}

class _AnimatedSwitch extends StatelessWidget {
  const _AnimatedSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.delay,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    ).animate(delay: delay).fadeIn(duration: 300.ms).slideX(
          begin: -0.05,
          end: 0,
          duration: 300.ms,
        );
  }
}
