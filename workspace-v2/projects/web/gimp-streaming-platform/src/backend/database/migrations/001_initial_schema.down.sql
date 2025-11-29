-- Migration 001: Rollback Initial Database Schema
-- This migration removes all tables and types created in the initial schema

BEGIN;

-- Drop tables in reverse order of dependency

DROP TABLE IF EXISTS notification_preferences;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS system_settings;
DROP TABLE IF EXISTS api_keys;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS file_versions;
DROP TABLE IF EXISTS usage_metrics;
DROP TABLE IF EXISTS file_storage;
DROP TABLE IF EXISTS session_events;
DROP TABLE IF EXISTS gimp_sessions;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS oauth_providers;
DROP TABLE IF EXISTS users;

-- Drop custom types
DROP TYPE IF EXISTS payment_status;
DROP TYPE IF EXISTS billing_status;
DROP TYPE IF EXISTS storage_provider;
DROP TYPE IF EXISTS session_status;
DROP TYPE IF EXISTS subscription_plan;
DROP TYPE IF EXISTS user_role;

COMMIT;