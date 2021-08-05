import 'package:flutter/material.dart';
import 'package:search_x/search_result_model.dart';
import 'package:search_x/toast_utils.dart';
import 'package:search_x/url_launch.dart';

import 'api.dart';

void main() {
  runApp(SearchXApp());
}

class SearchXApp extends StatelessWidget {
  const SearchXApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Search X",
      theme: ThemeData(primaryColor: Colors.blue),
      home: HomePage(
        title: "Search X",
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SearchResultModel? searchResultModel;

  ScrollController listViewController = ScrollController();

  String searchKey = "";

  TextEditingController searchTextController = TextEditingController();

  FocusNode focusNode = FocusNode();

  int startIndex = 0;

  bool _isLoadMore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildBody(context));
  }

  /// 构建一个搜索框
  _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildSearchResult(context),
        _buildSearchBox(context),
      ],
    );
  }

  /// 搜索结果
  _buildSearchResult(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: listViewController,
        itemCount: getItemListSize() * 2,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          //如果是奇数则返回一个分割线
          if (i.isOdd) return const Divider();
          //语法 i ~/ 2 表示 i 除以 2，但返回值是整型（向下取整），
          // 比如 i 为：1, 2, 3, 4, 5 时，结果为 0, 1, 1, 2, 2，
          // 这个可以计算出 ListView 中减去分隔线后的实际的位置。
          final index = i ~/ 2;
          if (index >= getItemListSize() - 1) {
            loadMore();
          }
          print("list index: $index getItemListSize ${getItemListSize()}");
          return _buildItem(context, index);
        },
      ),
    );
  }

  /// Item Size
  int getItemListSize() => (searchResultModel?.itemList.length ?? 0);

  /// 构建列表的 Item
  _buildItem(BuildContext context, int index) {
    SearchResultModel? model = searchResultModel;
    if (model == null) {
      return null;
    }
    List<ItemModel> itemList = model.itemList;
    if (index >= itemList.length) {
      return null;
    }
    ItemModel itemModel = itemList[index];
    return ListTile(
      onTap: () {
        print("将要跳转到: ${itemModel.url}");
        URLLauncher.launchURL(itemModel.url);
      },
      title: Text(itemModel.title),
      subtitle: Text(itemModel.description),
    );
  }

  /// 搜索框
  _buildSearchBox(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 2)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: TextField(
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                controller: searchTextController,
                onSubmitted: (value) {
                  goSearch();
                },
                decoration: InputDecoration(
                    hintText: "输入要搜索的文字", border: InputBorder.none),
                maxLines: 1,
              )),
              GestureDetector(
                child: Icon(
                  Icons.close_outlined,
                  color: Theme.of(context).hintColor,
                ),
                onTap: (){
                  print("执行按钮");
                  setState(() {
                    searchKey = "";
                    searchTextController.text = "";
                    searchResultModel = null;
                    _isLoadMore = false;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.all(1),
                child: TextButton(
                  onPressed: () {
                    goSearch();

                    //打印测试
                    // Future<String>(() {
                    //   return "hh";
                    // }).then((value) {
                    //   print("哎哟我天" + value);
                    // });
                  },
                  child: Text(
                    "搜索",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  /// 触发搜索
  void goSearch() {
    String searchKey = searchTextController.text;
    focusNode.unfocus();
    ToastUtils.showToast("正在搜索, 请稍候...");
    startIndex = 0;
    if (searchKey.isEmpty) {
      ToastUtils.showToast("请输入搜索关键字");
    } else {
      this.searchKey = searchKey;
      Api.requestSearchResult(searchKey, startIndex).then((value) {
        print("数据回调: ${value?.timeConsuming} size: ${value?.itemList.length}");
        setState(() {
          searchResultModel = value;
          listViewController.animateTo(0,
              duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
          searchTextController.text = searchKey;
          searchTextController.selection = TextSelection(
              baseOffset: searchKey.length, extentOffset: searchKey.length);
        });
      });
    }
  }

  /// 加载更多
  void loadMore() {
    print("loadMore: $_isLoadMore");
    if (_isLoadMore) {
      return;
    }
    _isLoadMore = true;
    this.searchKey = searchKey;
    startIndex = getItemListSize() + 1;
    Api.requestSearchResult(searchKey, startIndex).then((value) {
      _isLoadMore = false;
      print("数据回调: ${value?.timeConsuming} size: ${value?.itemList.length}");
      if (value == null) {
        return;
      }
      setState(() {
        searchResultModel?.itemList.addAll(value.itemList);
        searchTextController.text = searchKey;
        searchTextController.selection = TextSelection(
            baseOffset: searchKey.length, extentOffset: searchKey.length);
      });
    });
  }
}
