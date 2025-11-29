import '../entities/category.dart';

abstract class CategoryRepository {
  Stream<List<Category>> watchCategories();
  Future<List<Category>> getCategories();
  Future<void> addCategory(String name, String type);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
