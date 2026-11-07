import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laptop_browser/catalog.dart';
import 'package:laptop_browser/main.dart';

class LoadedCatalog extends CatalogRepository {
  final List<Laptop> data;
  LoadedCatalog(this.data);
  @override
  Future<List<Laptop>> load() async => data;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled catalog and strict API mapping', () async {
    final repository = CatalogRepository();
    final data = await repository.load();
    expect(data.length, 6);
    expect(data.first.priceLabel, '\$749.00');
    repository.close();
    expect(
      () => Laptop.fromJson({
        'id': 'x',
        'title': 'X',
        'description': 'd',
        'price': 1.2,
      }),
      throwsFormatException,
    );
  });
  test('failed and malformed remote responses propagate to retry UI', () async {
    final bad = CatalogRepository(
      baseUrl: 'https://example.test',
      client: MockClient((_) async => http.Response('Unavailable', 503)),
    );
    await expectLater(bad.load(), throwsException);
    bad.close();
    final malformed = CatalogRepository(
      baseUrl: 'https://example.test',
      client: MockClient((_) async => http.Response('{"items":[{}]}', 200)),
    );
    await expectLater(malformed.load(), throwsFormatException);
    malformed.close();
  });
  testWidgets('search, details and saving persist under a scoped key', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'unrelated.key': 'keep'});
    final data = await tester.runAsync(() => CatalogRepository().load());
    await tester.pumpWidget(LaptopApp(repository: LoadedCatalog(data!)));
    await tester.pumpAndSettle();
    expect(find.text('Find your next\nmachine.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Atlas');
    await tester.pumpAndSettle();
    expect(find.text('Atlas 14'), findsOneWidget);
    await tester.tap(find.text('Atlas 14'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save laptop'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Save laptop'));
    await tester.pumpAndSettle();
    expect(find.text('Remove from saved'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('laptop_browser.saved.v1'), ['atlas-14']);
    expect(prefs.getString('unrelated.key'), 'keep');
  });
}
