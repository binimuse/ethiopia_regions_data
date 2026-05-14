import 'dart:convert';

import 'package:ethiopia_regions_data/src/services/data_loader.dart';
import 'package:ethiopia_regions_data/src/models/city.dart';
import 'package:ethiopia_regions_data/src/models/region.dart';
import 'package:ethiopia_regions_data/src/models/woreda.dart';
import 'package:ethiopia_regions_data/src/models/zone.dart';

/// Ethiopian administrative catalog backed by structured JSON datasets.
///
/// * **Dart VM** (tests, `dart run`, server-side Dart): use
///   [EthiopiaRegionsData.load] to read the bundled JSON from disk.
/// * **Flutter apps** (Android, iOS, Web, and most UI targets): use
///   [EthiopiaRegionsData.fromJsonStrings] with JSON loaded from
///   [DefaultAssetBundle] / `rootBundle` (or a remote API). Do not use [load]
///   in Flutter embedders: `Isolate.resolvePackageUri` is unsupported there.
/// * Some zones (for example Oromia **Sheger** and **Bishoftu**) use
///   [EthiopiaRegionsData.zoneUsesSubCityPicker], [getSubCities], and
///   [getWoredas] with `subCity:` for a fourth picker tier.
class EthiopiaRegionsData {
  EthiopiaRegionsData._({
    required List<Region> regions,
    required List<Zone> zones,
    required List<Woreda> woredas,
    required List<City> cities,
  })  : _regions = List<Region>.unmodifiable(regions),
        _zones = List<Zone>.unmodifiable(zones),
        _woredas = List<Woreda>.unmodifiable(woredas),
        _cities = List<City>.unmodifiable(cities) {
    _indexRegions();
    _indexZones();
  }

  final List<Region> _regions;
  final List<Zone> _zones;
  final List<Woreda> _woredas;
  final List<City> _cities;

  late final Map<String, Region> _regionByIdLower = {};
  late final Map<String, String> _regionIdByNameLower = {};
  late final Map<String, Zone> _zoneByIdLower = {};
  late final Map<String, List<Zone>> _zonesByNameLower = {};

  void _indexRegions() {
    for (final region in _regions) {
      final idKey = region.id.trim().toLowerCase();
      _regionByIdLower[idKey] = region;
      final nameKey = region.name.trim().toLowerCase();
      _regionIdByNameLower.putIfAbsent(nameKey, () => region.id);
    }
  }

  void _indexZones() {
    for (final zone in _zones) {
      final idKey = zone.id.trim().toLowerCase();
      _zoneByIdLower[idKey] = zone;
      final nameKey = zone.name.trim().toLowerCase();
      (_zonesByNameLower[nameKey] ??= <Zone>[]).add(zone);
    }
  }

  /// Loads datasets from the package's `lib/src/data` JSON files.
  ///
  /// Uses `Isolate.resolvePackageUri` and `dart:io` file reads. This works on
  /// the **standalone Dart VM** (for example `dart test` and command-line
  /// tools). It does **not** work inside **Flutter** on Android/iOS (and is
  /// unsuitable for Flutter apps in general). Flutter callers should use
  /// [EthiopiaRegionsData.fromJsonStrings] with assets loaded via
  /// `rootBundle`.
  static Future<EthiopiaRegionsData> load() async {
    final regionsJson = await readPackageDatasetFile('src/data/regions.json');
    final zonesJson = await readPackageDatasetFile('src/data/zones.json');
    final woredasJson = await readPackageDatasetFile('src/data/woredas.json');
    final citiesJson = await readPackageDatasetFile('src/data/cities.json');

    return EthiopiaRegionsData.fromJsonStrings(
      regionsJson: regionsJson,
      zonesJson: zonesJson,
      woredasJson: woredasJson,
      citiesJson: citiesJson,
    );
  }

  /// Parses datasets from raw JSON strings.
  ///
  /// Use this for **Flutter** (all platforms, via `rootBundle` or
  /// [DefaultAssetBundle]), tests, and any environment where package files are
  /// not resolvable through the VM file APIs used by [load].
  factory EthiopiaRegionsData.fromJsonStrings({
    required String regionsJson,
    required String zonesJson,
    required String woredasJson,
    required String citiesJson,
  }) {
    final regionsDoc = jsonDecode(regionsJson) as Map<String, dynamic>;
    final zonesDoc = jsonDecode(zonesJson) as Map<String, dynamic>;
    final woredasDoc = jsonDecode(woredasJson) as Map<String, dynamic>;
    final citiesDoc = jsonDecode(citiesJson) as Map<String, dynamic>;

    final regions = (regionsDoc['regions'] as List<dynamic>)
        .map((dynamic e) => Region.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final zones = (zonesDoc['zones'] as List<dynamic>)
        .map((dynamic e) => Zone.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final woredas = (woredasDoc['woredas'] as List<dynamic>)
        .map((dynamic e) => Woreda.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final cities = (citiesDoc['cities'] as List<dynamic>)
        .map((dynamic e) => City.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    return EthiopiaRegionsData._(
      regions: regions,
      zones: zones,
      woredas: woredas,
      cities: cities,
    );
  }

  /// All regions from the loaded dataset, sorted by [Region.name].
  List<Region> getRegions() {
    final copy = List<Region>.from(_regions);
    copy.sort((a, b) => a.name.compareTo(b.name));
    return copy;
  }

  /// Zones for a given [region], matched by [Region.id] or [Region.name]
  /// (case-insensitive).
  ///
  /// Returns an empty list if [region] does not resolve.
  List<Zone> getZones(String region) {
    final regionId = _resolveRegionId(region);
    if (regionId == null) {
      return const <Zone>[];
    }
    final filtered =
        _zones.where((z) => z.regionId == regionId).toList(growable: false);
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  /// Whether [zone] is modeled with an extra **sub city** tier before woredas
  /// (for example Sheger and Bishoftu in Oromia: `metadata.subCityPicker`).
  static bool zoneUsesSubCityPicker(Zone zone) {
    return zone.metadata['subCityPicker'] == true;
  }

  /// Sorted unique sub-city labels under [zone], taken from
  /// `Woreda.metadata['subCity']` when present.
  ///
  /// Returns an empty list if [zone] does not resolve or has no such
  /// metadata.
  List<String> getSubCities(String zone) {
    final zoneIds = _resolveZoneIds(zone);
    if (zoneIds.isEmpty) {
      return const <String>[];
    }
    final idSet = zoneIds.toSet();
    final subs = <String>{};
    for (final w in _woredas) {
      if (!idSet.contains(w.zoneId)) {
        continue;
      }
      final v = w.metadata['subCity'];
      if (v is String && v.trim().isNotEmpty) {
        subs.add(v.trim());
      }
    }
    final list = subs.toList()..sort();
    return list;
  }

  /// Woredas for a given [zone], matched by [Zone.id] or [Zone.name]
  /// (case-insensitive).
  ///
  /// If [subCity] is set, only woredas whose `metadata['subCity']` equals
  /// [subCity] are returned (same string as from [getSubCities]).
  ///
  /// If multiple zones share the same name in different regions, woredas for
  /// all matching zones are returned.
  ///
  /// Returns an empty list if [zone] does not resolve.
  List<Woreda> getWoredas(String zone, {String? subCity}) {
    final zoneIds = _resolveZoneIds(zone);
    if (zoneIds.isEmpty) {
      return const <Woreda>[];
    }
    final idSet = zoneIds.toSet();
    var filtered =
        _woredas.where((w) => idSet.contains(w.zoneId)).toList(growable: false);
    if (subCity != null) {
      filtered = filtered
          .where((w) => w.metadata['subCity'] == subCity)
          .toList(growable: false);
    }
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  /// Cities for a given [region], matched by [Region.id] or [Region.name]
  /// (case-insensitive).
  ///
  /// Returns an empty list if [region] does not resolve.
  List<City> getCities(String region) {
    final regionId = _resolveRegionId(region);
    if (regionId == null) {
      return const <City>[];
    }
    final filtered =
        _cities.where((c) => c.regionId == regionId).toList(growable: false);
    filtered.sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  String? _resolveRegionId(String region) {
    final key = region.trim().toLowerCase();
    if (key.isEmpty) {
      return null;
    }
    final byId = _regionByIdLower[key];
    if (byId != null) {
      return byId.id;
    }
    return _regionIdByNameLower[key];
  }

  List<String> _resolveZoneIds(String zone) {
    final key = zone.trim().toLowerCase();
    if (key.isEmpty) {
      return const <String>[];
    }
    final byId = _zoneByIdLower[key];
    if (byId != null) {
      return <String>[byId.id];
    }
    final byName = _zonesByNameLower[key];
    if (byName == null || byName.isEmpty) {
      return const <String>[];
    }
    return byName.map((z) => z.id).toList(growable: false);
  }
}
