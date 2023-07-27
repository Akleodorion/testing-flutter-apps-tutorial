import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

// Mock est une simulation d'un objet réel il remplace les dépendances externe à la fonction que l'on souhaite tester.
class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test('initial value are correct', () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('getArticles', () {
    final testValue = [
      Article(title: 'Test 1', content: 'Test 1 content'),
      Article(title: 'Test 2', content: 'Test 2 content'),
      Article(title: 'Test 3', content: 'Test 3 content')
    ];

    void arrangeNewsServiceReturns3articles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => testValue);
    }

    test(
      "gets articles using the newService",
      () async {
        arrangeNewsServiceReturns3articles();
        await sut.getArticles();
        // Vérification qu'un methode est appelée.
        verify(() => mockNewsService.getArticles()).called(1);
      },
    );

    test(
      """indicates loading of data,
      sets articles to the ones from the service,
      the data nobeing loaded anymore""",
      () async {
        // on arrage la valeur de get articles à vérifier ici on poste 3 articles
        arrangeNewsServiceReturns3articles();
        // On appel la fonction getArticle mais on ne l'attend pas car le process serait fini
        final future = sut.getArticles();
        // on verfie que loading est passé à vrai
        expect(sut.isLoading, true);
        // on attends que le process fini
        await future;
        // on s'attend a ce que sut.article soit égale aux valeur arbitraires
        expect(sut.articles, testValue);
        // on vérifie que le loading repasse a faux en fin de process
        expect(sut.isLoading, false);
      },
    );
  });
}
