
import 'package:flutter_test/flutter_test.dart';
import 'package:mobil_gelistirme_projesi/main.dart';

void main() {
  testWidgets('TechStore ana sayfası açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const TechStoreApp());

    expect(find.text('TechStore'), findsOneWidget);
    expect(find.text('Öne Çıkan Ürünler'), findsOneWidget);
  });
}
