import 'package:flutter/material.dart';
import 'package:search_x/theme_config.dart';

import 'devices_util.dart';

class CommonUtil {

  /// 构建 AppBar
  static buildAppBar(BuildContext context, String title) {
    if (DevicesUtil.isWeb() != true) {
      return AppBar(
        title: Text(
          title,
          style: TextStyle(color: SearchXTheme.of(context).primaryTitleTextColor),
        ),
        backgroundColor: SearchXTheme.of(context).primaryColor,
        brightness: Brightness.dark,
      );
    }
    return null;
  }
}
