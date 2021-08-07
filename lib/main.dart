import 'package:flutter/material.dart';
import 'package:search_x/search_result_model.dart';
import 'package:search_x/toast_utils.dart';
import 'package:search_x/url_launch.dart';

import 'ThemeConfig.dart';
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
      theme: SearchXThemeConfig.blue,
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
  /// Model
  SearchResultModel? searchResultModel;

  /// ListViewController
  ScrollController listViewController = ScrollController();

  /// 当前搜索关键字
  String searchKey = "";

  /// 输入框控制器
  TextEditingController searchTextController = TextEditingController();

  /// 焦点
  FocusNode focusNode = FocusNode();

  /// 搜索其实 Index
  int _startIndex = 0;

  /// 正在 LoadMore
  bool _isLoadingMore = false;
  
  /// 加载更多完成
  bool _isLoadMoreEnd = false;

  /// 中间提示
  String _centerTipString = "";

  @override
  void initState() {
    String q = Uri.base.queryParameters['q'] ?? "";
    if (q.isNotEmpty == true) {
      searchTextController.text = q;
      goSearch();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(widget.title),
        // ),
        body: _buildBody(context));
  }

  /// 构建整个内容
  _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (size.height > size.width) {
      return Column(
        children: [
          _buildSearchResult(context),
          _buildSearchBox(context),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSearchBox(context),
          _buildSearchResult(context),
        ],
      );
    }
  }

  /// 搜索结果
  _buildSearchResult(BuildContext context) {
    if (_centerTipString.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _centerTipString,
          ),
        ),
      );
    }
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
        margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
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
                onTap: () {
                  print("清除屏幕");
                  setState(() {
                    searchKey = "";
                    searchTextController.text = "";
                    searchResultModel = null;
                    _isLoadingMore = false;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.all(1),
                child: TextButton(
                  style: ButtonStyle(
                    // 水波纹颜色
                    overlayColor: MaterialStateProperty.resolveWith((states){
                      //设置按下时的背景颜色
                      if(states.contains(MaterialState.pressed)) {
                        return Theme.of(context).buttonColor;
                      }
                      //默认不使用背景颜色
                      return null;
                    }),
                  ),
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
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).primaryColor),
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
    _startIndex = 0;
    if (searchKey.isEmpty) {
      ToastUtils.showToast("请输入搜索关键字");
    } else {
      setState(() {
        _centerTipString = "正在搜索, 请稍候...";
      });
      this.searchKey = searchKey;
      Api.requestSearchResult(searchKey, _startIndex).then((value) {
        print("数据回调: ${value?.timeConsuming} size: ${value?.itemList.length}");
        setState(() {
          if (value?.isSuccess == true) {
            _centerTipString = "";
            searchResultModel = value;
            searchTextController.text = searchKey;
            searchTextController.selection = TextSelection(
                baseOffset: searchKey.length, extentOffset: searchKey.length);
          } else {
            _centerTipString = "加载失败: ${value?.errorMsg}";
          }
        });
      });
    }
  }

  /// 加载更多
  void loadMore() {
    print("_isLoadingMore: $_isLoadingMore _isLoadMoreEnd: $_isLoadMoreEnd");
    if (_isLoadingMore || _isLoadMoreEnd) {
      return;
    }
    _isLoadingMore = true;
    this.searchKey = searchKey;
    _startIndex = getItemListSize() + 1;
    Api.requestSearchResult(searchKey, _startIndex).then((value) {
      _isLoadingMore = false;
      print("数据回调: ${value?.timeConsuming} size: ${value?.itemList.length}");
      if (value == null || value.isSuccess != true || value.itemList.length <= 0) {
        _isLoadMoreEnd = true;
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
