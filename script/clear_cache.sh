#!/usr/bin/env bash
set -e

MCP_CACHE_DIR="${HOME}/.gemini/antigravity-ide/mcp/mcp"

if [ -d "${MCP_CACHE_DIR}" ]; then
  rm -rf "${MCP_CACHE_DIR}"
fi
