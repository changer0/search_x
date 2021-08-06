import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:search_x/search_result_model.dart';

class Api {
  /// 请求搜索结果
  static Future<SearchResultModel?> requestSearchResult(String searchKey, int startIndex) {
    print("requestSearchResult | searchKey: $searchKey startIndex: $startIndex");
    return Future<SearchResultModel>(() async {
      String result = "";
      SearchResultModel model = SearchResultModel.newInstance(false, "");
      try {
        String url = "https://service-cr7xtm88-1256519379.hk.apigw.tencentcs.com/release/search_proxy?q=$searchKey&start=$startIndex";
        print("requestSearchResult | url: $url");
        var response = await Dio().get(url);
        result = response.data.toString();
        model = SearchResultModel.from(json.decode(result));
        model.isSuccess = true;
      } catch (e) {
        print(e);
        model.errorMsg = e.toString();
      }
      print("requestSearchResult | result: $result");
      return model;
    });

  }
}
