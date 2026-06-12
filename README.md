# León Hoy — Entaltek

App de utilidad para León, Guanajuato que muestra gasolineras en tiempo real usando datos de la API gubernamental CNE (~180 estaciones). Desarrollada como pieza central del portafolio técnico de Entaltek.

## Stack

| Capa | Tecnología |
|------|------------|
| UI | Flutter 3 + Material 3 |
| Estado | Riverpod 2.0 (code gen) |
| Navegación | go_router (StatefulShellRoute) |
| Red | Dio + Retrofit |
| Mapas | Google Maps Flutter SDK |
| Storage seguro | flutter_secure_storage |
| Cache local | Hive |
| Errores | dartz (Either) |
| Animaciones | flutter_animate · animations (Material Motion) · shimmer |

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
│  AppTheme  │ AppPreferences  │ Failures (sealed class)  │
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

## Features implementados

### Fase 1 (base)
- **Auth**: login y registro con JWT, refresh automático en interceptor
- **Mapa**: Google Maps con marcadores coloreados por precio (verde/amarillo/rojo), FABs animados, card de estadísticas

### Fase 2 (esta iteración)
| Feature | Descripción |
|---------|-------------|
| **Splash** | CustomPainter con anillos expansivos + logo spring animation |
| **Onboarding** | 3 páginas con ilustraciones CustomPainter y parallax, indicador morfable píldora↔dot |
| **Favoritos** | Persistencia Hive, corazón bounce `AnimationController`, pantalla vacía con pulso |
| **Lista** | Shimmer loading, búsqueda live, staggered fadeIn+slideY, filtros aplicados |
| **Detalle** | SliverAppBar colapsable, `FuelPriceGauge` semicircular CustomPainter animado, barras comparativas `TweenAnimationBuilder` |
| **Filtros** | `DraggableScrollableSheet`, FilterChips animados, badge indicator en FAB |
| **StationCard** | `OpenContainer` (Material Container Transform), favorito con bounce |
| **Nav** | `AnimatedBottomNavBar` con píldora deslizante `easeOutBack` + escala de ícono |
| **Conectividad** | `AnimatedContainer` slide-in automático cuando offline |

---

## Comandos

### Generar código (build_runner)

```bash
# Una sola vez
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch durante desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs
```

Los archivos generados (`*.g.dart`, `*.freezed.dart`) **no se commitean** — están en `.gitignore`.

### Correr tests

```bash
flutter test
```

### Correr la app

```bash
flutter run
```

> **Nota:** Requiere la API Key de Google Maps en:
> - Android: `android/app/src/main/AndroidManifest.xml` (meta-data `com.google.android.geo.API_KEY`)
> - iOS: `ios/Runner/AppDelegate.swift` (`GMSServices.provideAPIKey`)

---

## Flujo de navegación

```
/  (Splash)
├── /onboarding          ← primer install (flag en Hive)
├── /login               ← sin token
├── /register
└── /home/*              ← con token (StatefulShellRoute)
    ├── /home/map        ← tab 0
    ├── /home/list       ← tab 1
    └── /home/favorites  ← tab 2
```

---

## Variables de entorno / configuración

| Variable | Descripción |
|----------|-------------|
| `GOOGLE_MAPS_API_KEY` | API Key de Google Maps |
| API base URL | `lib/core/network/dio_client.dart` → `_baseUrl` |

---

## Créditos

Desarrollado por **Entaltek** como base técnica para proyectos Flutter senior.
