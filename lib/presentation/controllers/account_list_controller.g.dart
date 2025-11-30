// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountListController)
const accountListControllerProvider = AccountListControllerProvider._();

final class AccountListControllerProvider
    extends $StreamNotifierProvider<AccountListController, List<Asset>> {
  const AccountListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountListControllerHash();

  @$internal
  @override
  AccountListController create() => AccountListController();
}

String _$accountListControllerHash() =>
    r'40036a15a5ac3db5f9b26f1399f5ca6cbfb95523';

abstract class _$AccountListController extends $StreamNotifier<List<Asset>> {
  Stream<List<Asset>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Asset>>, List<Asset>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Asset>>, List<Asset>>,
              AsyncValue<List<Asset>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
