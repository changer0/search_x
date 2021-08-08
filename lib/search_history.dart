
import 'dart:convert';

import 'package:search_x/sp_util.dart';

/// SearchHistoryUtil.getHistory().then((value) => print("History: $value"));
/// SearchHistoryUtil.addHistory(SearchHistoryEntity(itemModel.url, itemModel.title));
class SearchHistoryEntity {
  String title = "";

  SearchHistoryEntity(this.title);

  factory SearchHistoryEntity.from(Map<String, dynamic> map) {
    return SearchHistoryEntity( map['title']);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title
    };
  }

  @override
  String toString() {
    return '{title: $title}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryEntity &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}

class SearchHistoryUtil {
  static Future<List<SearchHistoryEntity>?> addHistory(SearchHistoryEntity entity) {
    return Future<List<SearchHistoryEntity>?>(() async {
      String? value = await SearchHistoryUtil.getHistoryStr();
      print("SearchHistoryUtil 从 sp 中读取: $value");
      List<SearchHistoryEntity> list = [];
      if (value != null) {
        List<SearchHistoryEntity>? _list = decodeHistoryList(value);
        if (_list != null) {
          if (_list.contains(entity)) {
            _list.remove(entity);
          }
          list.addAll(_list);
        }
      }
      if (list.length >= 10) {
        list.removeRange(9, list.length);
      }
      list.insert(0, entity);
      //注意应使用 jsonEncode 进行 json 转义
      String saveStr = encodeHistoryList(list);
      print("saveStr: $saveStr");
      await SpUtil.setSearchHistory(saveStr);
      return list;
    });
  }

  static List<SearchHistoryEntity>? decodeHistoryList(String value) {
    try {
      if (value.isEmpty) return null;
      //解析json用到的model实体类，由于labelList是一个字符串集合数组，
      // 需要在解析labelList字段时加上cast<String>()
      //List<String> _list = json.decode(value).cast<String>();
      List _list = json.decode(value);
      List<SearchHistoryEntity> _retList = [];
      for (var v in _list) {
        _retList.add(SearchHistoryEntity.from(v));
      }
      return _retList;
    } catch (e) {
      SpUtil.setSearchHistory("");
      print("发生异常: $e, 清除搜索搜索历史");
    }
    return null;
  }

  static String encodeHistoryList(List<SearchHistoryEntity> _list) {
    List<dynamic> encodeList = [];
    for (var v in _list) {
      encodeList.add(v.toJson());
    }
    return json.encode(encodeList);
  }

  static Future<List<SearchHistoryEntity>> getHistory() async {
    String? str = await getHistoryStr();
    return Future((){
      List<SearchHistoryEntity> list = [];
      if (str == null) return list;
      List<SearchHistoryEntity>? _list = decodeHistoryList(str);
      if (_list != null) list.addAll(_list);
      return list;
    });
  }
  
  static Future<String?> getHistoryStr() {
    return SpUtil.getSearchHistory();
  }

  static Future clearHistory() {
    return SpUtil.setSearchHistory("");
  }

  static Future delHistory(SearchHistoryEntity entity) async {
    List<SearchHistoryEntity> list = await SearchHistoryUtil.getHistory();
    return Future((){
      list.remove(entity);
      SpUtil.setSearchHistory(encodeHistoryList(list));
    });
  }
}

///搜索历史辅助类
class SearchHistoryHelper {
  /// 搜索历史
  List<SearchHistoryEntity> searchHistoryList = [];

  /// 初始化搜索历史结果
  Future initHistoryList() {
    return SearchHistoryUtil.getHistory().then((value){
      print("SearchHistoryUtil result: $value");
      searchHistoryList.clear();
      searchHistoryList.addAll(value);
    });
  }

  int length() {
    return searchHistoryList.length;
  }

  Future addHistory(SearchHistoryEntity searchHistoryEntity) {
    return SearchHistoryUtil.addHistory(searchHistoryEntity).then((value) {
      if (value == null) return;
      searchHistoryList.clear();
      searchHistoryList.addAll(value);
    });
  }

  Future clearHistory() {
    return SearchHistoryUtil.clearHistory().then((value){
      searchHistoryList.clear();
    });
  }

  Future delHistory(SearchHistoryEntity entity) {
    return Future((){
      SearchHistoryUtil.delHistory(entity).then((value) {
        searchHistoryList.remove(entity);
      });
    });
  }
}