import 'package:prism/data/repositories/category_repository_impl.dart';
import 'package:prism/domain/entities/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_list_controller.g.dart';

@riverpod
class CategoryListController extends _$CategoryListController {
  @override
  Stream<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).watchCategories();
  }

  Future<void> addCategory(String name, String type) async {
    await ref.read(categoryRepositoryProvider).addCategory(name, type);
  }

  Future<void> updateCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).updateCategory(category);
  }

  Future<void> deleteCategory(int id) async {
    await ref.read(categoryRepositoryProvider).deleteCategory(id);
  }
}
