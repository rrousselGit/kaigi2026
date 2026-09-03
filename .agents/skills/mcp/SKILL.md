---
name: project-mcp
description: Context, capabilities, architecture, and maintenance procedures for the MCP server in this project (examples/mcp). Use when interacting with, modifying, running, debugging, or querying logs via the project's Model Context Protocol (MCP) server.
---

`example_mcp` capabilities:

- If requested to `get logs` of the `books` app, use `example_mcp` and call the `log` tool.
- If requested to `query` using `books` app's client, use `example_mcp` and call the `gql` tool. Specify `query` (String) and `variables` (object, optional) parameters.
  GraphQL schemas are found in `examples/api_schema`
