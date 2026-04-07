import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders StockFlow label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('StockFlow')),
        ),
      ),
    );

    expect(find.text('StockFlow'), findsOneWidget);
  });
}
