import 'package:ethiopia_regions_data/ethiopia_regions_data.dart';
import 'package:ethiopia_regions_data_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders cascading pickers', (WidgetTester tester) async {
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

    await tester.pumpWidget(EthiopiaRegionsExampleApp(data: data));
    await tester.pumpAndSettle();

    expect(find.text('Ethiopia location pickers'), findsOneWidget);
    expect(find.text('Region'), findsOneWidget);
  });
}
