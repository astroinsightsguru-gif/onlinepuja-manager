import 'package:flutter_test/flutter_test.dart';
import 'package:onlinepuja_manager/main.dart';

void main() {
  testWidgets('OnlinePuja Manager smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OnlinePujaManagerApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(OnlinePujaManagerApp), findsOneWidget);
  });
}
