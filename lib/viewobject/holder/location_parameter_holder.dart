
import 'package:flutterbuyandsell/constant/ps_constants.dart';
import 'package:flutterbuyandsell/viewobject/common/ps_holder.dart';

class LocationParameterHolder extends PsHolder<dynamic> {
  LocationParameterHolder() {
    keyword = '';
    orderBy = PsConst.FILTERING__ADDED_DATE;
    orderType = PsConst.FILTERING__DESC;
    currentLocationDataMap = <String,dynamic>{};

  }

  String keyword;
  String orderBy;
  String orderType;
  Map<String,dynamic> currentLocationDataMap;

  LocationParameterHolder getDefaultParameterHolder() {
    
    keyword = '';
    orderBy = PsConst.FILTERING__ORDERING;
    orderType = PsConst.FILTERING__DESC;
    currentLocationDataMap = <String,dynamic>{};

    return this;
  }

  LocationParameterHolder getLatestParameterHolder() {
    keyword = '';
    orderBy = PsConst.FILTERING__ADDED_DATE;
    orderType = PsConst.FILTERING__DESC;
    currentLocationDataMap = <String,dynamic>{};

    return this;
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['keyword'] = keyword;
    map['order_by'] = orderBy;
    map['order_type'] = orderType;
    map['curr_location'] = currentLocationDataMap;

    return map;
  }

  @override
  dynamic fromMap(dynamic dynamicData) {
    keyword = '';
    orderBy = PsConst.FILTERING__ADDED_DATE;
    orderType = PsConst.FILTERING__DESC;
    currentLocationDataMap = <String,dynamic>{};

    return this;
  }

  @override
  String getParamKey() {
    String key = '';

    if (keyword != '') {
      key += keyword;
    }
    if (orderBy != '') {
      key += orderBy;
    }
    if (orderType != '') {
      key += orderType;
    }

    return key;
  }
}
