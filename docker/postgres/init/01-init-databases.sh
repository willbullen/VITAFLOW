#!/bin/bash
set -e

# PostgreSQL Multiple Database Initialization Script
# This script creates multiple databases for VitalFlow services

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create databases for VitalFlow services
    CREATE DATABASE n8n;
    CREATE DATABASE analytics;
    CREATE DATABASE automation;
    
    -- Grant all privileges to the main user
    GRANT ALL PRIVILEGES ON DATABASE n8n TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE analytics TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE automation TO $POSTGRES_USER;
    
    -- Create extensions for better functionality
    \c $POSTGRES_DB;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
    
    \c n8n;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
    
    \c analytics;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
    CREATE EXTENSION IF NOT EXISTS "pg_trgm";
    
    \c automation;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
    
    -- Create initial tables for VitalFlow main database
    \c $POSTGRES_DB;
    
    -- Users table
    CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        is_active BOOLEAN DEFAULT true,
        is_admin BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Products table
    CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        supliful_id VARCHAR(100) UNIQUE NOT NULL,
        name VARCHAR(200) NOT NULL,
        category VARCHAR(50) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        cost DECIMAL(10,2) NOT NULL,
        margin DECIMAL(5,2) GENERATED ALWAYS AS (((price - cost) / price) * 100) STORED,
        stock_status VARCHAR(20) DEFAULT 'in_stock',
        is_active BOOLEAN DEFAULT true,
        images JSONB,
        benefits JSONB,
        ingredients JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Content table
    CREATE TABLE IF NOT EXISTS content (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        content_type VARCHAR(50) NOT NULL,
        product_id UUID REFERENCES products(id),
        script TEXT NOT NULL,
        hooks JSONB,
        cta TEXT,
        hashtags JSONB,
        estimated_engagement DECIMAL(5,2),
        status VARCHAR(20) DEFAULT 'pending',
        scheduled_time TIMESTAMP WITH TIME ZONE,
        posted_time TIMESTAMP WITH TIME ZONE,
        tiktok_post_id VARCHAR(100),
        performance_metrics JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Content images table
    CREATE TABLE IF NOT EXISTS content_images (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        content_id UUID REFERENCES content(id) ON DELETE CASCADE,
        image_type VARCHAR(50) NOT NULL,
        file_path VARCHAR(500) NOT NULL,
        file_size INTEGER,
        dimensions JSONB,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- System settings table
    CREATE TABLE IF NOT EXISTS system_settings (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        key VARCHAR(100) UNIQUE NOT NULL,
        value JSONB NOT NULL,
        description TEXT,
        is_encrypted BOOLEAN DEFAULT false,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Create indexes for better performance
    CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
    CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active);
    CREATE INDEX IF NOT EXISTS idx_content_status ON content(status);
    CREATE INDEX IF NOT EXISTS idx_content_scheduled_time ON content(scheduled_time);
    CREATE INDEX IF NOT EXISTS idx_content_product_id ON content(product_id);
    CREATE INDEX IF NOT EXISTS idx_content_images_content_id ON content_images(content_id);
    CREATE INDEX IF NOT EXISTS idx_system_settings_key ON system_settings(key);
    
    -- Insert default system settings
    INSERT INTO system_settings (key, value, description) VALUES
    ('posting_schedule', '["08:00", "12:00", "18:00"]', 'Default posting times'),
    ('max_posts_per_day', '3', 'Maximum posts per day'),
    ('auto_posting_enabled', 'true', 'Enable automatic posting'),
    ('content_generation_enabled', 'true', 'Enable automatic content generation'),
    ('ai_creativity_level', '0.8', 'AI creativity level (0-1)'),
    ('content_safety_filter', 'true', 'Enable content safety filtering')
    ON CONFLICT (key) DO NOTHING;
    
    -- Create analytics database tables
    \c analytics;
    
    -- Analytics events table
    CREATE TABLE IF NOT EXISTS analytics_events (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        event_type VARCHAR(50) NOT NULL,
        event_data JSONB NOT NULL,
        user_id UUID,
        session_id VARCHAR(100),
        ip_address INET,
        user_agent TEXT,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Performance metrics table
    CREATE TABLE IF NOT EXISTS performance_metrics (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        metric_type VARCHAR(50) NOT NULL,
        metric_name VARCHAR(100) NOT NULL,
        metric_value DECIMAL(15,4) NOT NULL,
        dimensions JSONB,
        timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Business metrics table
    CREATE TABLE IF NOT EXISTS business_metrics (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        date DATE NOT NULL,
        revenue DECIMAL(12,2) DEFAULT 0,
        orders INTEGER DEFAULT 0,
        conversion_rate DECIMAL(5,4) DEFAULT 0,
        average_order_value DECIMAL(10,2) DEFAULT 0,
        total_views INTEGER DEFAULT 0,
        total_likes INTEGER DEFAULT 0,
        total_shares INTEGER DEFAULT 0,
        total_comments INTEGER DEFAULT 0,
        engagement_rate DECIMAL(5,4) DEFAULT 0,
        follower_count INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(date)
    );
    
    -- Create indexes for analytics
    CREATE INDEX IF NOT EXISTS idx_analytics_events_type ON analytics_events(event_type);
    CREATE INDEX IF NOT EXISTS idx_analytics_events_timestamp ON analytics_events(timestamp);
    CREATE INDEX IF NOT EXISTS idx_performance_metrics_type ON performance_metrics(metric_type);
    CREATE INDEX IF NOT EXISTS idx_performance_metrics_timestamp ON performance_metrics(timestamp);
    CREATE INDEX IF NOT EXISTS idx_business_metrics_date ON business_metrics(date);
    
    -- Create automation database tables
    \c automation;
    
    -- Automation jobs table
    CREATE TABLE IF NOT EXISTS automation_jobs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        job_type VARCHAR(50) NOT NULL,
        job_name VARCHAR(100) NOT NULL,
        job_config JSONB NOT NULL,
        schedule_expression VARCHAR(100),
        is_active BOOLEAN DEFAULT true,
        last_run TIMESTAMP WITH TIME ZONE,
        next_run TIMESTAMP WITH TIME ZONE,
        run_count INTEGER DEFAULT 0,
        success_count INTEGER DEFAULT 0,
        failure_count INTEGER DEFAULT 0,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Job execution history table
    CREATE TABLE IF NOT EXISTS job_executions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        job_id UUID REFERENCES automation_jobs(id) ON DELETE CASCADE,
        status VARCHAR(20) NOT NULL,
        started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        completed_at TIMESTAMP WITH TIME ZONE,
        duration_seconds INTEGER,
        result JSONB,
        error_message TEXT,
        logs TEXT
    );
    
    -- Content queue table
    CREATE TABLE IF NOT EXISTS content_queue (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        content_id UUID NOT NULL,
        priority INTEGER DEFAULT 5,
        scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL,
        status VARCHAR(20) DEFAULT 'queued',
        attempts INTEGER DEFAULT 0,
        max_attempts INTEGER DEFAULT 3,
        last_attempt TIMESTAMP WITH TIME ZONE,
        error_message TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
    );
    
    -- Create indexes for automation
    CREATE INDEX IF NOT EXISTS idx_automation_jobs_active ON automation_jobs(is_active);
    CREATE INDEX IF NOT EXISTS idx_automation_jobs_next_run ON automation_jobs(next_run);
    CREATE INDEX IF NOT EXISTS idx_job_executions_job_id ON job_executions(job_id);
    CREATE INDEX IF NOT EXISTS idx_job_executions_status ON job_executions(status);
    CREATE INDEX IF NOT EXISTS idx_content_queue_scheduled_for ON content_queue(scheduled_for);
    CREATE INDEX IF NOT EXISTS idx_content_queue_status ON content_queue(status);
    
    -- Insert default automation jobs
    INSERT INTO automation_jobs (job_type, job_name, job_config, schedule_expression) VALUES
    ('content_generation', 'Daily Content Generation', '{"products_per_batch": 3, "content_types": ["transformation", "educational", "grwm"]}', '0 6 * * *'),
    ('tiktok_posting', 'Morning Post', '{"time": "08:00", "max_posts": 1}', '0 8 * * *'),
    ('tiktok_posting', 'Afternoon Post', '{"time": "12:00", "max_posts": 1}', '0 12 * * *'),
    ('tiktok_posting', 'Evening Post', '{"time": "18:00", "max_posts": 1}', '0 18 * * *'),
    ('analytics_sync', 'TikTok Analytics Sync', '{"sync_period_hours": 24}', '0 2 * * *'),
    ('performance_analysis', 'Daily Performance Analysis', '{"generate_insights": true}', '0 3 * * *')
    ON CONFLICT DO NOTHING;
    
    -- Create a function to update timestamps
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS \$\$
    BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    \$\$ language 'plpgsql';
    
    -- Create triggers for updated_at columns
    \c $POSTGRES_DB;
    CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_content_updated_at BEFORE UPDATE ON content FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
    \c analytics;
    CREATE TRIGGER update_business_metrics_updated_at BEFORE UPDATE ON business_metrics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
    \c automation;
    CREATE TRIGGER update_automation_jobs_updated_at BEFORE UPDATE ON automation_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    CREATE TRIGGER update_content_queue_updated_at BEFORE UPDATE ON content_queue FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
EOSQL

echo "PostgreSQL databases and tables created successfully!"
echo "Databases created: $POSTGRES_DB, n8n, analytics, automation"
echo "Extensions installed: uuid-ossp, pg_stat_statements, pg_trgm"

