import 'package:flutter_test/flutter_test.dart';

import 'package:cosmic_facts/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CosmicFactsApp());
    expect(find.text('Cosmic Facts'), findsOneWidget);
  });
}
