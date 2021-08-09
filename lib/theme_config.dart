
import 'package:flutter/material.dart';

class SearchXThemeData {
  Color? primaryColor;
  Color? accentColor;
  Color? buttonBgColor;
  Color? hintColor;
  Color? primaryTextColor;

  SearchXThemeData(
      {this.primaryColor,
      this.accentColor,
      this.buttonBgColor,
      this.hintColor,
      this.primaryTextColor});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchXThemeData &&
          runtimeType == other.runtimeType &&
          primaryColor == other.primaryColor &&
          accentColor == other.accentColor &&
          buttonBgColor == other.buttonBgColor &&
          hintColor == other.hintColor &&
          primaryTextColor == other.primaryTextColor;

  @override
  int get hashCode =>
      primaryColor.hashCode ^
      accentColor.hashCode ^
      buttonBgColor.hashCode ^
      hintColor.hashCode ^
      primaryTextColor.hashCode;
}

/// 使用 Widget 之间的传递,需要通过一个 StatefulWidget 进行传递
class SearchXThemeWidget extends StatefulWidget {
  final Widget child;
  const SearchXThemeWidget({Key? key,required this.child}) : super(key: key);

  @override
  _SearchXThemeWidgetState createState() => _SearchXThemeWidgetState(child);
}

class _SearchXThemeWidgetState extends State<SearchXThemeWidget> {
  SearchXThemeData curThemeData = ThemeConfig.black;
  final Widget child;

  _SearchXThemeWidgetState(this.child);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SearchXTheme(
        child: child,
        data: curThemeData,
      ),
      onTap: (){
        print("_SearchXThemeWidgetState click");
        setState(() {
          if (curThemeData == ThemeConfig.black) {
            curThemeData = ThemeConfig.blue;
          } else {
            curThemeData = ThemeConfig.black;
          }

        });
      },
    );
  }
}


class SearchXTheme extends InheritedWidget{
  
  final SearchXThemeData data;
  
  SearchXTheme({required Widget child, required this.data}): super(child: child);

  // 方便其子 Widget 在 Widget 树中找到它
  static SearchXThemeData of(BuildContext context) {
      SearchXTheme? theme = context.dependOnInheritedWidgetOfExactType<SearchXTheme>();
      print("SearchXThemeData | of theme: $theme ");
      return theme?.data ?? SearchXThemeData(
          primaryColor: Colors.red,
          accentColor: Colors.red,
          buttonBgColor: Colors.red
      );
  }

  @override
  bool updateShouldNotify(covariant SearchXTheme oldWidget) {
    bool needUpdate = (data != oldWidget.data);
    print("SearchXTheme | updateShouldNotify | needUpdate:$needUpdate");
    return needUpdate;
  }
}


class ThemeConfig {
  static SearchXThemeData black = SearchXThemeData(
    primaryColor: Colors.black,
    accentColor: Colors.black,
    buttonBgColor: Colors.black,
    primaryTextColor: Colors.white,
  );

  static SearchXThemeData blue = SearchXThemeData(
      primaryColor: Colors.blue[500],
      accentColor: Colors.red[200],
      buttonBgColor: Colors.blue[100],
    primaryTextColor: Colors.white
  );
}

