import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce/widgets/custom_textfield.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('should display hint text as label', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              hint: 'Enter your name',
            ),
          ),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });

    testWidgets('should update controller when text is entered', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              hint: 'Test',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      expect(controller.text, equals('test input'));
    });

    testWidgets('should have rounded border', (WidgetTester tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              hint: 'Test',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration as InputDecoration;
      expect(decoration.border, isA<OutlineInputBorder>());
    });
  });
}

