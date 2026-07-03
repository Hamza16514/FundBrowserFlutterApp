import 'package:flutter/material.dart';
import '../models/scheme_detail_model.dart';
import '../services/api_service.dart';

class SchemeDetailViewModel extends ChangeNotifier {
  final ApiService _apiService;

  SchemeDetailViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SchemeDetailModel? _detail;
  SchemeDetailModel? get detail => _detail;

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

  /// Loads details for the given scheme.
  Future<void> loadDetails(int schemeCode, String schemeName) async {
    _detail = null; // Clear previous state to avoid showing flash of old data
    _setError(null);
    _setLoading(true);

    try {
      final rawDetail = await _apiService.fetchSchemeDetail(schemeCode);
      _detail = SchemeDetailModel.fromJson(rawDetail);
      _isOfflineMode = false;
      _setError(null);
    } catch (e) {
      print('SchemeDetailViewModel: Details request failed ($e). Loading mock fallback.');
      // If the API call fails (like 502 Bad Gateway from server or offline), load generated local mock data
      final rawDetail = ApiService.getOfflineDetail(schemeCode, schemeName);
      _detail = SchemeDetailModel.fromJson(rawDetail);
      _isOfflineMode = true;
      _setError(null); // Clear error because we successfully loaded cached data
    } finally {
      _setLoading(false);
    }
  }

  /// Processes mock investment transaction validation.
  /// Returns `true` on successful validation.
  Future<bool> invest(double amount) async {
    if (amount < 100.00) {
      return false;
    }
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }
}
