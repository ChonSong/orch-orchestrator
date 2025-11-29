-- GIMP Streaming Platform Database Schema
-- PostgreSQL 14+ compatible
-- Created: 2024-01-01
-- Version: 1.0.0

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Create custom types
CREATE TYPE user_role AS ENUM ('admin', 'user', 'moderator');
CREATE TYPE subscription_plan AS ENUM ('free', 'basic', 'pro', 'enterprise');
CREATE TYPE session_status AS ENUM ('pending', 'active', 'paused', 'terminated', 'error');
CREATE type storage_provider AS ENUM ('aws', 'gcp', 'azure', 'local');
CREATE type billing_status AS ENUM ('active', 'cancelled', 'past_due', 'unpaid');
CREATE type payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    role user_role DEFAULT 'user',
    email_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(32),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- OAuth providers table
CREATE TABLE oauth_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL, -- google, github, etc.
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider, provider_user_id)
);

-- User sessions table
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    refresh_token VARCHAR(255) UNIQUE,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Subscriptions table
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    plan subscription_plan NOT NULL,
    status billing_status NOT NULL,
    stripe_subscription_id VARCHAR(255),
    stripe_customer_id VARCHAR(255),
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Usage metrics table
CREATE TABLE usage_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES gimp_sessions(id) ON DELETE SET NULL,
    metric_type VARCHAR(50) NOT NULL, -- cpu_time, memory_usage, storage_used, etc.
    metric_value NUMERIC NOT NULL,
    unit VARCHAR(20) NOT NULL, -- seconds, megabytes, etc.
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- GIMP sessions table
CREATE TABLE gimp_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    pod_name VARCHAR(255) UNIQUE NOT NULL,
    status session_status NOT NULL DEFAULT 'pending',
    vnc_port INTEGER,
    webrtc_port INTEGER,
    container_id VARCHAR(255),
    node_name VARCHAR(255),
    cpu_request VARCHAR(20) DEFAULT '500m',
    memory_request VARCHAR(20) DEFAULT '1Gi',
    gpu_request INTEGER DEFAULT 0,
    storage_claim VARCHAR(255),
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    last_activity_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Session events table for audit trail
CREATE TABLE session_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES gimp_sessions(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- created, started, paused, resumed, terminated, error
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- File storage table
CREATE TABLE file_storage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES gimp_sessions(id) ON DELETE SET NULL,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    checksum VARCHAR(64), -- SHA-256 hash
    storage_provider storage_provider NOT NULL DEFAULT 'aws',
    storage_bucket VARCHAR(255),
    storage_key TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    download_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- File versioning table
CREATE TABLE file_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_id UUID NOT NULL REFERENCES file_storage(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    file_size BIGINT NOT NULL,
    checksum VARCHAR(64),
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(file_id, version_number)
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    stripe_payment_intent_id VARCHAR(255),
    amount NUMERIC(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status payment_status NOT NULL,
    payment_method VARCHAR(50),
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
    stripe_invoice_id VARCHAR(255),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    tax NUMERIC(10,2) DEFAULT 0,
    total NUMERIC(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- API keys table for external integrations
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    key_hash VARCHAR(255) NOT NULL UNIQUE,
    key_prefix VARCHAR(20) NOT NULL, -- First few characters for identification
    permissions JSONB NOT NULL DEFAULT '[]',
    last_used_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP WITH TIME ZONE
);

-- System settings table
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit logs table
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notification preferences table
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT FALSE,
    in_app_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type)
);

-- Create indexes for performance optimization
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

CREATE INDEX idx_usage_metrics_user_id ON usage_metrics(user_id);
CREATE INDEX idx_usage_metrics_session_id ON usage_metrics(session_id);
CREATE INDEX idx_usage_metrics_recorded_at ON usage_metrics(recorded_at);
CREATE INDEX idx_usage_metrics_type ON usage_metrics(metric_type);

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

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_subscription_id ON payments(subscription_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_subscription_id ON invoices(subscription_id);
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
CREATE INDEX idx_usage_metrics_data_gin ON usage_metrics USING gin((metric_type || ':' || metric_value));
CREATE INDEX idx_session_events_data_gin ON session_events USING gin(event_data);
CREATE INDEX idx_file_storage_metadata_gin ON file_storage USING gin((filename || ':' || mime_type));
CREATE INDEX idx_api_keys_permissions_gin ON api_keys USING gin(permissions);
CREATE INDEX idx_audit_logs_values_gin ON audit_logs USING gin((old_values || new_values));

-- Create triggers for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

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

-- Create default notification preferences for new users
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

CREATE TRIGGER create_notification_preferences_trigger
    AFTER INSERT ON users
    FOR EACH ROW EXECUTE FUNCTION create_default_notification_preferences();

-- Create Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE gimp_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE file_storage ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_keys ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY users_self_policy ON users
    FOR ALL TO application_user
    USING (id = current_setting('app.current_user_id')::uuid OR role = 'admin');

CREATE POLICY sessions_user_policy ON user_sessions
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id')::uuid);

CREATE POLICY gimp_sessions_user_policy ON gimp_sessions
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id')::uuid);

CREATE POLICY file_storage_user_policy ON file_storage
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id')::uuid OR is_public = true);

-- Create view for user statistics
CREATE VIEW user_statistics AS
SELECT
    u.id,
    u.email,
    u.username,
    u.created_at as user_created_at,
    COUNT(DISTINCT gs.id) as total_sessions,
    COUNT(DISTINCT CASE WHEN gs.status = 'active' THEN gs.id END) as active_sessions,
    EXTRACT(EPOCH FROM (COALESCE(MAX(gs.ended_at), CURRENT_TIMESTAMP) - MIN(gs.started_at))) as total_session_time,
    COUNT(DISTINCT fs.id) as total_files,
    COALESCE(SUM(fs.file_size), 0) as total_storage_used,
    COUNT(DISTINCT p.id) as total_payments,
    COALESCE(SUM(p.amount), 0) as total_spent,
    s.plan as current_plan,
    s.status as subscription_status
FROM users u
LEFT JOIN gimp_sessions gs ON u.id = gs.user_id
LEFT JOIN file_storage fs ON u.id = fs.user_id AND fs.deleted_at IS NULL
LEFT JOIN payments p ON u.id = p.user_id AND p.status = 'completed'
LEFT JOIN subscriptions s ON u.id = s.user_id AND s.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.email, u.username, u.created_at, s.plan, s.status;

-- Create view for system statistics
CREATE VIEW system_statistics AS
SELECT
    (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) as total_users,
    (SELECT COUNT(*) FROM users WHERE created_at >= CURRENT_DATE) as new_users_today,
    (SELECT COUNT(*) FROM gimp_sessions WHERE status = 'active') as active_sessions,
    (SELECT COUNT(*) FROM gimp_sessions WHERE created_at >= CURRENT_DATE) as sessions_today,
    (SELECT COUNT(DISTINCT user_id) FROM gimp_sessions WHERE status = 'active') as active_users,
    (SELECT COALESCE(SUM(file_size), 0) FROM file_storage WHERE deleted_at IS NULL) as total_storage_used,
    (SELECT COUNT(*) FROM payments WHERE status = 'completed' AND created_at >= CURRENT_DATE) as payments_today,
    (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed' AND created_at >= CURRENT_DATE) as revenue_today,
    (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') as active_subscriptions,
    (SELECT COUNT(*) FROM subscriptions WHERE plan = 'pro' AND status = 'active') as pro_subscriptions;

-- Insert default system settings
INSERT INTO system_settings (key, value, description, is_public) VALUES
    ('max_sessions_per_user', '3', 'Maximum number of concurrent GIMP sessions per user', true),
    ('max_file_size', '104857600', 'Maximum file upload size in bytes (100MB)', true),
    ('session_timeout', '3600', 'Session timeout in seconds', true),
    ('free_storage_quota', '1073741824', 'Free storage quota in bytes (1GB)', true),
    ('pro_storage_quota', '10737418240', 'Pro storage quota in bytes (10GB)', true),
    ('enterprise_storage_quota', '107374182400', 'Enterprise storage quota in bytes (100GB)', true),
    ('enable_gpu_acceleration', 'true', 'Enable GPU acceleration for GIMP sessions', true),
    ('maintenance_mode', 'false', 'Put the platform in maintenance mode', false),
    ('registration_enabled', 'true', 'Enable new user registration', true),
    ('stripe_publishable_key', '', 'Stripe publishable key for payments', false),
    ('default_session_cpu', '500m', 'Default CPU request for GIMP sessions', false),
    ('default_session_memory', '1Gi', 'Default memory request for GIMP sessions', false);

COMMIT;