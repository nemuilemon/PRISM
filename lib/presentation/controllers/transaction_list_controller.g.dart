// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionListController)
const transactionListControllerProvider = TransactionListControllerProvider._();

final class TransactionListControllerProvider
    extends
        $StreamNotifierProvider<TransactionListController, List<Transaction>> {
  const TransactionListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionListControllerHash();

  @$internal
  @override
  TransactionListController create() => TransactionListController();
}

String _$transactionListControllerHash() =>
    r'6549321054b7d9f82da6ea63304f07a970d695db';

abstract class _$TransactionListController
    extends $StreamNotifier<List<Transaction>> {
  Stream<List<Transaction>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Transaction>>, List<Transaction>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Transaction>>, List<Transaction>>,
              AsyncValue<List<Transaction>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
