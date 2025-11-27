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
    extends $AsyncNotifierProvider<AccountListController, List<dynamic>> {
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
    r'77e0abebfac0451d0371c99d833def2353626d03';

abstract class _$AccountListController extends $AsyncNotifier<List<dynamic>> {
  FutureOr<List<dynamic>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<dynamic>>, List<dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<dynamic>>, List<dynamic>>,
              AsyncValue<List<dynamic>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
