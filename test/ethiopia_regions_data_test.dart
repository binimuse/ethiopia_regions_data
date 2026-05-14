import 'package:ethiopia_regions_data/ethiopia_regions_data.dart';
import 'package:test/test.dart';

void main() {
  group('EthiopiaRegionsData', () {
    late EthiopiaRegionsData data;

    setUpAll(() async {
      data = await EthiopiaRegionsData.load();
    });

    test('getRegions returns sorted regions', () {
      final regions = data.getRegions();
      expect(regions, isNotEmpty);
      final names = regions.map((r) => r.name).toList();
      final sorted = [...names]..sort();
      expect(names, orderedEquals(sorted));
    });

    test('getZones filters by region id', () {
      final zones = data.getZones('oromia');
      expect(zones, isNotEmpty);
      expect(zones.every((z) => z.regionId == 'oromia'), isTrue);
    });

    test('getZones resolves region name case-insensitively', () {
      final byName = data.getZones('OROMIA');
      final byId = data.getZones('oromia');
      expect(byName.map((z) => z.id), equals(byId.map((z) => z.id)));
    });

    test('getWoredas filters by zone id', () {
      final woredas = data.getWoredas('aa_gulele_subcity');
      expect(woredas, isNotEmpty);
      expect(
        woredas.every((w) => w.zoneId == 'aa_gulele_subcity'),
        isTrue,
      );
    });

    test('Sheger zone uses sub-city tier and getWoredas filters by subCity',
        () {
      final zones = data.getZones('oromia');
      final sheger = zones.firstWhere((z) => z.id == 'oro_sheger');
      expect(EthiopiaRegionsData.zoneUsesSubCityPicker(sheger), isTrue);
      final subs = data.getSubCities('oro_sheger');
      expect(subs, contains('Mana Abichu'));
      final mana = data.getWoredas('oro_sheger', subCity: 'Mana Abichu');
      expect(mana.length, 2);
      expect(mana.map((w) => w.name).toSet(), {'Tufa Muna', 'Akako'});
    });

    test('Bishoftu zone uses sub-city tier', () {
      final zones = data.getZones('oromia');
      final bishoftu = zones.firstWhere((z) => z.id == 'oro_bishoftu');
      expect(EthiopiaRegionsData.zoneUsesSubCityPicker(bishoftu), isTrue);
      expect(data.getSubCities('oro_bishoftu'), contains('Dukem'));
      expect(
        data.getWoredas('oro_bishoftu', subCity: 'Dukem').length,
        4,
      );
    });

    test('getCities filters by region id', () {
      final cities = data.getCities('amhara');
      expect(cities, isNotEmpty);
      expect(cities.every((c) => c.regionId == 'amhara'), isTrue);
    });
  });

  group('EthiopiaRegionsData.fromJsonStrings', () {
    test('parses minimal embedded documents', () {
      final data = EthiopiaRegionsData.fromJsonStrings(
        regionsJson: '''
{"schemaVersion":1,"regions":[{"id":"r1","name":"Region One"}]}
''',
        zonesJson: '''
{"schemaVersion":1,"zones":[{"id":"z1","name":"Zone One","regionId":"r1"}]}
''',
        woredasJson: '''
{"schemaVersion":1,"woredas":[{"id":"w1","name":"Woreda One","zoneId":"z1"}]}
''',
        citiesJson: '''
{"schemaVersion":1,"cities":[{"id":"c1","name":"City One","regionId":"r1"}]}
''',
      );

      expect(data.getRegions().single.id, 'r1');
      expect(data.getZones('r1').single.id, 'z1');
      expect(data.getWoredas('z1').single.id, 'w1');
      expect(data.getCities('r1').single.id, 'c1');
    });
  });
}
