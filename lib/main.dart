import 'package:flutter/material.dart';
import 'package:search_x/devices_util.dart';
import 'package:search_x/search_history.dart';
import 'package:search_x/search_result_model.dart';
import 'package:search_x/sp_util.dart';
import 'package:search_x/toast_util.dart';
import 'package:search_x/url_launch.dart';

import 'theme_config.dart';
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
      home: SearchXThemeWidget(
        child: HomePage(
          title: "Search X",
        ),
      )
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

  /// 搜索历史辅助类
  SearchHistoryHelper searchHistoryHelper = SearchHistoryHelper();

  @override
  void initState() {
    String q = Uri.base.queryParameters['q'] ?? "";
    if (q.isNotEmpty == true) {
      searchTextController.text = q;
      goSearch();
    }
    searchHistoryHelper.initHistoryList().then((value) => setState(() {}));
    // 获取焦点 不可放在这儿
    //FocusScope.of(context).requestFocus(focusNode);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar(context),
        body:_buildBody(context),
    );
  }

  _getAppBar(BuildContext context) {
    if (DevicesUtil.isWeb() != true) {
      return AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: SearchXTheme.of(context).primaryTextColor),
        ),
        backgroundColor: SearchXTheme.of(context).primaryColor,
        brightness: Brightness.dark,
      );
    }
  }

  /// 构建整个内容
  _buildBody(BuildContext context) {
    if (DevicesUtil.isPortrait(context)) {
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

    if (getItemListSize() <= 0) {
      //listView 可展示内容为空,那就展示配置页面
      return _buildConfigPage(context);
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
          //print("list index: $index getItemListSize ${getItemListSize()}");
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
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border:
                Border.all(color: SearchXTheme.of(context).primaryColor, width: 2)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 5, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: TextField(
                autofocus: true,
                focusNode: focusNode,
                textInputAction: TextInputAction.search,
                controller: searchTextController,
                onSubmitted: (value) {
                  goSearch();
                },
                decoration: InputDecoration(
                    hintText: "输入要搜索的关键字", border: InputBorder.none),
                maxLines: 1,
              )),
              IconButton(
                icon: Icon(Icons.close_outlined),
                color: SearchXTheme.of(context).hintColor,
                onPressed: () {
                  print("clear screen");
                  setState(() {
                    _centerTipString = "";
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
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      //设置按下时的背景颜色
                      if (states.contains(MaterialState.pressed)) {
                        return SearchXTheme.of(context).buttonPressColor;
                      }
                      //默认不使用背景颜色
                      return null;
                    }),
                  ),
                  onPressed: () {
                    goSearch();
                  },
                  child: Text(
                    "搜索",
                    style: TextStyle(
                        fontSize: 16, color: SearchXTheme.of(context).primaryColor),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  /// 构建配置页面 目前只有搜索历史
  _buildConfigPage(BuildContext context) {
    List<Widget> children = [];
    if (DevicesUtil.isPortrait(context)) {
      children.add(_buildSettingEntrance());
      children.add(
          Expanded(child: Container(),)
      );
      //搜索历史
      if (searchHistoryHelper.length() > 0) {
        children.add(_buildSearchHistory());
      }
    } else {
      //搜索历史
      if (searchHistoryHelper.length() > 0) {
        children.add(_buildSearchHistory());
      }
      children.add(
          Expanded(child: Container(),)
      );
      children.add(_buildSettingEntrance());
    }



    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: children,
        ),
      ),
    );
  }

  /// 设置按钮入口
  _buildSettingEntrance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(icon: Icon(Icons.color_lens, color: SearchXTheme.of(context).primaryColor,), onPressed: (){
          _showThemeDialog(context);
        })
      ],
    );
  }
  _showThemeDialog(BuildContext context) async {
    int? i = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
       return SimpleDialog(
         title: Text("请选择主题"),
         children: [
           SimpleDialogOption(
             onPressed: (){
               Navigator.pop(context, 1);
             },
             child: Text("黑色"),
           ),
           SimpleDialogOption(
             onPressed: (){
               Navigator.pop(context, 2);
             },
             child: Text("蓝色"),
           ),
         ],
       );
      }
    );
    if (i != null){
      switch(i) {
        case 1: {
          _changeTheme(context, ThemeConfig.BLACK);
          break;
        }
        case 2: {
          _changeTheme(context, ThemeConfig.BLUE);
          break;
        }
      }
    }

  }

  _changeTheme(BuildContext context, String key) async{
    await SpUtil.setSearchXTheme(key);
    ThemeNotification(ThemeConfig.get(key)).dispatch(context);
  }

  /// 搜索历史
  _buildSearchHistory() {
    return Column(
      //居右
      crossAxisAlignment: CrossAxisAlignment.start,
      //居底
      mainAxisAlignment: DevicesUtil.isPortrait(context)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: SearchXTheme.of(context).accentColor,
            ),
            onPressed: () {
              searchHistoryHelper
                  .clearHistory()
                  .then((value) => setState(() {}));
            },
          ),
        ),
        _buildSearchHistoryWrap(),
      ],
    );
  }

  /// 构建搜索历史的瀑布布局
  _buildSearchHistoryWrap() {
    List<Widget> _children = [];
    for (SearchHistoryEntity e in searchHistoryHelper.searchHistoryList) {
      _children.add(Container(
          child: Chip(
        label: GestureDetector(
          child: Text(
            e.title,
            maxLines: 1,
            style: TextStyle(color: SearchXTheme.of(context).primaryTextColor),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, //省略号
          ),
          onTap: () {
            //SearchHistoryUtil.clearHistory();
            searchTextController.text = e.title;
            goSearch();
          },
        ),
        onDeleted: () {
          print("_buildSearchHistoryWrap | remove $e");
          searchHistoryHelper.delHistory(e).then((value) => setState((){}));
        },
        backgroundColor: SearchXTheme.of(context).primaryColor,
        deleteIcon: Icon(
          Icons.cancel,
          color: Colors.white,
        ),
      )));
    }
    return Wrap(
      spacing: 8.0,
      // 主轴(水平)方向间距
      runSpacing: 0.0,
      //  纵轴（垂直）方向间距
      alignment: WrapAlignment.start,
      //居左
      crossAxisAlignment: WrapCrossAlignment.start,
      children: _children,
    );
  }

  /// 触发搜索
  void goSearch() {
    String searchKey = searchTextController.text;
    _startIndex = 0;
    if (searchKey.isEmpty) {
      ToastUtil.showToast("请输入搜索关键字");
    } else {
      focusNode.unfocus();
      //添加搜索历史
      searchHistoryHelper
          .addHistory(SearchHistoryEntity(searchKey))
          .then((value) => setState(() {}));
      setState(() {
        _centerTipString = "正在搜索, 请稍候...";
      });
      this.searchKey = searchKey;
      Api.requestSearchResult(searchKey, _startIndex).then((value) {
        print(
            "goSearch requestSearchResult callback: ${value?.timeConsuming} size: ${value?.itemList.length}");
        setState(() {
          if (value?.isSuccess == true) {
            _centerTipString = "";
            searchResultModel = value;
            searchTextController.text = searchKey;
            searchTextController.selection = TextSelection(
                baseOffset: searchKey.length, extentOffset: searchKey.length);
            _isLoadMoreEnd = false;
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
      print(
          "loadMore requestSearchResult callback: ${value?.timeConsuming} size: ${value?.itemList.length}");
      if (value == null ||
          value.isSuccess != true ||
          value.itemList.length <= 0) {
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
