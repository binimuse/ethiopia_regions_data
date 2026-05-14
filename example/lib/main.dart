import 'package:ethiopia_regions_data/ethiopia_regions_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await _loadEthiopiaRegionsData();
  runApp(EthiopiaRegionsExampleApp(data: data));
}

/// Loads JSON via [rootBundle] on every platform.
///
/// [EthiopiaRegionsData.load] uses `Isolate.resolvePackageUri`, which is not
/// supported inside Flutter on Android/iOS (and is unreliable in Flutter apps
/// in general). Declaring these paths under `flutter: assets:` and using
/// `rootBundle` is the supported approach for Flutter.
Future<EthiopiaRegionsData> _loadEthiopiaRegionsData() async {
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

/// Chartered administrations that use **sub cities** instead of zones in the UI.
bool _regionUsesSubcityLabel(Region region) {
  return region.id == 'addis_ababa';
}

/// Demo Flutter app for cascading administrative pickers.
class EthiopiaRegionsExampleApp extends StatelessWidget {
  /// Creates the example app with preloaded [data].
  const EthiopiaRegionsExampleApp({required this.data, super.key});

  /// Administrative catalog used by the demo screens.
  final EthiopiaRegionsData data;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethiopia Regions Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: LocationPickerPage(data: data),
    );
  }
}

/// Demonstrates region, zone, and woreda dropdowns backed by the package API.
class LocationPickerPage extends StatefulWidget {
  /// Creates a page bound to [data].
  const LocationPickerPage({required this.data, super.key});

  /// Administrative catalog for lookups.
  final EthiopiaRegionsData data;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  Region? _region;
  Zone? _zone;
  String? _subCity;
  Woreda? _woreda;

  @override
  Widget build(BuildContext context) {
    final regions = widget.data.getRegions();
    final zones =
        _region == null ? const <Zone>[] : widget.data.getZones(_region!.id);
    final subCityNames =
        _zone == null ? const <String>[] : widget.data.getSubCities(_zone!.id);
    final useSubCityTier = _zone != null &&
        EthiopiaRegionsData.zoneUsesSubCityPicker(_zone!) &&
        subCityNames.isNotEmpty;
    final woredas = _zone == null
        ? const <Woreda>[]
        : useSubCityTier
            ? (_subCity == null
                ? const <Woreda>[]
                : widget.data.getWoredas(_zone!.id, subCity: _subCity))
            : widget.data.getWoredas(_zone!.id);

    final cities =
        _region == null ? const <City>[] : widget.data.getCities(_region!.id);

    final secondLevelLabel =
        _region != null && _regionUsesSubcityLabel(_region!)
            ? 'Sub city'
            : 'Zone';

    return Scaffold(
      appBar: AppBar(title: const Text('Ethiopia location pickers')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Sample data is provided for development and testing. '
              '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _LabeledDropdown<Region>(
              label: 'Region',
              value: _region,
              items: regions,
              itemLabel: (r) => r.name,
              onChanged: (value) {
                setState(() {
                  _region = value;
                  _zone = null;
                  _subCity = null;
                  _woreda = null;
                });
              },
            ),
            const SizedBox(height: 12),
            _LabeledDropdown<Zone>(
              label: secondLevelLabel,
              value: _zone,
              items: zones,
              enabled: _region != null,
              itemLabel: (z) => z.name,
              onChanged: (value) {
                setState(() {
                  _zone = value;
                  _subCity = null;
                  _woreda = null;
                });
              },
            ),
            if (useSubCityTier) ...[
              const SizedBox(height: 12),
              _LabeledDropdown<String>(
                label: 'Sub city',
                value: _subCity,
                items: subCityNames,
                enabled: _zone != null,
                itemLabel: (s) => s,
                onChanged: (value) {
                  setState(() {
                    _subCity = value;
                    _woreda = null;
                  });
                },
              ),
            ],
            const SizedBox(height: 12),
            _LabeledDropdown<Woreda>(
              label: 'Woreda',
              value: _woreda,
              items: woredas,
              enabled: _zone != null && (!useSubCityTier || _subCity != null),
              itemLabel: (w) => w.name,
              onChanged: (value) {
                setState(() {
                  _woreda = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Text('Cities in selected region',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (cities.isEmpty)
              const Text('Select a region to list sample cities.')
            else
              ...cities.map(
                (c) => ListTile(
                  dense: true,
                  title: Text(c.name),
                  subtitle: Text('id: ${c.id}'),
                ),
              ),
            const SizedBox(height: 24),
            Text('Selection', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Region: ${_region?.name ?? "—"}\n'
              '$secondLevelLabel: ${_zone?.name ?? "—"}\n'
              '${useSubCityTier ? 'Sub city: ${_subCity ?? "—"}\n' : ''}'
              'Woreda: ${_woreda?.name ?? "—"}',
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(enabled ? 'Choose $label' : 'Select a region first'),
          onChanged: enabled ? onChanged : null,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
