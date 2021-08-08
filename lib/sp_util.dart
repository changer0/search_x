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
    return Future<String?>((){
      return sp.getString(SEARCH_HISTORY);
    });
  }

}