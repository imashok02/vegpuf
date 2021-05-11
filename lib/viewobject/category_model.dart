import 'package:flutterbuyandsell/viewobject/common/ps_object.dart';
import 'package:quiver/core.dart';

class CategoryModel extends PsObject<CategoryModel> {
  final String id;
  final String name;
  final String status;
  final String mainCategoryId;
  final String addedDate;
  final String addedDateStr;

  CategoryModel({
    this.id,
    this.name,
    this.status,
    this.mainCategoryId,
    this.addedDate,
    this.addedDateStr,
  });


  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, status: $status, mainCategoryId: $mainCategoryId, addedDate: $addedDate, addedDateStr: $addedDateStr}';
  }

  @override
  bool operator ==(dynamic other) => other is CategoryModel && id == other.id;
  @override
  int get hashCode => hash2(id.hashCode, id.hashCode);

  @override
  CategoryModel fromMap(dynamic dynamicData) {
    if (dynamicData != null) {
      return CategoryModel(
          id: dynamicData['id'],
          name: dynamicData['name'],
          status: dynamicData['status'],
          mainCategoryId: dynamicData['main_cat_id'],
          addedDate: dynamicData['added_date'],
          addedDateStr: dynamicData['added_date_str'],
      );
    } else {
      return null;
    }
  }

  @override
  Map<String, dynamic> toMap(dynamic object) {
    if (object != null) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['id'] = object.id;
      data['name'] = object.name;
      data['status'] = object.status;
      data['main_cat_id'] = object.mainCategoryId;
      data['added_date'] = object.addedDate;
      data['added_date_str'] = object.addedDateStr;
      return data;
    } else {
      return null;
    }
  }

  @override
  List<CategoryModel> fromMapList(List<dynamic> dynamicDataList) {
    final List<CategoryModel> categoryModelList = <CategoryModel>[];

    if (dynamicDataList != null) {
      for (dynamic dynamicData in dynamicDataList) {
        if (dynamicData != null) {
          categoryModelList.add(fromMap(dynamicData));
        }
      }
    }
    return categoryModelList;
  }

  @override
  List<Map<String, dynamic>> toMapList(List<dynamic> objectList) {
    final List<Map<String, dynamic>> dynamicList = <Map<String, dynamic>>[];
    if (objectList != null) {
      for (dynamic data in objectList) {
        if (data != null) {
          dynamicList.add(toMap(data));
        }
      }
    }
    return dynamicList;
  }

  @override
  String getPrimaryKey() {
    return id;
  }

  @override
  List<String> getIdList(List<dynamic> mapList) {
    final List<String> idList = <String>[];
    if (mapList != null) {
      for (dynamic category in mapList) {
        if (category != null) {
          idList.add(category.categoryId);
        }
      }
    }
    return idList;
  }


}
