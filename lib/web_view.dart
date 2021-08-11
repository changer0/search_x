import 'package:flutter/material.dart';
import 'package:search_x/theme_config.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'common_util.dart';

/// Webview
class SearchXWebView extends StatefulWidget {
  const SearchXWebView({Key? key}) : super(key: key);

  @override
  _SearchXWebViewState createState() => _SearchXWebViewState();
}

class _SearchXWebViewState extends State<SearchXWebView> {
  double curProgress = 0;

  dynamic _params(BuildContext context) {
    return ModalRoute.of(context)?.settings.arguments as dynamic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonUtil.buildAppBar(context, _params(context)['title']),
      body: _buildBody(context),
    );
  }

  /// 构建 Body
  _buildBody(BuildContext context) {
    List<Widget> children = [];
    children.add(_buildWebView(context));
    if (curProgress > 0 && curProgress < 1) {
      children.add(_buildProgress());
    }
    return Stack(
      children: children,
    );
  }

  LinearProgressIndicator _buildProgress() {
    return LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(SearchXTheme.of(context).primaryColor),
      backgroundColor: Colors.white,
      value: curProgress,
    );
  }

  /// 构建 WebView
  _buildWebView(BuildContext context) {
    print("WevView url: ${_params(context)}");
    return WebView(
      initialUrl: _params(context)['url'],
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {},
      onProgress: (int progress) {
        setState(() {
          curProgress = progress / 100.0;
          print("WebView is loading (progress : $curProgress%)");
        });
      },
      navigationDelegate: (NavigationRequest request) {
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
    );
  }
}