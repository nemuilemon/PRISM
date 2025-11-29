// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryListController)
const categoryListControllerProvider = CategoryListControllerProvider._();

final class CategoryListControllerProvider
    extends $StreamNotifierProvider<CategoryListController, List<Category>> {
  const CategoryListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryListControllerHash();

  @$internal
  @override
  CategoryListController create() => CategoryListController();
}

String _$categoryListControllerHash() =>
    r'58784cfc1f0fc5eebc045cbf0e9e28ee31fbb1df';

abstract class _$CategoryListController
    extends $StreamNotifier<List<Category>> {
  Stream<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
