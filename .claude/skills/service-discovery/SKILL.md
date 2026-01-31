---
name: service-api-discovery
description: Process for learning to interact with new services programmatically. Use when encountering an unfamiliar API or service.
---

# Discovering How to Interact with New Services

When learning to interact with a new service programmatically, follow this progression:

## 1. Search for Existing CLIs (Preferred)

Search GitHub for well-respected CLIs (>100 stars, ideally recommended for AI agent use):
- `<service-name> cli github`
- `<service-name> command line tool`

Good CLIs abstract away API complexity and handle authentication, pagination, error handling.

## 2. API via OpenAPI Spec

If no suitable CLI exists, look for OpenAPI/Swagger documentation:
- Check `<service-url>/api/docs` or `<service-url>/swagger`
- Search for `openapi.json` in the project's GitHub repo
- Example: `https://raw.githubusercontent.com/<org>/<repo>/develop/src/<path>/openapi.json`

OpenAPI specs define all endpoints, parameters, and response schemas.

## 3. Read Source Code on GitHub

If OpenAPI spec is incomplete or behaviour is unclear:
- Find the controller/handler files (e.g., `*Controller.cs`, `*Handler.go`, `*_routes.py`)
- Search for the endpoint path to find the implementation
- Look for comments explaining business logic

## 4. Check Forum Discussions

For undocumented behaviour or workarounds:
- Search `<service-name> api <operation>` plus the project's forum/discourse
- GitHub issues often document API quirks and limitations

## Common Pitfalls

- **OpenAPI specs may be incomplete** - don't assume all endpoints are documented
- **Field names can be misleading** - a field named `shouldOverride` may not actually override anything; verify by testing
- **Raw GitHub URLs may 404** - use the web interface or GitHub API instead of raw.githubusercontent.com
- **Cached/stale responses** - APIs may cache aggressively; check if there's a way to force fresh data

## Discovery Pattern

1. Try the obvious API call
2. Check service logs for what actually happened
3. If unexpected behaviour, search forums/issues for similar problems
4. If still stuck, read source code for the specific endpoint
5. Document findings immediately before moving on
