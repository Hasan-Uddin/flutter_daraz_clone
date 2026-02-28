import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiService {
  static const _baseUrl = 'https://fakestoreapi.com';

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 200 | 201) {
      throw Exception('Login failed');
    }
    return jsonDecode(response.body)['token'];
  }

  Future<User> fetchUser(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/$id'));
    if (response.statusCode != 200) {
      throw Exception('Could not load user');
    }
    return User.fromJson(jsonDecode(response.body));
  }

  Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products'));
    if (response.statusCode != 200) {
      throw Exception('Could not load products');
    }
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/category/$category'),
    );
    if (response.statusCode != 200) {
      throw Exception('Could not load products');
    }
    final list = jsonDecode(response.body) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }
}
