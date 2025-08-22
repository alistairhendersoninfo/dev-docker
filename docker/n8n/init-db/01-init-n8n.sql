-- Initialize n8n database with additional tables for container management

-- Create extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create table for container deployment tracking
CREATE TABLE IF NOT EXISTS container_deployments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    container_name VARCHAR(255) NOT NULL UNIQUE,
    image_name VARCHAR(255) NOT NULL,
    dns_name VARCHAR(255),
    ssh_port INTEGER,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Create table for DNS entries management
CREATE TABLE IF NOT EXISTS dns_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hostname VARCHAR(255) NOT NULL UNIQUE,
    ip_address INET,
    container_id VARCHAR(255),
    container_name VARCHAR(255),
    entry_type VARCHAR(50) DEFAULT 'A',
    ttl INTEGER DEFAULT 300,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT true
);

-- Create table for workflow execution logs
CREATE TABLE IF NOT EXISTS workflow_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_name VARCHAR(255) NOT NULL,
    execution_id VARCHAR(255),
    status VARCHAR(50),
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    execution_time INTEGER, -- in milliseconds
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_container_deployments_name ON container_deployments(container_name);
CREATE INDEX IF NOT EXISTS idx_container_deployments_status ON container_deployments(status);
CREATE INDEX IF NOT EXISTS idx_dns_entries_hostname ON dns_entries(hostname);
CREATE INDEX IF NOT EXISTS idx_dns_entries_active ON dns_entries(active);
CREATE INDEX IF NOT EXISTS idx_workflow_logs_workflow_name ON workflow_logs(workflow_name);
CREATE INDEX IF NOT EXISTS idx_workflow_logs_created_at ON workflow_logs(created_at);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_container_deployments_updated_at 
    BEFORE UPDATE ON container_deployments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dns_entries_updated_at 
    BEFORE UPDATE ON dns_entries 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert some sample data for testing
INSERT INTO container_deployments (container_name, image_name, dns_name, ssh_port, status, metadata) 
VALUES 
    ('n8n-automation', 'n8nio/n8n:latest', 'n8n-local.alistairhenderson.info', 2222, 'running', '{"description": "n8n automation server"}'),
    ('traefik-proxy', 'traefik:latest', 'traefik-local.alistairhenderson.info', 2223, 'running', '{"description": "Traefik reverse proxy"}')
ON CONFLICT (container_name) DO NOTHING;

INSERT INTO dns_entries (hostname, container_name, entry_type, active)
VALUES 
    ('n8n-local.alistairhenderson.info', 'n8n-automation', 'A', true),
    ('traefik-local.alistairhenderson.info', 'traefik-proxy', 'A', true)
ON CONFLICT (hostname) DO NOTHING;
