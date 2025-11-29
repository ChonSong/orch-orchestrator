-- Migration 002: Rollback Indexes and Triggers
-- This migration removes all indexes and triggers created in migration 002

BEGIN;

-- Drop triggers
DROP TRIGGER IF EXISTS create_notification_preferences_trigger ON users;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_oauth_providers_updated_at ON oauth_providers;
DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON subscriptions;
DROP TRIGGER IF EXISTS update_gimp_sessions_updated_at ON gimp_sessions;
DROP TRIGGER IF EXISTS update_file_storage_updated_at ON file_storage;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP TRIGGER IF EXISTS update_invoices_updated_at ON invoices;
DROP TRIGGER IF EXISTS update_system_settings_updated_at ON system_settings;
DROP TRIGGER IF EXISTS update_notification_preferences_updated_at ON notification_preferences;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS generate_invoice_number();
DROP FUNCTION IF EXISTS create_default_notification_preferences();

-- Drop GIN indexes
DROP INDEX IF EXISTS idx_usage_metrics_data_gin;
DROP INDEX IF EXISTS idx_session_events_data_gin;
DROP INDEX IF EXISTS idx_file_storage_metadata_gin;
DROP INDEX IF EXISTS idx_api_keys_permissions_gin;
DROP INDEX IF EXISTS idx_audit_logs_values_gin;

-- Drop regular indexes
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_username;
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_users_created_at;
DROP INDEX IF EXISTS idx_users_deleted_at;

DROP INDEX IF EXISTS idx_oauth_providers_user_id;
DROP INDEX IF EXISTS idx_oauth_providers_provider;

DROP INDEX IF EXISTS idx_user_sessions_user_id;
DROP INDEX IF EXISTS idx_user_sessions_session_token;
DROP INDEX IF EXISTS idx_user_sessions_expires_at;

DROP INDEX IF EXISTS idx_subscriptions_user_id;
DROP INDEX IF EXISTS idx_subscriptions_status;
DROP INDEX IF EXISTS idx_subscriptions_plan;

DROP INDEX IF EXISTS idx_gimp_sessions_user_id;
DROP INDEX IF EXISTS idx_gimp_sessions_status;
DROP INDEX IF EXISTS idx_gimp_sessions_pod_name;
DROP INDEX IF EXISTS idx_gimp_sessions_created_at;
DROP INDEX IF EXISTS idx_gimp_sessions_last_activity_at;

DROP INDEX IF EXISTS idx_session_events_session_id;
DROP INDEX IF EXISTS idx_session_events_created_at;
DROP INDEX IF EXISTS idx_session_events_type;

DROP INDEX IF EXISTS idx_file_storage_user_id;
DROP INDEX IF EXISTS idx_file_storage_session_id;
DROP INDEX IF EXISTS idx_file_storage_original_filename;
DROP INDEX IF EXISTS idx_file_storage_created_at;
DROP INDEX IF EXISTS idx_file_storage_deleted_at;

DROP INDEX IF EXISTS idx_file_versions_file_id;
DROP INDEX IF EXISTS idx_file_versions_created_at;

DROP INDEX IF EXISTS idx_usage_metrics_user_id;
DROP INDEX IF EXISTS idx_usage_metrics_session_id;
DROP INDEX IF EXISTS idx_usage_metrics_recorded_at;
DROP INDEX IF EXISTS idx_usage_metrics_type;

DROP INDEX IF EXISTS idx_payments_user_id;
DROP INDEX IF EXISTS idx_payments_subscription_id;
DROP INDEX IF EXISTS idx_payments_status;
DROP INDEX IF EXISTS idx_payments_created_at;

DROP INDEX IF EXISTS idx_invoices_user_id;
DROP INDEX IF EXISTS idx_invoices_subscription_id;
DROP INDEX IF EXISTS idx_invoices_status;
DROP INDEX IF EXISTS idx_invoices_created_at;

DROP INDEX IF EXISTS idx_api_keys_user_id;
DROP INDEX IF EXISTS idx_api_keys_key_hash;
DROP INDEX IF EXISTS idx_api_keys_expires_at;

DROP INDEX IF EXISTS idx_audit_logs_user_id;
DROP INDEX IF EXISTS idx_audit_logs_action;
DROP INDEX IF EXISTS idx_audit_logs_resource;
DROP INDEX IF EXISTS idx_audit_logs_created_at;

COMMIT;