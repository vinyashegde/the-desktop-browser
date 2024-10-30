import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'The Desktop Browser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider(
        create: (context) => PointerPosition(),
        child: DesktopBrowser(),
      ),
    );
  }
}

class PointerPosition with ChangeNotifier {
  Offset _position = const Offset(100, 100);

  Offset get position => _position;

  void updatePosition(Offset newPosition) {
    _position = newPosition;
    notifyListeners();
  }
}

class DesktopBrowser extends StatefulWidget {
  const DesktopBrowser({super.key});

  @override
  _DesktopBrowserState createState() => _DesktopBrowserState();
}

class _DesktopBrowserState extends State<DesktopBrowser> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://github.com'))
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Interactive WebView with pinch-to-zoom enabled
          InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            child: WebViewWidget(
              controller: _controller,
            ),
          ),
          // Custom mouse pointer overlay
          Consumer<PointerPosition>(
            builder: (context, pointerPosition, child) {
              return Positioned(
                top: pointerPosition.position.dy,
                left: pointerPosition.position.dx,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    Provider.of<PointerPosition>(context, listen: false)
                        .updatePosition(pointerPosition.position + details.delta);
                  },
                  child: Image.asset('assets/mouse_pointer.png', width: 24, height: 24),
                ),
              );
            },
          ),
          // Gesture controls for clicks
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(msg: "Left-clicked");
            },
            onDoubleTap: () {
              Fluttertoast.showToast(msg: "Right-clicked");
            },
            onLongPress: () {
              Fluttertoast.showToast(msg: "Long-press right-click");
            },
          ),
          // Custom Toolbar
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _controller.reload();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    _controller.loadRequest(Uri.parse('https://github.com'));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () async {
                    if (await _controller.canGoForward()) {
                      _controller.goForward();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}