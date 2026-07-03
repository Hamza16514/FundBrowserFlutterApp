import 'package:flutter/material.dart';
import '../models/scheme_model.dart';
import '../services/api_service.dart';

class SchemeListViewModel extends ChangeNotifier {
  final ApiService _apiService;

  SchemeListViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SchemeModel> _allSchemes = [];
  List<SchemeModel> _filteredSchemes = [];
  List<SchemeModel> get schemes => _filteredSchemes;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadSchemes() async {
    _setError(null);
    _setLoading(true);

    try {
      final rawList = await _apiService.fetchSchemes();
      _allSchemes = rawList.map((json) => SchemeModel.fromJson(json)).toList();
      _isOfflineMode = false;
      _applyFilters();
      _setError(null);
    } catch (e) {
      print('SchemeListViewModel: Network request failed ($e). Loading offline cache.');
      // If the API call fails or times out, load the offline cached list
      final cachedList = ApiService.offlineCache;
      _allSchemes = cachedList.map((json) => SchemeModel.fromJson(json)).toList();
      _isOfflineMode = true;
      _applyFilters();
      _setError(null); // Clear error because we successfully loaded offline cache data
    } finally {
      _setLoading(false);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<SchemeModel> temp = _allSchemes;

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      temp = temp
          .where((scheme) =>
              scheme.schemeName.toLowerCase().contains(query) ||
              scheme.schemeCode.toString().contains(query))
          .toList();
    }

    if (_selectedCategory != 'All') {
      temp = temp
          .where((scheme) =>
              scheme.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    _filteredSchemes = temp;
    notifyListeners();
  }

  Future<void> refreshSchemes() async {
    await loadSchemes();
  }
}
