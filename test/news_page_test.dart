import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

// Mock est une simulation d'un objet réel il remplace les dépendances externe à la fonction que l'on souhaite tester.
class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  final testValue = [
    Article(title: 'Test 1', content: 'Test 1 content'),
    Article(title: 'Test 2', content: 'Test 2 content'),
    Article(title: 'Test 3', content: 'Test 3 content')
  ];

  void arrangeNewsServiceReturns3articles() {
    when(() => mockNewsService.getArticles())
        .thenAnswer((_) async => testValue);
  }

  void arrangeNewsServiceReturns3articlesAfter2SecondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 2));
      return testValue;
    });
  }

  testWidgets(
    'title is displayed',
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3articles();
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('News'), findsOneWidget);
    },
  );
  testWidgets(
    "Loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3articlesAfter2SecondWait();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('progress-indicator')), findsOneWidget);

      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    "Articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3articles();
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));

      for (var articles in testValue) {
        expect(find.text(articles.title), findsOneWidget);
        expect(find.text(articles.content), findsOneWidget);
      }
    },
  );
}
