import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:first_app/main.dart';
import 'package:first_app/widgets/gradient_header.dart';
import 'package:first_app/widgets/custom_text_field.dart';
import 'package:first_app/widgets/primary_button.dart';

void main() {
  group('GradientHeader Widget Tests', () {
    testWidgets('Renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GradientHeader(
              title: 'Test Title',
              subtitle: 'Test Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
    });
  });

  group('CustomTextField Widget Tests', () {
    testWidgets('Renders label, hint and responds to input', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              labelText: 'Username',
              hintText: 'Enter username',
              prefixIcon: Icons.person,
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Enter username'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'john_doe');
      expect(controller.text, 'john_doe');
    });

    testWidgets('Toggles obscure text visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              labelText: 'Password',
              hintText: '••••••••',
              prefixIcon: Icons.lock,
              isPassword: true,
            ),
          ),
        ),
      );

      // Verify prefix icon and eye icon are present
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      // Tap visibility toggle to reveal password
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  group('PrimaryButton Widget Tests', () {
    testWidgets('Displays text and triggers callback', (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });

    testWidgets('Shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Click Me',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginScreen Integration/Validation Tests', () {
    testWidgets('Triggers validation errors on blank fields', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(hasToken: false));

      // Click Sign In directly
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      // Check for validation error messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Triggers validation error on invalid email / short password', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(hasToken: false));

      // Enter invalid email and short password
      await tester.enterText(find.byType(TextFormField).at(0), 'invalidemail');
      await tester.enterText(find.byType(TextFormField).at(1), '1234');
      
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    });
  });
}
