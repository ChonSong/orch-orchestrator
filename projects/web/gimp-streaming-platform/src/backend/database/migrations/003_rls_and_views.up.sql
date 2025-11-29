-- Migration 003: Row Level Security and Views
-- This migration creates RLS policies and database views

BEGIN;

-- Create application user role for RLS
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'application_user') THEN
        CREATE ROLE application_user;
    END IF;
END
$$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO application_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO application_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO application_user;

-- Enable Row Level Security on relevant tables
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
-- Users can only access their own data, admins can access all
CREATE POLICY users_self_policy ON users
    FOR ALL TO application_user
    USING (id = current_setting('app.current_user_id', true)::uuid OR role = 'admin');

CREATE POLICY sessions_user_policy ON user_sessions
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

CREATE POLICY gimp_sessions_user_policy ON gimp_sessions
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Users can access their own files and public files
CREATE POLICY file_storage_user_policy ON file_storage
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid OR is_public = true);

-- Users can access their own usage metrics
CREATE POLICY usage_metrics_user_policy ON usage_metrics
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Users can access their own payments
CREATE POLICY payments_user_policy ON payments
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Users can access their own invoices
CREATE POLICY invoices_user_policy ON invoices
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Users can access their own API keys
CREATE POLICY api_keys_user_policy ON api_keys
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Users can access their own notification preferences
CREATE POLICY notification_preferences_user_policy ON notification_preferences
    FOR ALL TO application_user
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

-- Create views for statistics and reporting

-- User statistics view
CREATE OR REPLACE VIEW user_statistics AS
SELECT
    u.id,
    u.email,
    u.username,
    u.created_at as user_created_at,
    u.last_login_at,
    u.role,
    COUNT(DISTINCT gs.id) FILTER (WHERE gs.status != 'terminated') as total_sessions,
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
GROUP BY u.id, u.email, u.username, u.created_at, u.last_login_at, u.role, s.plan, s.status;

-- System statistics view (admin only)
CREATE OR REPLACE VIEW system_statistics AS
SELECT
    (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) as total_users,
    (SELECT COUNT(*) FROM users WHERE created_at >= CURRENT_DATE) as new_users_today,
    (SELECT COUNT(*) FROM users WHERE last_login_at >= CURRENT_DATE) as active_users_today,
    (SELECT COUNT(*) FROM gimp_sessions WHERE status = 'active') as active_sessions,
    (SELECT COUNT(*) FROM gimp_sessions WHERE created_at >= CURRENT_DATE) as sessions_today,
    (SELECT COUNT(DISTINCT user_id) FROM gimp_sessions WHERE status = 'active') as concurrent_active_users,
    (SELECT COALESCE(SUM(file_size), 0) FROM file_storage WHERE deleted_at IS NULL) as total_storage_used,
    (SELECT COUNT(*) FROM payments WHERE status = 'completed' AND created_at >= CURRENT_DATE) as payments_today,
    (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'completed' AND created_at >= CURRENT_DATE) as revenue_today,
    (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') as active_subscriptions,
    (SELECT COUNT(*) FROM subscriptions WHERE plan = 'pro' AND status = 'active') as pro_subscriptions,
    (SELECT COUNT(*) FROM subscriptions WHERE plan = 'enterprise' AND status = 'active') as enterprise_subscriptions;

-- Session statistics view
CREATE OR REPLACE VIEW session_statistics AS
SELECT
    DATE_TRUNC('day', created_at) as session_date,
    COUNT(*) as total_sessions,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(EXTRACT(EPOCH FROM (ended_at - started_at))) as avg_session_duration_seconds,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_sessions,
    COUNT(CASE WHEN status = 'terminated' THEN 1 END) as terminated_sessions,
    COUNT(CASE WHEN status = 'error' THEN 1 END) as error_sessions
FROM gimp_sessions
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY session_date DESC;

-- Storage usage statistics view
CREATE OR REPLACE VIEW storage_statistics AS
SELECT
    u.id as user_id,
    u.email,
    COUNT(fs.id) as file_count,
    COALESCE(SUM(fs.file_size), 0) as total_storage_used,
    COUNT(CASE WHEN fs.created_at >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as files_last_7_days,
    COUNT(CASE WHEN fs.created_at >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as files_last_30_days,
    MAX(fs.created_at) as last_file_upload
FROM users u
LEFT JOIN file_storage fs ON u.id = fs.user_id AND fs.deleted_at IS NULL
WHERE u.deleted_at IS NULL
GROUP BY u.id, u.email
ORDER BY total_storage_used DESC;

-- Billing statistics view
CREATE OR REPLACE VIEW billing_statistics AS
SELECT
    DATE_TRUNC('month', created_at) as billing_month,
    COUNT(DISTINCT user_id) as paying_users,
    COUNT(*) as total_transactions,
    COALESCE(SUM(amount), 0) as total_revenue,
    COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_payments,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_payments,
    AVG(amount) FILTER (WHERE status = 'completed') as avg_payment_amount
FROM payments
WHERE created_at >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY billing_month DESC;

-- Popular files view (for admin analytics)
CREATE OR REPLACE VIEW popular_files AS
SELECT
    fs.id,
    fs.original_filename,
    fs.file_size,
    fs.mime_type,
    fs.download_count,
    fs.created_at,
    u.username as owner_username,
    u.email as owner_email,
    COUNT(DISTINCT fv.id) as version_count
FROM file_storage fs
JOIN users u ON fs.user_id = u.id
LEFT JOIN file_versions fv ON fs.id = fv.file_id
WHERE fs.deleted_at IS NULL AND fs.download_count > 0
GROUP BY fs.id, fs.original_filename, fs.file_size, fs.mime_type, fs.download_count, fs.created_at, u.username, u.email
ORDER BY fs.download_count DESC;

-- Create function to check user quota
CREATE OR REPLACE FUNCTION check_user_storage_quota(p_user_id UUID, p_additional_size BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    current_usage BIGINT;
    user_quota BIGINT;
BEGIN
    -- Get current storage usage
    SELECT COALESCE(SUM(file_size), 0)
    INTO current_usage
    FROM file_storage
    WHERE user_id = p_user_id AND deleted_at IS NULL;

    -- Get user quota based on subscription
    SELECT CASE
        WHEN s.plan = 'free' THEN (SELECT value::BIGINT FROM system_settings WHERE key = 'free_storage_quota')
        WHEN s.plan = 'basic' THEN (SELECT value::BIGINT FROM system_settings WHERE key = 'basic_storage_quota')
        WHEN s.plan = 'pro' THEN (SELECT value::BIGINT FROM system_settings WHERE key = 'pro_storage_quota')
        WHEN s.plan = 'enterprise' THEN (SELECT value::BIGINT FROM system_settings WHERE key = 'enterprise_storage_quota')
        ELSE (SELECT value::BIGINT FROM system_settings WHERE key = 'free_storage_quota')
    END
    INTO user_quota
    FROM subscriptions s
    WHERE s.user_id = p_user_id AND s.status = 'active' AND s.deleted_at IS NULL;

    -- If no active subscription, use free quota
    IF user_quota IS NULL THEN
        user_quota := (SELECT value::BIGINT FROM system_settings WHERE key = 'free_storage_quota');
    END IF;

    RETURN (current_usage + p_additional_size) <= user_quota;
END;
$$ LANGUAGE plpgsql;

-- Create function to log user activity
CREATE OR REPLACE FUNCTION log_user_activity()
RETURNS TRIGGER AS $$
BEGIN
    -- Update last_activity_at for the user when they start a session
    IF TG_TABLE_NAME = 'gimp_sessions' AND TG_OP = 'INSERT' THEN
        UPDATE users
        SET last_login_at = CURRENT_TIMESTAMP
        WHERE id = NEW.user_id;
    END IF;

    -- Update last_accessed_at for user sessions
    IF TG_TABLE_NAME = 'user_sessions' AND TG_OP = 'UPDATE' THEN
        NEW.last_accessed_at = CURRENT_TIMESTAMP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create activity logging triggers
CREATE TRIGGER log_gimp_session_activity
    AFTER INSERT ON gimp_sessions
    FOR EACH ROW EXECUTE FUNCTION log_user_activity();

CREATE TRIGGER log_user_session_activity
    BEFORE UPDATE ON user_sessions
    FOR EACH ROW EXECUTE FUNCTION log_user_activity();

-- Grant view permissions to application user
GRANT SELECT ON user_statistics TO application_user;
GRANT SELECT ON session_statistics TO application_user;
GRANT SELECT ON storage_statistics TO application_user;
GRANT SELECT ON billing_statistics TO application_user;

-- Grant admin view permissions to admin users
GRANT SELECT ON system_statistics TO application_user;
GRANT SELECT ON popular_files TO application_user;

COMMIT;