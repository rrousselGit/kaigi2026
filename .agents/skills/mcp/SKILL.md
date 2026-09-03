---
name: project-mcp
description: Context, capabilities, architecture, and maintenance procedures for the MCP server in this project (examples/mcp). Use when interacting with, modifying, running, debugging, or querying logs via the project's Model Context Protocol (MCP) server.
---

## Logs

If requested to `get logs` of the `books` app, use `example_mcp` and do a tool call.
You must first obtain a vm_service_uri using `dart_mcp_server` with the tool `listConnectedApps`.
