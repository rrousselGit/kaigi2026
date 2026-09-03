import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    String? requestBody;

    if (request is http.Request) {
      requestBody = request.body;
    }

    AppLogger.instance.logNetworkRequest(
      method: request.method,
      url: request.url.toString(),
      headers: request.headers,
      body: requestBody,
    );

    try {
      final response = await _inner.send(request);
      final responseBytes = await response.stream.toBytes();
      stopwatch.stop();

      final responseBody = utf8.decode(responseBytes, allowMalformed: true);

      AppLogger.instance.logNetworkResponse(
        method: request.method,
        url: request.url.toString(),
        statusCode: response.statusCode,
        body: responseBody,
        duration: stopwatch.elapsed,
      );

      return http.StreamedResponse(
        http.ByteStream.fromBytes(responseBytes),
        response.statusCode,
        contentLength: responseBytes.isNotEmpty
            ? responseBytes.length
            : response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.instance.logException(
        e,
        stackTrace,
        'Network Error (${request.method} ${request.url})',
      );
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
