import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoryimageproject/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shows login when no username is saved', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Memorimage'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Play Game'), findsNothing);
  });

  testWidgets('logs in and opens the main menu', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'Alya');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Halo, Alya'), findsOneWidget);
    expect(find.text('Play Game'), findsOneWidget);
  });

  test('maps correct answer counts to result titles', () {
    expect(titleForCorrectAnswers(5), "Maestro dell'Indovinello");
    expect(titleForCorrectAnswers(3), 'Abile Indovinatore');
    expect(titleForCorrectAnswers(0), 'Sfortunato Indovinatore');
  });
}
