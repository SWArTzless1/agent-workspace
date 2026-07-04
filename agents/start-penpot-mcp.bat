@echo off
REM Known issue (as of @penpot/mcp 2.15.4): the package ships a broken
REM pnpm-workspace.yaml with literal placeholder text instead of real values
REM ("esbuild: set this to true or false"), which makes pnpm refuse the
REM install with ERR_PNPM_IGNORED_BUILDS. Also requires a real `pnpm` on PATH
REM (not just corepack's shim). If this script fails with either error:
REM   1. npm install -g pnpm
REM   2. Find the cached package: dir /s /b "%LOCALAPPDATA%\npm-cache\_npx\*pnpm-workspace.yaml"
REM   3. Edit that file: set esbuild and sharp both to "true" (no quotes)
REM   4. Re-run this script.
echo Starting Penpot MCP bridge server...
echo.
echo   MCP endpoint:     http://localhost:4401/mcp
echo   Plugin manifest:  http://localhost:4400/manifest.json
echo.
echo One-time manual step per Penpot file (skip if already connected):
echo   1. Open https://design.penpot.app and open or create a design file.
echo   2. Go to Plugins -^> Load from URL, enter: http://localhost:4400/manifest.json
echo   3. Click "Connect to MCP server" in the plugin panel and keep it open.
echo.
echo Leave this window running - closing it stops the MCP bridge.
echo.
npx -y @penpot/mcp@stable
