import 'dart:async';

import 'package:appium_flutter_server/src/logger.dart';
import 'package:appium_flutter_server/src/models/api/appium_response.dart';
import 'package:shelf_plus/shelf_plus.dart';

abstract class RequestHandler {
  final String route;

  RequestHandler(this.route);

  Function getHandler() {
    return (Request request) async {
      String sessionId = getSessionId(request);
      log('New Request [${request.method}] ${request.requestedUri.toString()}');
      try {
        AppiumResponse response = await handle(request);
        log('response ${response.value}');
        return response.toHttpResponse();
      } catch (e, stacktrace) {
        log(stacktrace);
        return AppiumResponse.withError(sessionId, e, stacktrace)
            .toHttpResponse();
      }
    };
  }

  String getSessionId(Request request) {
    return getRouteParam(request, "sessionId");
  }

  String getElementId(Request request) {
    return getRouteParam(request, "id");
  }

  String getRouteParam(Request request, String param) {
    return request.routeParameter(param);
  }

  FutureOr<AppiumResponse> handle(Request request);
}
