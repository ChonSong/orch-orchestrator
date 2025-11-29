-- Migration 002: Create Indexes and Triggers
-- This migration creates performance indexes and database triggers

BEGIN;

-- Performance indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_created_at ON users(created_at);
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

CREATE INDEX idx_oauth_providers_user_id ON oauth_providers(user_id);
CREATE INDEX idx_oauth_providers_provider ON oauth_providers(provider);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_session_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan);

CREATE INDEX idx_gimp_sessions_user_id ON gimp_sessions(user_id);
CREATE INDEX idx_gimp_sessions_status ON gimp_sessions(status);
CREATE INDEX idx_gimp_sessions_pod_name ON gimp_sessions(pod_name);
CREATE INDEX idx_gimp_sessions_created_at ON gimp_sessions(created_at);
CREATE INDEX idx_gimp_sessions_last_activity_at ON gimp_sessions(last_activity_at);

CREATE INDEX idx_session_events_session_id ON session_events(session_id);
CREATE INDEX idx_session_events_created_at ON session_events(created_at);
CREATE INDEX idx_session_events_type ON session_events(event_type);

CREATE INDEX idx_file_storage_user_id ON file_storage(user_id);
CREATE INDEX idx_file_storage_session_id ON file_storage(session_id);
CREATE INDEX idx_file_storage_original_filename ON file_storage(original_filename);
CREATE INDEX idx_file_storage_created_at ON file_storage(created_at);
CREATE INDEX idx_file_storage_deleted_at ON file_storage(deleted_at) WHERE deleted_at IS NOT NULL;

CREATE INDEX idx_file_versions_file_id ON file_versions(file_id);
CREATE INDEX idx_file_versions_created_at ON file_versions(created_at);

CREATE INDEX idx_usage_metrics_user_id ON usage_metrics(user_id);
CREATE INDEX idx_usage_metrics_session_id ON usage_metrics(session_id);
CREATE INDEX idx_usage_metrics_recorded_at ON usage_metrics(recorded_at);
CREATE INDEX idx_usage_metrics_type ON usage_metrics(metric_type);

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_subscription_id ON payments(subscriptions.id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_subscription_id ON invoices(subscriptions.id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_created_at ON invoices(created_at);

CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_keys_key_hash ON api_keys(key_hash);
CREATE INDEX idx_api_keys_expires_at ON api_keys(expires_at);

CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- GIN indexes for JSONB columns
CREATE INDEX idx_session_events_data_gin ON session_events USING gin(event_data);
CREATE INDEX idx_file_storage_metadata_gin ON file_storage USING gin((filename || ':' || mime_type));
CREATE INDEX idx_api_keys_permissions_gin ON api_keys USING gin(permissions);
CREATE INDEX idx_audit_logs_values_gin ON audit_logs USING gin((old_values || new_values));
CREATE INDEX idx_usage_metrics_data_gin ON usage_metrics USING gin((metric_type || ':' || metric_value));

-- Create trigger function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for timestamp updates
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oauth_providers_updated_at
    BEFORE UPDATE ON oauth_providers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_gimp_sessions_updated_at
    BEFORE UPDATE ON gimp_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_file_storage_updated_at
    BEFORE UPDATE ON file_storage
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at
    BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to generate invoice numbers
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TEXT AS $$
DECLARE
    prefix TEXT := 'INV';
    year_month TEXT := to_char(CURRENT_DATE, 'YYYYMM');
    sequence_num TEXT;
BEGIN
    SELECT lpad((count(*) + 1)::TEXT, 4, '0')
    INTO sequence_num
    FROM invoices
    WHERE invoice_number LIKE prefix || year_month || '%';

    RETURN prefix || year_month || sequence_num;
END;
$$ LANGUAGE plpgsql;

-- Create default notification preferences function
CREATE OR REPLACE FUNCTION create_default_notification_preferences()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification_preferences (user_id, notification_type) VALUES
        (NEW.id, 'session_started'),
        (NEW.id, 'session_ended'),
        (NEW.id, 'payment_failed'),
        (NEW.id, 'subscription_renewed'),
        (NEW.id, 'storage_quota_warning'),
        (NEW.id, 'security_alert');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for default notification preferences
CREATE TRIGGER create_notification_preferences_trigger
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_default_notification_preferences();

COMMIT;