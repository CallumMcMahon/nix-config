---
name: fix-sqlite-readonly
description: Fix SQLite read-only database errors in Docker containers. Use when containers fail with "attempt to write a readonly database" errors.
disable-model-invocation: true
allowed-tools: Bash(docker *, ssh *, rm *)
---

# Fix SQLite Read-Only Database Errors in Docker Containers

## Problem

Docker containers using SQLite fail with:
```
SQLiteException: attempt to write a readonly database
```

This occurs even when file permissions appear correct.

## Cause

SQLite WAL (Write-Ahead Log) files (`.db-shm` and `.db-wal`) can become corrupted or locked, typically after:
- Unclean container shutdown
- Host system crash or restart
- Docker daemon restart
- Filesystem issues

## Solution

1. Stop the affected container:
   ```bash
   docker compose stop <service>
   ```

2. Remove the WAL and SHM files from the service's config directory:
   ```bash
   rm -f config/<service>/*.db-shm config/<service>/*.db-wal
   ```

3. Restart the container:
   ```bash
   docker compose start <service>
   ```

4. Verify logs show no more read-only errors:
   ```bash
   docker logs <service> --since 2m 2>&1 | grep -i readonly
   ```

## Notes

- This fix is safe - SQLite will recreate the WAL files on startup
- The main `.db` file is not deleted, so no data is lost
- If the error persists after this fix, check for actual filesystem/permission issues
