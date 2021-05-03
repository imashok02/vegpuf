import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterbuyandsell/api/common/ps_resource.dart';
import 'package:flutterbuyandsell/api/common/ps_status.dart';
import 'package:flutterbuyandsell/api/ps_api_service.dart';
import 'package:flutterbuyandsell/viewobject/category_model.dart';

import 'Common/ps_repository.dart';

class MainCategoryRepository extends PsRepository {
  MainCategoryRepository(
      {@required PsApiService psApiService, @required String key}) {
    _psApiService = psApiService;
    _key = key;
  }

  String primaryKey = '';
  PsApiService _psApiService;
  String _key;

  Future<PsResource<List<CategoryModel>>> getMainCategory(
      bool isConnectedToInternet, PsStatus status,
      {bool isLoadFromServer = true}) async {
    final PsResource<List<CategoryModel>> _resource =
        await _psApiService.getCategories(_key);
    if (_resource.status == PsStatus.SUCCESS) {
      return _resource;
    } else
      return null;
  }
}
