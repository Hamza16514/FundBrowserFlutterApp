import 'package:flutter_test/flutter_test.dart';
 // Wait, let's make sure the package name is first_app!
import 'package:first_app/models/scheme_model.dart';
import 'package:first_app/viewmodels/login_view_model.dart';
import 'package:first_app/viewmodels/scheme_list_view_model.dart';
import 'package:first_app/services/secure_storage_service.dart';
import 'package:first_app/services/api_service.dart';

// Mock implementation of SecureStorageService using memory map
class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _memoryStorage = {};

  @override
  Future<void> saveToken(String token) async {
    _memoryStorage['auth_token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _memoryStorage['auth_token'];
  }

  @override
  Future<void> deleteToken() async {
    _memoryStorage.remove('auth_token');
  }

  @override
  Future<bool> hasToken() async {
    return _memoryStorage.containsKey('auth_token');
  }

  @override
  Future<void> deleteEmail() {
    // TODO: implement deleteEmail
    throw UnimplementedError();
  }

  @override
  Future<String?> getEmail() {
    // TODO: implement getEmail
    throw UnimplementedError();
  }

  @override
  Future<void> saveEmail(String email) {
    // TODO: implement saveEmail
    throw UnimplementedError();
  }
}

// Mock implementation of ApiService
class MockApiService implements ApiService {
  final bool shouldFail;
  MockApiService({this.shouldFail = false});

  @override
  Future<List<dynamic>> fetchSchemes() async {
    if (shouldFail) {
      throw Exception('Connection timed out');
    }
    return [
      {'schemeCode': 100033, 'schemeName': 'Aditya Birla Large & Mid Cap', 'isinGrowth': 'INF1', 'isinDivReinvestment': null},
      {'schemeCode': 100119, 'schemeName': 'HDFC Balanced Advantage', 'isinGrowth': 'INF2', 'isinDivReinvestment': null},
      {'schemeCode': 100027, 'schemeName': 'Grindlays Saver Debt', 'isinGrowth': null, 'isinDivReinvestment': null},
      {'schemeCode': 100176, 'schemeName': 'quant Small Cap Equity', 'isinGrowth': 'INF3', 'isinDivReinvestment': 'INF4'},
    ];
  }

  @override
  Future<Map<String, dynamic>> fetchSchemeDetail(int schemeCode) {
    // TODO: implement fetchSchemeDetail
    throw UnimplementedError();
  }
}

void main() {
  group('LoginViewModel Unit Tests', () {
    late MockSecureStorageService mockStorage;
    late LoginViewModel viewModel;

    setUp(() {
      mockStorage = MockSecureStorageService();
      viewModel = LoginViewModel(storageService: mockStorage);
    });

    test('Initial states are clean', () {
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('Successful login stores token', () async {
      final success = await viewModel.login('user@example.com', 'password123');
      expect(success, true);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(await mockStorage.hasToken(), true);
    });

    test('Login validation error on empty fields', () async {
      final success = await viewModel.login('', '');
      expect(success, false);
      expect(viewModel.errorMessage, contains('cannot be empty'));
      expect(await mockStorage.hasToken(), false);
    });

    test('checkAutoLogin returns true when token is present', () async {
      expect(await viewModel.checkAutoLogin(), false);
      await mockStorage.saveToken('existing');
      expect(await viewModel.checkAutoLogin(), true);
    });

    test('logout deletes token', () async {
      await mockStorage.saveToken('token');
      expect(await mockStorage.hasToken(), true);
      await viewModel.logout();
      expect(await mockStorage.hasToken(), false);
    });
  });

  group('SchemeListViewModel Unit Tests', () {
    test('Load schemes success', () async {
      final mockApi = MockApiService();
      final viewModel = SchemeListViewModel(apiService: mockApi);

      expect(viewModel.isLoading, false);
      expect(viewModel.schemes.isEmpty, true);

      final futureLoad = viewModel.loadSchemes();
      expect(viewModel.isLoading, true);

      await futureLoad;
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      expect(viewModel.schemes.length, 4);
    });

    test('Load schemes failure updates error', () async {
      final mockApi = MockApiService(shouldFail: true);
      final viewModel = SchemeListViewModel(apiService: mockApi);

      await viewModel.loadSchemes();
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, 'Connection timed out');
      expect(viewModel.schemes.isEmpty, true);
    });

    test('Filter by Category works correctly', () async {
      final mockApi = MockApiService();
      final viewModel = SchemeListViewModel(apiService: mockApi);
      await viewModel.loadSchemes();

      // check category distribution based on model's formula:
      // 100033 % 4 = 1 -> Debt
      // 100119 % 4 = 3 -> Others (Hybrid/Others) -> 100119 % 4 = 3 -> Others
      // 100027 % 4 = 3 -> Others
      // 100176 % 4 = 0 -> Equity
      
      viewModel.setSelectedCategory('Equity');
      expect(viewModel.schemes.length, 1);
      expect(viewModel.schemes.first.schemeName, contains('quant Small Cap'));

      viewModel.setSelectedCategory('Debt');
      expect(viewModel.schemes.length, 1);
      expect(viewModel.schemes.first.schemeName, contains('Aditya Birla'));
    });

    test('Search query filters schemes correctly', () async {
      final mockApi = MockApiService();
      final viewModel = SchemeListViewModel(apiService: mockApi);
      await viewModel.loadSchemes();

      viewModel.setSearchQuery('HDFC');
      expect(viewModel.schemes.length, 1);
      expect(viewModel.schemes.first.schemeName, 'HDFC Balanced Advantage');

      viewModel.setSearchQuery('non-existent');
      expect(viewModel.schemes.isEmpty, true);
    });
  });
}
