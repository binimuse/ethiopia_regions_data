# ethiopia_regions_data

[![pub package](https://img.shields.io/pub/v/ethiopia_regions_data.svg)](https://pub.dev/packages/ethiopia_regions_data)

Pure Dart (dependency-free) Ethiopian administrative location data for
**regions**, **zones**, **woredas**, and **cities**, backed by structured JSON
files shipped with the package.

> **Data disclaimer:** Administrative boundaries and names change over time.
> The bundled JSON is maintained for apps and forms, but you should still
> validate against your own authoritative sources for compliance-critical use.

## Features

* Null-safe Dart 3 API with documented public members
* JSON datasets under `lib/src/data/` (easy to extend or replace)
* Models include optional `nameAm` and a `metadata` map for future fields
  (Amharic labels, kebeles, geolocation, search tokens, and so on)
* Dart VM loading via [EthiopiaRegionsData.load] (tests, CLI — not Flutter UI)
* Flutter-friendly loading via [EthiopiaRegionsData.fromJsonStrings] and
  `rootBundle` / assets on Android, iOS, Web, and desktop

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ethiopia_regions_data: ^0.2.0
```

## Usage

### Dart VM (tests, `dart run`, server-side)

```dart
import 'package:ethiopia_regions_data/ethiopia_regions_data.dart';

Future<void> main() async {
  final data = await EthiopiaRegionsData.load();

  final regions = data.getRegions();
  final zones = data.getZones('oromia'); // id or name (case-insensitive)
  final woredas = data.getWoredas('oromia_east');
  final cities = data.getCities('oromia');
}
```

### Flutter (Android, iOS, Web, desktop)

`EthiopiaRegionsData.load()` uses `Isolate.resolvePackageUri` and **does not
work inside Flutter on Android/iOS** (and is not the right API for Flutter apps
in general). Register the package JSON as assets and load with `rootBundle`:

```yaml
# app pubspec.yaml
flutter:
  assets:
    - packages/ethiopia_regions_data/src/data/regions.json
    - packages/ethiopia_regions_data/src/data/zones.json
    - packages/ethiopia_regions_data/src/data/woredas.json
    - packages/ethiopia_regions_data/src/data/cities.json
```

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:ethiopia_regions_data/ethiopia_regions_data.dart';

Future<EthiopiaRegionsData> loadCatalog() async {
  final regionsJson = await rootBundle.loadString(
    'packages/ethiopia_regions_data/src/data/regions.json',
  );
  final zonesJson = await rootBundle.loadString(
    'packages/ethiopia_regions_data/src/data/zones.json',
  );
  final woredasJson = await rootBundle.loadString(
    'packages/ethiopia_regions_data/src/data/woredas.json',
  );
  final citiesJson = await rootBundle.loadString(
    'packages/ethiopia_regions_data/src/data/cities.json',
  );

  return EthiopiaRegionsData.fromJsonStrings(
    regionsJson: regionsJson,
    zonesJson: zonesJson,
    woredasJson: woredasJson,
    citiesJson: citiesJson,
  );
}
```

## JSON schema

Each file contains a `schemaVersion` and a top-level array key:

* `regions.json` → `{ "schemaVersion": 1, "regions": [ ... ] }`
* `zones.json` → `{ "schemaVersion": 1, "zones": [ ... ] }`
* `woredas.json` → `{ "schemaVersion": 1, "woredas": [ ... ] }`
* `cities.json` → `{ "schemaVersion": 1, "cities": [ ... ] }`

Entities support optional `nameAm` and `metadata` objects without breaking the
parser.

## Example app

See the `example/` directory for a Flutter app with cascading dropdowns.

## Source

Repository: [github.com/binimuse/ethiopia_regions_data](https://github.com/binimuse/ethiopia_regions_data).

## License

See `LICENSE`.
