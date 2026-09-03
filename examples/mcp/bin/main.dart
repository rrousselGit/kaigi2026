import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

final class BooksLogServer extends MCPServer with ToolsSupport {
  BooksLogServer(super.channel)
    : super.fromStreamChannel(
        implementation: Implementation(name: 'books-log-mcp', version: '1.0.0'),
      ) {
    registerTool(
      Tool(
        name: 'log',
        description:
            'Queries logs from the running books app using VM Service.',
        inputSchema: ObjectSchema(
          properties: {
            'vm_service_uri': Schema.string(
              description:
                  'The VM Service URI (HTTP or WS) of the running books app (optional).',
            ),
          },
        ),
      ),
      _handleLogTool,
    );
    registerTool(
      Tool(
        name: 'gql',
        description:
            'Executes a GraphQL query using the books app GraphQL client via VM Service.',
        inputSchema: ObjectSchema(
          properties: {
            'vm_service_uri': Schema.string(
              description:
                  'The VM Service URI (HTTP or WS) of the running books app (optional).',
            ),
            'query': Schema.string(
              description:
                  'The GraphQL query or mutation document string to execute.',
            ),
            'variables': Schema.object(
              description: 'Optional JSON variables map for the GraphQL query.',
            ),
          },
          required: ['query'],
        ),
      ),
      _handleGqlTool,
    );
  }

  Future<CallToolResult> _handleLogTool(CallToolRequest request) async {
    var uriParam =
        request.arguments?['vm_service_uri'] as String? ??
        request.arguments?['vmServiceUri'] as String? ??
        request.arguments?['uri'] as String?;

    if (uriParam == null || uriParam.trim().isEmpty) {
      uriParam = await _autoDiscoverVmServiceUri();
    }

    if (uriParam == null || uriParam.trim().isEmpty) {
      return CallToolResult(
        isError: true,
        content: [
          TextContent(
            text:
                'Error: Missing vm_service_uri parameter and could not auto-discover a running books app.',
          ),
        ],
      );
    }

    VmService? service;
    try {
      service = await _connectToVmService(uriParam.trim());

      final vm = await service.getVM();
      final isolates = vm.isolates;
      if (isolates == null || isolates.isEmpty) {
        return CallToolResult(
          isError: true,
          content: [
            TextContent(text: 'Error: No active isolates found in Dart VM.'),
          ],
        );
      }

      final isolateId = isolates.first.id!;

      // 1. Try service extension 'ext.books.logs'
      try {
        final response = await service.callServiceExtension(
          'ext.books.logs',
          isolateId: isolateId,
        );
        final jsonResult = response.json;
        if (jsonResult != null && jsonResult.containsKey('logs')) {
          final logs = jsonResult['logs'];
          final formatted = const JsonEncoder.withIndent('  ').convert(logs);
          return CallToolResult(content: [TextContent(text: formatted)]);
        }
      } catch (_) {
        // Fallback to evaluation if service extension is not registered or fails
      }

      // 2. Fallback: evaluate expression on main isolate
      final isolate = await service.getIsolate(isolateId);
      final rootLibId = isolate.rootLib?.id;
      if (rootLibId != null) {
        final evalResult = await service.evaluate(
          isolateId,
          rootLibId,
          'AppLogger.instance.logs.map((e) => e.toJson()).toList().toString()',
        );

        if (evalResult is InstanceRef && evalResult.valueAsString != null) {
          return CallToolResult(
            content: [TextContent(text: evalResult.valueAsString!)],
          );
        } else if (evalResult is InstanceRef && evalResult.id != null) {
          final obj = await service.getObject(isolateId, evalResult.id!);
          if (obj is Instance && obj.valueAsString != null) {
            return CallToolResult(
              content: [TextContent(text: obj.valueAsString!)],
            );
          }
        }
      }

      return CallToolResult(
        isError: true,
        content: [TextContent(text: 'Failed to retrieve logs from books app.')],
      );
    } catch (e, st) {
      return CallToolResult(
        isError: true,
        content: [
          TextContent(
            text: 'Error connecting to VM Service or querying logs: $e\n$st',
          ),
        ],
      );
    } finally {
      await service?.dispose();
    }
  }

  Future<CallToolResult> _handleGqlTool(CallToolRequest request) async {
    var uriParam =
        request.arguments?['vm_service_uri'] as String? ??
        request.arguments?['vmServiceUri'] as String? ??
        request.arguments?['uri'] as String?;
    final query = request.arguments?['query'] as String?;
    final variablesRaw = request.arguments?['variables'];

    if (uriParam == null || uriParam.trim().isEmpty) {
      uriParam = await _autoDiscoverVmServiceUri();
    }

    if (uriParam == null || uriParam.trim().isEmpty) {
      return CallToolResult(
        isError: true,
        content: [
          TextContent(
            text:
                'Error: Missing vm_service_uri parameter and could not auto-discover a running books app.',
          ),
        ],
      );
    }

    if (query == null || query.trim().isEmpty) {
      return CallToolResult(
        isError: true,
        content: [
          TextContent(text: 'Error: Missing required parameter query.'),
        ],
      );
    }

    String? variablesJsonStr;
    if (variablesRaw is Map) {
      variablesJsonStr = jsonEncode(variablesRaw);
    } else if (variablesRaw is String && variablesRaw.trim().isNotEmpty) {
      variablesJsonStr = variablesRaw.trim();
    }

    VmService? service;
    try {
      service = await _connectToVmService(uriParam.trim());

      final vm = await service.getVM();
      final isolates = vm.isolates;
      if (isolates == null || isolates.isEmpty) {
        return CallToolResult(
          isError: true,
          content: [
            TextContent(text: 'Error: No active isolates found in Dart VM.'),
          ],
        );
      }

      final isolateId = isolates.first.id!;

      final args = <String, String>{
        'query': query,
        'variables': ?variablesJsonStr,
      };

      try {
        final response = await service.callServiceExtension(
          'ext.books.gql',
          isolateId: isolateId,
          args: args,
        );

        final jsonResult = response.json;
        if (jsonResult != null) {
          final formatted = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonResult);
          return CallToolResult(content: [TextContent(text: formatted)]);
        }
      } catch (e) {
        // Service extension invocation failed
      }

      return CallToolResult(
        isError: true,
        content: [
          TextContent(text: 'Failed to execute GraphQL query via books app.'),
        ],
      );
    } catch (e, st) {
      return CallToolResult(
        isError: true,
        content: [
          TextContent(
            text:
                'Error connecting to VM Service or executing GraphQL query: $e\n$st',
          ),
        ],
      );
    } finally {
      await service?.dispose();
    }
  }

  static Future<String?> _autoDiscoverVmServiceUri() async {
    // 1. Try invoking Dart MCP server via stdio if executable is available
    final home = Platform.environment['HOME'] ?? '';
    final mcpCandidates = [
      'dart_mcp_server',
      if (home.isNotEmpty) '$home/.pub-cache/bin/dart_mcp_server',
      if (home.isNotEmpty)
        '$home/Library/Application Support/Dart/install/app-bundles/dart_mcp_server/hosted/1.1.1/bundle/bin/dart_mcp_server',
    ];

    for (final mcpExec in mcpCandidates) {
      try {
        final proc = await Process.start(mcpExec, []);
        final completer = Completer<String?>();

        proc.stdout
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
              if (line.trim().isEmpty) return;
              try {
                final json = jsonDecode(line) as Map<String, dynamic>;
                if (json['id'] == 2 && json.containsKey('result')) {
                  final res = json['result'] as Map<String, dynamic>?;
                  final content = res?['content'] as List?;
                  if (content != null && content.isNotEmpty) {
                    final text = content.first['text'] as String?;
                    if (text != null) {
                      final match = RegExp(
                        r'- name:.*books.*\n\s+uri:\s+([^\s]+)',
                        caseSensitive: false,
                      ).firstMatch(text);
                      if (match != null) {
                        completer.complete(match.group(1));
                        return;
                      }
                      final matchAny = RegExp(
                        r'uri:\s+([^\s]+)',
                      ).firstMatch(text);
                      if (matchAny != null) {
                        completer.complete(matchAny.group(1));
                        return;
                      }
                    }
                  }
                  if (!completer.isCompleted) completer.complete(null);
                }
              } catch (_) {}
            });

        proc.stdin.writeln(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'initialize',
            'params': {
              'protocolVersion': '2024-11-05',
              'capabilities': {},
              'clientInfo': {'name': 'books-mcp', 'version': '1.0.0'},
            },
          }),
        );
        proc.stdin.writeln(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 2,
            'method': 'tools/call',
            'params': {
              'name': 'dtd',
              'arguments': {'command': 'listConnectedApps'},
            },
          }),
        );

        final uri = await completer.future.timeout(
          const Duration(milliseconds: 800),
          onTimeout: () => null,
        );
        proc.kill();
        if (uri != null && uri.isNotEmpty) {
          return uri;
        }
      } catch (_) {}
    }

    // 2. Search running processes using `ps aux`
    try {
      final result = await Process.run('ps', ['aux']);
      if (result.exitCode == 0) {
        final stdoutText = result.stdout as String;
        final lines = stdoutText.split('\n');

        for (final line in lines) {
          if (line.toLowerCase().contains('books') &&
              line.contains('--vm-service-uri=')) {
            final match = RegExp(r'--vm-service-uri=([^\s]+)').firstMatch(line);
            if (match != null) {
              return match.group(1);
            }
          }
        }

        for (final line in lines) {
          if (line.contains('--vm-service-uri=')) {
            final match = RegExp(r'--vm-service-uri=([^\s]+)').firstMatch(line);
            if (match != null) {
              return match.group(1);
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static Future<VmService> _connectToVmService(String uriString) async {
    var formattedUriStr = uriString;
    if (!formattedUriStr.startsWith('http://') &&
        !formattedUriStr.startsWith('https://') &&
        !formattedUriStr.startsWith('ws://') &&
        !formattedUriStr.startsWith('wss://')) {
      formattedUriStr = 'ws://$formattedUriStr';
    }

    var uri = Uri.parse(formattedUriStr);

    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'ws');
    } else if (uri.scheme == 'https') {
      uri = uri.replace(scheme: 'wss');
    }

    if (!uri.path.endsWith('/ws') && !uri.path.endsWith('/ws/')) {
      final newPath = uri.path.endsWith('/')
          ? '${uri.path}ws'
          : '${uri.path}/ws';
      uri = uri.replace(path: newPath);
    }

    return await vmServiceConnectUri(uri.toString());
  }
}

void main() async {
  final server = BooksLogServer(stdioChannel(input: stdin, output: stdout));

  await server.done;
}
