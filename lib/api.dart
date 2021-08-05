import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:search_x/search_result_model.dart';

class Api {
  /// 请求搜索结果
  static Future<SearchResultModel?> requestSearchResult(String searchKey) {
    return Future<SearchResultModel>(() async {
      String result = "";
      try {
        var response = await Dio()
            .get("https://service-cr7xtm88-1256519379.hk.apigw.tencentcs.com/release/search_proxy?q=" + searchKey);
        result = response.data.toString();
      } catch (e) {
        print(e);
      }
      print("打印结果: $result");
      return SearchResultModel.from(json.decode(result));
    });

  }
}
