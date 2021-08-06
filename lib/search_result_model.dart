
import 'base_model.dart';

class SearchResultModel with BaseModel {
  /// 耗时
  String timeConsuming = "";
  /// 列表
  List<ItemModel> itemList = [];

  SearchResultModel({required this.timeConsuming, required this.itemList});

  factory SearchResultModel.newInstance(bool isSuccess, String errorMsg) {
    SearchResultModel model = SearchResultModel(timeConsuming: "", itemList: []);
    model.isSuccess = isSuccess;
    model.errorMsg = errorMsg;
    return model;
  }

  factory SearchResultModel.from(Map<String, dynamic> parsedJson) {
    print("SearchResultModel.from called");
    List<ItemModel> itemModelList = [];
    var list = parsedJson["list"];
    for (Map<String, dynamic> item in list) {
      itemModelList.add(ItemModel.fromJson(item));
    }
    return SearchResultModel(
      timeConsuming: parsedJson['time_consuming'],
      itemList:itemModelList
    );
  }

}
class ItemModel {
  String title = "";
  String url = "";
  String description = "";
  String showTime = "";


  ItemModel({required this.title, required this.url, required this.description, required this.showTime});

  factory ItemModel.fromJson(Map<String, dynamic> parsedJson) {
    return ItemModel(
      title: parsedJson['title'],
      url: parsedJson['url'],
      description: parsedJson['description'],
      showTime: parsedJson['showTime']
    );
  }
}