import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductViewModel extends ChangeNotifier {
  final ApiService _api;
  ProductViewModel(this._api);

  // The 3 tabs and their corresponding API categories.
  static const tabs = ['All', 'Electronics', 'Jewelery', "women's clothing"];
  static const categories = [
    null,
    'electronics',
    'jewelery',
    "women's clothing",
  ];

  int selectedTab = 0;
  bool isLoading = false;
  String? errorMessage;

  // Cache: tab index → list of products
  // This means switching tabs is instant after first load.
  final Map<int, List<Product>> _cache = {};

  List<Product> get products => _cache[selectedTab] ?? [];

  // Called once when the home screen opens
  Future<void> loadAll() async {
    for (int i = 0; i < tabs.length; i++) {
      await _loadTab(i);
    }
  }

  // Called when user taps a tab or swipes
  Future<void> switchTab(int index) async {
    selectedTab = index;
    notifyListeners(); // update tab bar highlight immediately

    if (!_cache.containsKey(index)) {
      await _loadTab(index);
    }
  }

  // Called on pull-to-refresh, clears cache for current tab only
  Future<void> refresh() async {
    _cache.remove(selectedTab);
    await _loadTab(selectedTab);
  }

  Future<void> _loadTab(int index) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final category = categories[index];
      _cache[index] = category == null
          ? await _api.fetchAllProducts()
          : await _api.fetchProductsByCategory(category);
    } catch (e) {
      errorMessage = 'Failed to load products. Check your connection.';
    }

    isLoading = false;
    notifyListeners();
  }
}
