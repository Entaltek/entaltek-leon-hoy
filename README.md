# León Hoy — Entaltek

App de utilidad para León, Guanajuato que muestra gasolineras en tiempo real usando datos de la API gubernamental CNE (~180 estaciones). Desarrollada como pieza central del portafolio técnico de Entaltek.

## Stack

| Capa | Tecnología |
|------|------------|
| UI | Flutter 3 + Material 3 |
| Estado | Riverpod 2.0 (code gen) |
| Navegación | go_router |
| Red | Dio + Retrofit |
| Mapas | Google Maps Flutter SDK |
| Storage seguro | flutter_secure_storage |
| Cache local | Hive |
| Errores | dartz (Either) |

---

## Arquitectura de capas

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  ConsumerWidget ──► StateNotifier ──► sealed UiState    │
│  (Screens / Widgets)   (Riverpod)    (Initial/Loading/  │
│                                       Success/Error)     │
└────────────────────────┬────────────────────────────────┘
                         │ llama
┌────────────────────────▼────────────────────────────────┐
│                      DOMAIN                              │
│   UseCase ──► Repository (abstract) ──► Entity          │
│   (puro Dart, sin Flutter ni paquetes de infra)         │
│   Retorna: Either<Failure, T>                           │
└────────────────────────┬────────────────────────────────┘
                         │ implementa
┌────────────────────────▼────────────────────────────────┐
│                       DATA                               │
│  RepositoryImpl ──► RemoteDataSource ──► DTO            │
│                  └► LocalDataSource     .toDomain()     │
│                     (Hive cache)                        │
└─────────────────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────┐
│                      CORE                                │
│  DioClient │ AuthInterceptor │ SecureStorage │ Router   │
│  AppTheme  │ Failures (sealed class)                    │
└─────────────────────────────────────────────────────────┘
```

### Regla de dependencias

```
Presentation → Domain ← Data
      ↓                   ↓
     Core ←──────────── Core
```

Domain **nunca** importa hacia arriba ni hacia Data.

---

## Comandos

### Generar código (build_runner)

```bash
# Una sola vez
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch durante desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs
```

Los archivos generados (`*.g.dart`, `*.freezed.dart`) **no se commitean** — agrégalos a `.gitignore`.

### Correr tests

```bash
flutter test
```

### Correr la app

```bash
flutter run
```

> **Nota:** Requiere agregar la API Key de Google Maps en `android/app/src/main/AndroidManifest.xml` y `ios/Runner/AppDelegate.swift` antes de correr.

---

## Variables de entorno / configuración

| Variable | Descripción |
|----------|-------------|
| `GOOGLE_MAPS_API_KEY` | API Key de Google Maps |
| API base URL | Definida en `lib/core/network/dio_client.dart` → `_baseUrl` |

---

## Estructura de carpetas

```
lib/
├── core/           # Infraestructura transversal
│   ├── error/      # sealed class Failure
│   ├── network/    # Dio + AuthInterceptor
│   ├── storage/    # SecureStorage (tokens)
│   ├── router/     # go_router con guard de auth
│   └── theme/      # Paleta Entaltek + Sansation
└── features/
    ├── auth/       # Login / Registro
    └── gas_stations/ # Mapa de gasolineras CNE
```

---

## Créditos

Desarrollado por **Entaltek** como base técnica para proyectos Flutter senior.
