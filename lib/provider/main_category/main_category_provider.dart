import 'package:flutter/material.dart';

import '../../api/common/ps_resource.dart';
import '../../api/common/ps_status.dart';
import '../../config/ps_config.dart';
import '../../api/ps_api_service.dart';
import '../../repository/main_category_repository.dart';
import '../../utils/utils.dart';
import '../../utils/ps_progress_dialog.dart';
import '../../viewobject/category_model.dart';

class MainCategoryProvider extends ChangeNotifier {
  List<CategoryModel> thingsList = [];
  List<CategoryModel> servicesList = [];
  List<CategoryModel> propertyList = [];
  MainCategoryRepository repo;
  bool failedToLoadData = false;

  Future<bool> checkInternetConnectivity() async {
    return await Utils.checkInternetConnectivity();
  }

  Future<void> loadThings() async {
    bool network = await checkInternetConnectivity();
    if (network) {
      MainCategoryRepository repo = MainCategoryRepository(
        key: PsConfig.things,
        psApiService: PsApiService(),
      );
      final PsResource<List<CategoryModel>> list =
          await repo.getMainCategory(true, PsStatus.SUCCESS);

      if (list.status == PsStatus.SUCCESS && list.data.isNotEmpty) {
        thingsList = list.data;
      }
    } else {
      failedToLoadData = true;
    }
    notifyListeners();
  }

  Future<void> loadServices() async {
    bool network = await checkInternetConnectivity();
    if (network) {
      MainCategoryRepository repo = MainCategoryRepository(
        key: PsConfig.services,
        psApiService: PsApiService(),
      );
      final PsResource<List<CategoryModel>> list =
          await repo.getMainCategory(true, PsStatus.SUCCESS);

      if (list.status == PsStatus.SUCCESS && list.data.isNotEmpty) {
        servicesList = list.data;
      }
    } else {
      failedToLoadData = true;
    }
    notifyListeners();
  }

  Future<void> loadProperty() async {
    bool network = await checkInternetConnectivity();
    if (network) {
      MainCategoryRepository repo = MainCategoryRepository(
        key: PsConfig.property,
        psApiService: PsApiService(),
      );
      final PsResource<List<CategoryModel>> list =
          await repo.getMainCategory(true, PsStatus.SUCCESS);

      if (list.status == PsStatus.SUCCESS && list.data.isNotEmpty) {
        propertyList = list.data;
      }
    } else {
      failedToLoadData = true;
    }
    notifyListeners();
  }
}
