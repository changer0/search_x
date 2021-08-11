import 'package:flutter/material.dart';
import 'package:search_x/sp_util.dart';

class SearchXThemeData {
  Color primaryColor;
  Color accentColor;
  Color buttonPressColor;
  Color hintColor;
  Color primaryTitleTextColor;

  SearchXThemeData(
      {this.primaryColor = Colors.red,
      this.accentColor = Colors.red,
      this.buttonPressColor = Colors.red,
      this.hintColor = Colors.grey,
      this.primaryTitleTextColor = Colors.white});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchXThemeData &&
          runtimeType == other.runtimeType &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          buttonPressColor == other.buttonPressColor &&
          hintColor == other.hintColor &&
          primaryTitleTextColor == other.primaryTitleTextColor;

  @override
  int get hashCode =>
      primaryColor.hashCode ^
      accentColor.hashCode ^
      buttonPressColor.hashCode ^
      hintColor.hashCode ^
      primaryTitleTextColor.hashCode;
}

class ThemeNotification extends Notification {
  ThemeNotification(this.msg);
  final SearchXThemeData msg;
}

/// 使用 Widget 之间的传递,需要通过一个 StatefulWidget 进行传递
class SearchXThemeWidget extends StatefulWidget {
  final Widget child;
  const SearchXThemeWidget({Key? key, required this.child}) : super(key: key);

  @override
  _SearchXThemeWidgetState createState() => _SearchXThemeWidgetState(child);
}

class _SearchXThemeWidgetState extends State<SearchXThemeWidget> {
  SearchXThemeData curThemeData = ThemeConfig.defaultTheme;
  final Widget child;
  _SearchXThemeWidgetState(this.child);

  @override
  void initState() {
    SpUtil.getSearchXTheme().then((value) {
      setState(() {
        print("change Theme: $value");
        curThemeData = ThemeConfig.get(value);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return NotificationListener<ThemeNotification>(
      onNotification: (notification) {
        print("NotificationListener | 收到通知");
        setState(() {
          curThemeData = notification.msg;
        });
        return true;
      },
      child: SearchXTheme(
        child: child,
        data: curThemeData,
      ),
    );
  }
}

class SearchXTheme extends InheritedWidget{
  
  final SearchXThemeData data;
  
  SearchXTheme({required Widget child, required this.data}): super(child: child);

  // 方便其子 Widget 在 Widget 树中找到它
  static SearchXThemeData of(BuildContext context) {
    SearchXTheme? theme =
        context.dependOnInheritedWidgetOfExactType<SearchXTheme>();
    //print("SearchXThemeData | of theme: $theme ");
    return theme?.data ?? SearchXThemeData();
  }

  @override
  bool updateShouldNotify(covariant SearchXTheme oldWidget) {
    bool needUpdate = (data != oldWidget.data);
    //print("SearchXTheme | updateShouldNotify | needUpdate:$needUpdate");
    return needUpdate;
  }
}

class ThemeConfig {
  static const String BLACK = "black";
  static const String BLUE = "blue";
  static const String RED = "red";

  static SearchXThemeData defaultTheme = SearchXThemeData(
      primaryColor: Colors.blue[500] ?? Colors.blue,
      accentColor: Colors.red[200] ?? Colors.red,
      buttonPressColor: Colors.blue[100] ?? Colors.blue,
      primaryTitleTextColor: Colors.white);

  static Map<String, SearchXThemeData> themeMap = {
    RED: SearchXThemeData(
      primaryColor: Colors.red,
      accentColor: Colors.red,
      buttonPressColor: Colors.red[50]??Colors.red,
      primaryTitleTextColor: Colors.white,
    ),
    BLACK: SearchXThemeData(
      primaryColor: Colors.black,
      accentColor: Colors.black,
      buttonPressColor: Colors.grey,
      primaryTitleTextColor: Colors.white,
    ),
    BLUE: defaultTheme,
  };

  static SearchXThemeData get(String? key) {
    String _key = key ?? BLUE;
    return themeMap[_key] ?? defaultTheme;
  }
}
