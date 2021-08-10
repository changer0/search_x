import 'package:shared_preferences/shared_preferences.dart';

class SpUtil {
  static Future<SharedPreferences> _sp = SharedPreferences.getInstance();

  /// 搜索历史
  static const SEARCH_HISTORY = "search_history";
  static Future setSearchHistory(String history) async {
    SharedPreferences sp = await _sp;
    sp.setString(SEARCH_HISTORY, history);
  }
  static Future<String?> getSearchHistory() async {
    SharedPreferences sp = await _sp;
    return Future<String?>(() {
      return sp.getString(SEARCH_HISTORY);
    });
  }

  /// 主题样式
  static const SEARCH_X_THEME = "SEARCH_X_THEME";
  static Future setSearchXTheme(String theme) async {
    SharedPreferences sp = await _sp;
    sp.setString(SEARCH_X_THEME, theme);
  }

  static Future<String?> getSearchXTheme() async {
    SharedPreferences sp = await _sp;
    return Future<String?>(() {
      return sp.getString(SEARCH_X_THEME);
    });
  }
}
