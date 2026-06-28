# =========================================================
# MongoDB Script for Dumping and Restoring on macOS
# Simple + Clean Version
#
# Requirements:
# - PowerShell (pwsh)
# - mongodump
# - mongorestore
#
# Run:
# pwsh ./mongo-dump-restore.ps1
#
# Author: Md. Abu Adnan
# =========================================================

$ErrorActionPreference = "Stop"

# =========================================================
# CONFIGURATION
# =========================================================

# ---------- SOURCE ----------
$SourceUser = "source-user"
$SourcePassword = "Password123"
$SourceCluster = "source-cluster.k66bp4k.mongodb.net"
$SourceDB = "source-database"

# ---------- TARGET ----------
$TargetUser = "target-user"
$TargetPassword = "TargetPassword123!"
$TargetCluster = "target-cluster.znl2q.mongodb.net"
$TargetDB = "target-database"

# =========================================================
# MONGODB TOOLS PATH
# =========================================================

$MongoDump = "/opt/homebrew/bin/mongodump"
$MongoRestore = "/opt/homebrew/bin/mongorestore"

# =========================================================
# TIMESTAMP + PATHS
# =========================================================

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$HomeDir = [Environment]::GetFolderPath("UserProfile")

$BackupRoot = Join-Path $HomeDir "mongo-backups"
$BackupDir = Join-Path $BackupRoot "$SourceDB-$Timestamp"

$LogDir = Join-Path $HomeDir "mongo-logs"

# Create folders
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

# Logs
$LogFile = Join-Path $LogDir "mongo-dump-restore-$Timestamp.log"

# =========================================================
# VALIDATION
# =========================================================

if (!(Test-Path $MongoDump)) {
    throw "mongodump not found: $MongoDump"
}

if (!(Test-Path $MongoRestore)) {
    throw "mongorestore not found: $MongoRestore"
}

# =========================================================
# URL ENCODE PASSWORDS
# =========================================================

Add-Type -AssemblyName System.Web

$EncodedSourcePassword = [System.Web.HttpUtility]::UrlEncode($SourcePassword)
$EncodedTargetPassword = [System.Web.HttpUtility]::UrlEncode($TargetPassword)

# =========================================================
# CONNECTION STRINGS
# =========================================================

$SourceUri = "mongodb+srv://${SourceUser}:${EncodedSourcePassword}@${SourceCluster}/${SourceDB}?retryWrites=true&w=majority"

$TargetUri = "mongodb+srv://${TargetUser}:${EncodedTargetPassword}@${TargetCluster}/${TargetDB}?retryWrites=true&w=majority"

# =========================================================
# LOG FUNCTION
# =========================================================

function Log {
    param([string]$Message)

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Line = "[$Time] $Message"

    Write-Host $Line
    Add-Content -Path $LogFile -Value $Line
}

# =========================================================
# START
# =========================================================

Log "==============================================="
Log "MongoDB Dump/Restore Started"
Log "==============================================="

Log "Source DB: $SourceDB"
Log "Target DB: $TargetDB"

# =========================================================
# DUMP DATABASE
# =========================================================

Log "Starting mongodump..."

& $MongoDump `
    --uri="$SourceUri" `
    --out="$BackupDir"

if ($LASTEXITCODE -ne 0) {
    Log "mongodump failed"
    exit 1
}

Log "mongodump completed"

# =========================================================
# RESTORE DATABASE
# =========================================================

$RestorePath = Join-Path $BackupDir $SourceDB

if (!(Test-Path $RestorePath)) {
    Log "Backup folder not found: $RestorePath"
    exit 1
}

Log "Starting mongorestore..."

& $MongoRestore `
    --uri="$TargetUri" `
    --nsInclude="$TargetDB.*" `
    --drop `
    "$RestorePath"

if ($LASTEXITCODE -ne 0) {
    Log "mongorestore failed"
    exit 1
}

Log "mongorestore completed"

# =========================================================
# DONE
# =========================================================

Log "==============================================="
Log "MongoDB Dump/Restore Completed Successfully"
Log "Backup Path: $BackupDir"
Log "Log File: $LogFile"
Log "==============================================="