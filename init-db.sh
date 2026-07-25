#!/bin/bash
# init-db.sh - Initialize PostgreSQL database on first deployment
# This script runs the schema SQL file on the Render PostgreSQL instance

set -e

echo "=== Initializing PostgreSQL Database ==="

# Get database connection info from environment variables
DB_URL="$DB_URL"
DB_USER="$DB_USERNAME"
DB_PASS="$DB_PASSWORD"

if [ -z "$DB_URL" ]; then
    echo "DB_URL not set, skipping DB init"
    exit 0
fi

# Install psql if not available
if ! command -v psql &> /dev/null; then
    echo "Installing PostgreSQL client..."
    apt-get update -qq && apt-get install -y -qq postgresql-client > /dev/null 2>&1 || true
fi

# Extract host, port, dbname from JDBC URL
# JDBC URL format: jdbc:postgresql://host:port/dbname?params
PG_URL=$(echo "$DB_URL" | sed 's|jdbc:postgresql:||' | sed 's|?.*||')
PG_HOST=$(echo "$PG_URL" | sed 's|.*//||' | sed 's|:.*||')
PG_PORT=$(echo "$PG_URL" | sed 's|.*:||' | sed 's|/.*||')
PG_DB=$(echo "$PG_URL" | sed 's|.*/||')

echo "Connecting to PostgreSQL at $PG_HOST:$PG_PORT/$PG_DB"

# Run schema initialization
# Check if tables already exist (idempotent)
TABLE_COUNT=$(PGPASSWORD="$DB_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$DB_USER" -d "$PG_DB" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';" 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" -gt "0" ]; then
    echo "Database already has $TABLE_COUNT tables, skipping initialization."
    exit 0
fi

echo "Database is empty, running schema initialization..."
PGPASSWORD="$DB_PASS" psql -h "$PG_HOST" -p "$PG_PORT" -U "$DB_USER" -d "$PG_DB" -f database/schema-postgresql.sql

echo "=== Database initialization complete ==="
