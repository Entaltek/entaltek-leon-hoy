import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/gas_station.dart';

part 'gas_station_dto.g.dart';

@JsonSerializable()
class GasStationDto {
  const GasStationDto({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.precioRegular,
    required this.precioPremium,
    required this.precioDiesel,
    required this.fechaActualizacion,
  });

  factory GasStationDto.fromJson(Map<String, dynamic> json) =>
      _$GasStationDtoFromJson(json);

  final String id;
  final String nombre;
  final String marca;
  final String direccion;
  final double latitud;
  final double longitud;

  @JsonKey(name: 'precio_regular')
  final double precioRegular;

  @JsonKey(name: 'precio_premium')
  final double precioPremium;

  @JsonKey(name: 'precio_diesel')
  final double precioDiesel;

  @JsonKey(name: 'fecha_actualizacion')
  final String fechaActualizacion;

  Map<String, dynamic> toJson() => _$GasStationDtoToJson(this);

  GasStation toDomain() => GasStation(
        id: id,
        name: nombre,
        brand: marca,
        address: direccion,
        latitude: latitud,
        longitude: longitud,
        regularPrice: precioRegular,
        premiumPrice: precioPremium,
        dieselPrice: precioDiesel,
        lastUpdated: DateTime.parse(fechaActualizacion),
      );
}
