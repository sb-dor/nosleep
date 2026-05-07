import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:no_sleep/src/feature/in_app_update/data/in_app_update_repository.dart';

part 'in_app_update_controller.freezed.dart';

@freezed
sealed class InAppUpdateState with _$InAppUpdateState {
  const factory InAppUpdateState.initial() = InAppUpdate$InitialState;

  const factory InAppUpdateState.checking() = InAppUpdate$CheckingState;

  const factory InAppUpdateState.notAvailable() = InAppUpdate$NotAvailableState;

  const factory InAppUpdateState.available(AppUpdateInfo updateInfo) = InAppUpdate$AvailableState;

  const factory InAppUpdateState.updating() = InAppUpdate$UpdatingState;

  const factory InAppUpdateState.completed() = InAppUpdate$CompletedState;

  const factory InAppUpdateState.error(String message) = InAppUpdate$ErrorState;
}

final class InAppUpdateController extends StateController<InAppUpdateState>
    with SequentialControllerHandler {
  InAppUpdateController({
    required final IInAppUpdateRepository inAppUpdateRepository,
    super.initialState = const InAppUpdateState.initial(),
  }) : _inAppUpdateRepository = inAppUpdateRepository;

  final IInAppUpdateRepository _inAppUpdateRepository;

  Future<void> checkForUpdate() => handle(() async {
    if (state is! InAppUpdate$InitialState) return;

    setState(const InAppUpdateState.checking());

    final updateInfo = await _inAppUpdateRepository.checkForUpdate();
    if (updateInfo == null || updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
      setState(const InAppUpdateState.notAvailable());
      return;
    }

    setState(InAppUpdateState.available(updateInfo));
  }, error: (error, stackTrace) async => setState(InAppUpdateState.error(error.toString())));

  Future<void> startUpdate() => handle(() async {
    setState(const InAppUpdateState.updating());

    await _inAppUpdateRepository.startFlexibleUpdate();
    await _inAppUpdateRepository.completeFlexibleUpdate();

    setState(const InAppUpdateState.completed());
  }, error: (error, stackTrace) async => setState(InAppUpdateState.error(error.toString())));
}
