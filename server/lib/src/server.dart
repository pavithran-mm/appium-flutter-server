import 'package:appium_flutter_server/src/handler/click.dart';
import 'package:appium_flutter_server/src/handler/double_click.dart';
import 'package:appium_flutter_server/src/handler/delete_session.dart';
import 'package:appium_flutter_server/src/handler/find_element.dart';
import 'package:appium_flutter_server/src/handler/find_elements.dart';
import 'package:appium_flutter_server/src/handler/gesture/double_click.dart'
    as gesture_double_click;
import 'package:appium_flutter_server/src/handler/get_attribute.dart';
import 'package:appium_flutter_server/src/handler/get_text.dart';
import 'package:appium_flutter_server/src/handler/new_session.dart';
import 'package:appium_flutter_server/src/handler/request/request_handler.dart';
import 'package:appium_flutter_server/src/handler/sample/screenshot.dart';
import 'package:appium_flutter_server/src/handler/sample/tap_handler.dart';
import 'package:appium_flutter_server/src/handler/status.dart';
import 'package:appium_flutter_server/src/logger.dart';
import 'package:appium_flutter_server/src/utils.dart';
import 'package:shelf_plus/shelf_plus.dart' as shelf_plus;

enum HttpMethod { GET, POST, DELETE, PUT, PATCH }

class FlutterServer {
  final bool _isStarted = false;
  late shelf_plus.RouterPlus _app;
  static final FlutterServer _instance = FlutterServer._();

  FlutterServer._() {
    _app = shelf_plus.Router().plus;

    _registerRoutes();
  }

  static FlutterServer get instance => _instance;

  void _addRoute(HttpMethod method, RequestHandler handler) {
    _app.add(method.name, handler.route, handler.getHandler());
  }

  void _registerRoutes() {
    //GET ROUTES
    _registerGet(StatusHandler("/status"));
    _registerGet(ScreenshotHandler("/screenshot"));
    _registerGet(TapHandler("/tap"));
    _registerGet(GetTextHandler("/session/<sessionId>/element/<id>/text"));
    _registerGet(GetAttributeHandler(
        "/session/<sessionId>/element/<id>/attribute/<name>"));

    //POST ROUTES
    _registerPost(NewSessionHandler("/session"));
    _registerPost(FindElementHandler("/session/<sessionId>/element"));
    _registerPost(FindElementstHandler("/session/<sessionId>/elements"));
    _registerPost(ClickHandler("/session/<sessionId>/element/<id>/click"));
    _registerPost(
        DoubleClickHandler("/session/<sessionId>/element/<id>/double_click"));

    _registerPost(gesture_double_click.DoubleClickHandler(
        "/session/<sessionId>/appium/gestures/double_click"));

    //DELETE ROUTES
    _registerDelete(DeleteSessionHandler("/session/<sessionId>"));
  }

  void _registerGet(RequestHandler handler) {
    _addRoute(HttpMethod.GET, handler);
  }

  void _registerPost(RequestHandler handler) {
    _addRoute(HttpMethod.POST, handler);
  }

  void _registerDelete(RequestHandler handler) {
    _addRoute(HttpMethod.DELETE, handler);
  }

  void startServer({int? port}) async {
    port ??= await getFreePort();
    await shelf_plus.shelfRun(() => _app.call,
        defaultBindAddress: "0.0.0.0",
        defaultBindPort: port,
        defaultEnableHotReload: false);
    log("[Appium flutter server is listening on port $port]");
  }
}
