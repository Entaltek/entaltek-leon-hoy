import 'package:equatable/equatable.dart';

class GasStation extends Equatable {
  const GasStation({
    required this.id,
    required this.name,
    required this.brand,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.regularPrice,
    required this.premiumPrice,
    required this.dieselPrice,
    required this.lastUpdated,
  });

  final String id;
  final String name;
  final String brand;
  final String address;
  final double latitude;
  final double longitude;
  final double regularPrice;
  final double premiumPrice;
  final double dieselPrice;
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        address,
        latitude,
        longitude,
        regularPrice,
        premiumPrice,
        dieselPrice,
        lastUpdated,
      ];
}
