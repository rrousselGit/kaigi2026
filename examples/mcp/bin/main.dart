import 'dart:io';

import 'package:dart_mcp/server.dart';
import 'package:dart_mcp/stdio.dart';

final class HelloWorldServer extends MCPServer with ToolsSupport {
  HelloWorldServer(super.channel)
      : super.fromStreamChannel(
          implementation: Implementation(
            name: 'hello-world-mcp',
            version: '1.0.0',
          ),
        ) {
    registerTool(
      Tool(
        name: 'hello_world',
        description: 'Returns a simple hello world greeting.',
        inputSchema: ObjectSchema(
          properties: {
            'name': Schema.string(
              description: 'Optional name to greet.',
            ),
          },
        ),
      ),
      (request) async {
        final name = request.arguments?['name'] as String? ?? 'World';
        return CallToolResult(
          content: [
            TextContent(text: 'Hello, $name!'),
          ],
        );
      },
    );
  }
}

void main() async {
  final server = HelloWorldServer(
    stdioChannel(
      input: stdin,
      output: stdout,
    ),
  );

  await server.done;
}
