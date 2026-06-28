# MongoDB Dump and Restore

## Problem
You need to copy a MongoDB database from one cluster to another, while preserving a local backup and keeping the operation easy to rerun.

## Solution
Use the PowerShell script [mongo-dump-restore.ps1](mongo-atlas-dump-restore.ps1) to dump the source database with `mongodump`, restore it into the target database with `mongorestore`, and save both the backup files and a log file for later review.

## Command
```powershell
pwsh ./mongo-dump-restore.ps1
```

## Example
```powershell
# Run from the dump-restore folder
pwsh ./mongo-dump-restore.ps1
```

This creates a timestamped backup directory under your home folder, for example:

```text
~/mongo-backups/<database-name>-<timestamp>/
```

## Explanation
- The script expects `mongodump` and `mongorestore` to be installed and available in the system path.
- On macOS, the default paths are set to `/opt/homebrew/bin/mongodump` and `/opt/homebrew/bin/mongorestore`.
- It uses the source and target MongoDB Atlas connection strings defined inside the script.
- The backup is created in a timestamped folder and a log file is written under `~/mongo-logs`.
- The restore step uses `--drop` to replace existing data in the target database.

## Common Errors
- `mongodump not found` or `mongorestore not found`: verify the tool paths or install the MongoDB Database Tools.
- Authentication failed: confirm the username, password, and cluster hostname values in the script.
- Backup folder not found: ensure the dump completed successfully before restore begins.
- Connection string issues: special characters in passwords are URL-encoded by the script.

> For production use, consider moving connection details and secrets out of the script and into environment variables or a secure secret store.

## References
- MongoDB Database Tools: https://www.mongodb.com/docs/database-tools/
- mongodump documentation: https://www.mongodb.com/docs/database-tools/mongodump/
- mongorestore documentation: https://www.mongodb.com/docs/database-tools/mongorestore/
- MongoDB Atlas connection strings: https://www.mongodb.com/docs/manual/reference/connection-string/
