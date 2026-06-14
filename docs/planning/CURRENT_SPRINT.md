# Sprint 11 – Real Map Integration (OSM) — **Completed**

## Sprint Goal

Replace the current mock map with a real interactive map using OpenStreetMap.

The application must preserve the current EVCharge design language while providing a functional map experience.

---

## In Scope

### Map Infrastructure

* FlutterMap integration
* OpenStreetMap tiles
* Map service abstraction layer
* Configurable tile source

### Interactive Map

* Pan
* Zoom
* Recenter button
* Camera movement

### Station Markers

* Available stations (green)
* Limited stations (orange)
* Occupied stations (red)

### Station Selection

* Tap marker
* Open existing station details sheet
* Preserve current station interactions

### Performance

* Efficient marker rendering
* Preparation for clustering

### Localization

* Persian-first
* RTL support

### Accessibility

* Marker semantics
* Screen reader labels

### Future Readiness

Map provider abstraction for future migration to:

* Neshan
* Balad
* Self-hosted tile server
* Offline tiles

---

## Out of Scope

* Routing / navigation
* Turn-by-turn directions
* Traffic data
* Live backend integration
* Real charger API integration
* Offline map storage

---

## Relevant Files

mobile/lib/features/map/**
mobile/lib/core/map/**
mobile/lib/core/router/**
mobile/lib/core/l10n/**

---

## Acceptance Criteria

* Mock map removed
* Interactive OSM map visible
* Station markers visible
* Marker tap works
* Station detail sheet works
* Existing filters preserved
* Existing search preserved
* Existing wallet chip preserved
* Existing notification button preserved
* Mock map removed
* Interactive OSM map visible ✅
* Station markers visible ✅ (green/orange/red by availability)
* Marker tap works ✅
* Station detail sheet works ✅ (compact + expanded)
* Reserve button → 3-step flow → success ✅
* Existing filters preserved ✅
* Existing search preserved ✅
* Existing wallet chip preserved ✅
* Existing notification button preserved ✅
* flutter analyze passes ✅ (No issues found)
* Android build passes ✅
* APK launches successfully ✅

## Implementation Notes

* `mobile/lib/core/map/tile_provider_config.dart` — abstract tile contract; `OsmDarkTileConfig` (CartoDB DarkMatter) + `OsmStandardTileConfig`
* `mobile/lib/core/map/map_service.dart` — `MapService` abstract class; `OsmMapService` default; `mapServiceProvider` Riverpod provider
* `mobile/lib/main.dart` — `_DebugProxyOverrides` routes Dart `HttpClient` through `tools/tile_proxy.py` on host (`10.0.2.2:8888`) — active only in `kDebugMode && Platform.isAndroid`; tiles were blocked by GFW on emulator
* `tools/tile_proxy.py` — threaded HTTPS CONNECT proxy (Python); run on host before emulator session when tile servers are GFW-blocked
