import 'package:flutter_test/flutter_test.dart';
import 'package:reelo/main.dart';

void main() {
  testWidgets('App loads ReeloApp widget', (WidgetTester tester) async {
    await tester.pumpWidget(const ReeloApp());
    expect(find.byType(ReeloApp), findsOneWidget);
  });
}
