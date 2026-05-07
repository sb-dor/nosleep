import 'package:in_app_update/in_app_update.dart';

abstract interface class IInAppUpdateRepository {
  Future<AppUpdateInfo?> checkForUpdate();

  Future<void> startFlexibleUpdate();

  Future<void> completeFlexibleUpdate();
}

final class InAppUpdateRepositoryImpl implements IInAppUpdateRepository {
  const InAppUpdateRepositoryImpl();

  @override
  Future<AppUpdateInfo?> checkForUpdate() async {
    return InAppUpdate.checkForUpdate();
  }

  @override
  Future<void> startFlexibleUpdate() async {
    await InAppUpdate.startFlexibleUpdate();
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    await InAppUpdate.completeFlexibleUpdate();
  }
}
