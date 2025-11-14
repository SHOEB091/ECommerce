// Basic Flutter widget test for the ecommerce app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/widgets/custom_textfield.dart';

void main() {
  testWidgets('CustomTextField widget test', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            controller: controller,
            hint: 'Enter text',
          ),
        ),
      ),
    );

    // Verify the hint text is displayed
    expect(find.text('Enter text'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Test input');
    expect(controller.text, equals('Test input'));
  });
}
