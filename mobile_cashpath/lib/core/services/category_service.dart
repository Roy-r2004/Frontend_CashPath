import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_cashpath/models/category_model.dart';
import 'package:mobile_cashpath/config/api_endpoints.dart';

class CategoryService {
  final http.Client client = http.Client();

  // ✅ Get All Categories (With Optional Filtering)
  Future<List<Category>> getCategories(String token) async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.categories),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['categories'];
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // ✅ Get a Single Category by ID
  Future<Category> getCategoryById(String id) async {
    final response = await client.get(Uri.parse(ApiEndpoints.categoryDetails(id)));

    if (response.statusCode == 200) {
      return Category.fromJson(jsonDecode(response.body)['category']);
    } else {
      throw Exception("Category not found");
    }
  }

  // ✅ Create a New Category
  Future<Category> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
    String? parentId,
  }) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.categories),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "type": type,
        "icon": icon ?? "",
        "color": color ?? "",
        "parent_id": parentId,
      }),
    );

    if (response.statusCode == 201) {
      return Category.fromJson(jsonDecode(response.body)['category']);
    } else {
      throw Exception("Failed to create category");
    }
  }

  // ✅ Delete a Category
  Future<bool> deleteCategory(String id) async {
    final response = await client.delete(Uri.parse(ApiEndpoints.categoryDetails(id)));

    return response.statusCode == 200;
  }
}
