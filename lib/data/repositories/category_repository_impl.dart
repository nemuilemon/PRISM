import 'package:drift/drift.dart';
import 'package:prism/data/datasources/local/app_database.dart' as db;
import 'package:prism/domain/entities/category.dart' as domain;
import 'package:prism/domain/repositories/category_repository.dart';
import 'package:prism/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepositoryImpl(ref.watch(appDatabaseProvider));
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._db);

  final db.AppDatabase _db;

  @override
  Stream<List<domain.Category>> watchCategories() {
    return _db.select(_db.categories).watch().map((rows) {
      return rows.map(_toDomain).toList();
    });
  }

  @override
  Future<List<domain.Category>> getCategories() async {
    final rows = await _db.select(_db.categories).get();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<void> addCategory(String name, String type) async {
    await _db
        .into(_db.categories)
        .insert(
          db.CategoriesCompanion.insert(
            name: name,
            type: Value(type),
          ),
        );
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    await _db
        .update(_db.categories)
        .replace(
          db.CategoriesCompanion(
            id: Value(category.id),
            name: Value(category.name),
            type: Value(category.type),
          ),
        );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
  }

  domain.Category _toDomain(db.Category row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      type: row.type,
    );
  }
}
