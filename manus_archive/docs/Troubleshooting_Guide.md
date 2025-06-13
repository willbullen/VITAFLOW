# VitalFlow Automation Troubleshooting Guide

## Quick Diagnosis

If you're experiencing issues with your VitalFlow automation system, start with these quick diagnostic steps:

### 1. System Health Check
```bash
python scripts/health_check.py --environment production --detailed
```

### 2. Service Status Check
```bash
# Check if all services are running
ps aux | grep -E "(main.py|tiktok_automation|vitalflow_analytics|n8n)"

# Check service logs
tail -f logs/api.log
tail -f logs/tiktok.log
tail -f logs/analytics.log
```

### 3. Quick Restart
```bash
# Restart all services
./scripts/deploy.sh production
```

## Common Issues and Solutions

### Content Generation Issues

#### Issue: Content generation fails with "AI service unavailable"

**Symptoms:**
- Content generation API returns 503 errors
- No new content appears in queue
- Error logs show "Connection timeout to AI service"

**Diagnosis:**
```bash
# Check API connectivity
curl -X POST http://localhost:5000/api/automation/generate-content \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"product_category": "energy", "content_type": "transformation"}'

# Check AI service configuration
grep -i "openai\|ai_service" .env
```

**Solutions:**

1. **Check API Keys:**
   ```bash
   # Verify OpenAI API key is set and valid
   echo $OPENAI_API_KEY
   
   # Test API key
   curl https://api.openai.com/v1/models \
     -H "Authorization: Bearer $OPENAI_API_KEY"
   ```

2. **Update API Configuration:**
   ```bash
   # Edit environment file
   nano .env
   
   # Add or update:
   OPENAI_API_KEY=your_valid_api_key
   AI_SERVICE_TIMEOUT=30
   AI_SERVICE_RETRIES=3
   ```

3. **Restart Content Generation Service:**
   ```bash
   pkill -f "content_generation"
   python src/content_generation/vitalflow_content_generator.py &
   ```

#### Issue: Generated content quality is poor

**Symptoms:**
- Content lacks creativity or relevance
- Repetitive scripts and hooks
- Low engagement predictions

**Solutions:**

1. **Adjust AI Creativity Settings:**
   ```python
   # In src/content_generation/vitalflow_content_generator.py
   AI_CREATIVITY_LEVEL = 0.8  # Increase from 0.6
   CONTENT_VARIETY_THRESHOLD = 0.7  # Increase diversity
   ```

2. **Update Content Templates:**
   ```bash
   # Review and update templates
   ls assets/templates/
   nano assets/templates/transformation_template.json
   ```

3. **Refresh Training Data:**
   ```bash
   python scripts/update_content_training.py
   ```

### TikTok Posting Issues

#### Issue: Posts fail to upload to TikTok

**Symptoms:**
- Content stuck in "posting" status
- TikTok API errors in logs
- Posts not appearing on TikTok profile

**Diagnosis:**
```bash
# Check TikTok API connectivity
curl -X GET "https://open-api.tiktok.com/platform/oauth/connect/" \
  -H "Authorization: Bearer $TIKTOK_ACCESS_TOKEN"

# Check posting logs
grep -i "tiktok\|posting\|upload" logs/tiktok.log | tail -20
```

**Solutions:**

1. **Refresh TikTok Access Token:**
   ```bash
   # Check token expiration
   python scripts/check_tiktok_token.py
   
   # Refresh token if needed
   python scripts/refresh_tiktok_token.py
   ```

2. **Verify TikTok API Permissions:**
   - Log into TikTok for Business
   - Check app permissions include:
     - `user.info.basic`
     - `video.upload`
     - `video.publish`

3. **Check Content Format:**
   ```bash
   # Verify video format compliance
   python scripts/validate_content_format.py
   ```

4. **Manual Retry:**
   ```bash
   # Retry failed posts
   python src/automation/tiktok_automation.py --retry-failed
   ```

#### Issue: Posts are uploaded but not published

**Symptoms:**
- Videos appear in TikTok drafts
- No public posts on profile
- "Upload successful but publish failed" in logs

**Solutions:**

1. **Check Publishing Permissions:**
   ```bash
   # Verify account has publishing rights
   python scripts/verify_tiktok_permissions.py
   ```

2. **Review Content Guidelines:**
   - Ensure content meets TikTok community guidelines
   - Check for copyrighted material
   - Verify appropriate hashtags

3. **Enable Auto-Publish:**
   ```python
   # In TikTok automation configuration
   AUTO_PUBLISH = True
   PUBLISH_DELAY_SECONDS = 5
   ```

### Analytics and Monitoring Issues

#### Issue: Analytics dashboard shows no data

**Symptoms:**
- Empty dashboard widgets
- "No data available" messages
- Analytics API returns empty results

**Diagnosis:**
```bash
# Check analytics database
sqlite3 data/analytics.db ".tables"
sqlite3 data/analytics.db "SELECT COUNT(*) FROM posts;"

# Check analytics service
curl http://localhost:5002/api/analytics/dashboard
```

**Solutions:**

1. **Initialize Analytics Database:**
   ```bash
   python scripts/init_analytics_db.py
   ```

2. **Backfill Analytics Data:**
   ```bash
   python scripts/backfill_analytics.py --start-date 2024-12-01
   ```

3. **Restart Analytics Service:**
   ```bash
   pkill -f "vitalflow_analytics"
   python src/analytics/vitalflow_analytics.py &
   ```

#### Issue: Performance metrics are inaccurate

**Symptoms:**
- Engagement rates don't match TikTok analytics
- Revenue calculations are wrong
- Conversion tracking is off

**Solutions:**

1. **Sync with TikTok Analytics:**
   ```bash
   python scripts/sync_tiktok_analytics.py
   ```

2. **Recalculate Metrics:**
   ```bash
   python scripts/recalculate_metrics.py --all
   ```

3. **Verify Tracking Configuration:**
   ```bash
   # Check tracking pixels and UTM parameters
   grep -i "tracking\|utm\|pixel" config/settings.json
   ```

### Database Issues

#### Issue: Database corruption or connection errors

**Symptoms:**
- "Database is locked" errors
- Corrupted data responses
- Service startup failures

**Diagnosis:**
```bash
# Check database integrity
sqlite3 data/vitalflow.db "PRAGMA integrity_check;"
sqlite3 data/analytics.db "PRAGMA integrity_check;"

# Check database permissions
ls -la data/
```

**Solutions:**

1. **Repair Database:**
   ```bash
   # Backup current database
   cp data/vitalflow.db data/vitalflow.db.backup
   
   # Repair database
   sqlite3 data/vitalflow.db ".recover" | sqlite3 data/vitalflow_repaired.db
   mv data/vitalflow_repaired.db data/vitalflow.db
   ```

2. **Restore from Backup:**
   ```bash
   # List available backups
   ls -la backups/
   
   # Restore from latest backup
   cp backups/backup-20241213-120000/vitalflow.db data/
   ```

3. **Reset Database (Last Resort):**
   ```bash
   # WARNING: This will delete all data
   python scripts/reset_database.py --confirm
   ```

### Network and Connectivity Issues

#### Issue: External API timeouts

**Symptoms:**
- Frequent timeout errors
- Slow response times
- Intermittent service failures

**Diagnosis:**
```bash
# Test external connectivity
ping api.openai.com
ping open-api.tiktok.com
ping api.supliful.com

# Check DNS resolution
nslookup api.openai.com
```

**Solutions:**

1. **Increase Timeout Values:**
   ```bash
   # Edit configuration
   nano .env
   
   # Add:
   API_TIMEOUT=60
   CONNECTION_TIMEOUT=30
   READ_TIMEOUT=45
   ```

2. **Configure Retry Logic:**
   ```python
   # In API configuration
   MAX_RETRIES = 5
   RETRY_DELAY = 2
   EXPONENTIAL_BACKOFF = True
   ```

3. **Use Connection Pooling:**
   ```python
   # Enable connection pooling
   CONNECTION_POOL_SIZE = 10
   CONNECTION_POOL_MAXSIZE = 20
   ```

### Performance Issues

#### Issue: High CPU or memory usage

**Symptoms:**
- System slowdown
- Service crashes
- High resource utilization

**Diagnosis:**
```bash
# Monitor system resources
top -p $(pgrep -f "python.*main.py")
htop

# Check memory usage
free -h
ps aux --sort=-%mem | head -10
```

**Solutions:**

1. **Optimize Content Generation:**
   ```python
   # Reduce concurrent generation
   MAX_CONCURRENT_GENERATIONS = 2
   
   # Enable content caching
   CONTENT_CACHE_ENABLED = True
   CACHE_TTL_HOURS = 24
   ```

2. **Database Optimization:**
   ```bash
   # Optimize database
   sqlite3 data/vitalflow.db "VACUUM;"
   sqlite3 data/vitalflow.db "ANALYZE;"
   
   # Add indexes
   python scripts/optimize_database.py
   ```

3. **Enable Resource Limits:**
   ```bash
   # Set memory limits
   ulimit -m 2097152  # 2GB memory limit
   
   # Use systemd limits (production)
   echo "MemoryLimit=2G" >> /etc/systemd/system/vitalflow-api.service
   ```

### Security Issues

#### Issue: Unauthorized access attempts

**Symptoms:**
- Failed authentication logs
- Unusual API usage patterns
- Security alerts

**Diagnosis:**
```bash
# Check authentication logs
grep -i "auth\|login\|unauthorized" logs/api.log

# Monitor failed attempts
grep "401\|403" logs/api.log | tail -20
```

**Solutions:**

1. **Rotate API Keys:**
   ```bash
   # Generate new API keys
   python scripts/rotate_api_keys.py
   
   # Update configuration
   nano .env
   ```

2. **Enable Rate Limiting:**
   ```python
   # Increase rate limiting
   RATE_LIMIT_REQUESTS = 50
   RATE_LIMIT_WINDOW = 60
   RATE_LIMIT_ENABLED = True
   ```

3. **Review Access Logs:**
   ```bash
   # Analyze access patterns
   python scripts/analyze_access_logs.py --suspicious
   ```

## System Maintenance

### Daily Maintenance Tasks

1. **Health Check:**
   ```bash
   python scripts/health_check.py --environment production
   ```

2. **Log Review:**
   ```bash
   # Check for errors
   grep -i "error\|exception\|failed" logs/*.log | tail -20
   
   # Monitor performance
   grep -i "slow\|timeout\|performance" logs/*.log
   ```

3. **Backup Verification:**
   ```bash
   # Verify latest backup
   python scripts/verify_backup.py --latest
   ```

### Weekly Maintenance Tasks

1. **Database Optimization:**
   ```bash
   python scripts/optimize_database.py
   ```

2. **Log Rotation:**
   ```bash
   # Rotate and compress logs
   logrotate /etc/logrotate.d/vitalflow
   ```

3. **Security Scan:**
   ```bash
   python scripts/security_scan.py
   ```

4. **Performance Analysis:**
   ```bash
   python scripts/performance_report.py --week
   ```

### Monthly Maintenance Tasks

1. **Full System Backup:**
   ```bash
   python scripts/full_backup.py --compress
   ```

2. **Dependency Updates:**
   ```bash
   # Check for updates
   pip list --outdated
   npm outdated
   
   # Update dependencies
   pip install -r requirements.txt --upgrade
   npm update
   ```

3. **Security Updates:**
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade
   
   # Security audit
   pip-audit
   npm audit
   ```

## Emergency Procedures

### Complete System Failure

1. **Immediate Response:**
   ```bash
   # Stop all services
   pkill -f "python.*main.py"
   pkill -f "python.*automation"
   pkill -f "n8n"
   
   # Check system resources
   df -h
   free -h
   top
   ```

2. **Restore from Backup:**
   ```bash
   # Restore latest backup
   ./scripts/restore_backup.sh --latest --confirm
   ```

3. **Restart Services:**
   ```bash
   # Full deployment
   ./scripts/deploy.sh production
   ```

### Data Loss Recovery

1. **Assess Damage:**
   ```bash
   # Check database integrity
   python scripts/assess_data_damage.py
   ```

2. **Recover from Backups:**
   ```bash
   # List available backups
   ls -la backups/
   
   # Restore specific backup
   ./scripts/restore_backup.sh --backup backup-20241213-120000
   ```

3. **Rebuild Missing Data:**
   ```bash
   # Rebuild analytics from TikTok API
   python scripts/rebuild_analytics.py --from-tiktok
   
   # Regenerate content queue
   python scripts/rebuild_content_queue.py
   ```

### Security Incident Response

1. **Immediate Isolation:**
   ```bash
   # Block suspicious IPs
   iptables -A INPUT -s SUSPICIOUS_IP -j DROP
   
   # Disable API access
   systemctl stop vitalflow-api
   ```

2. **Investigate:**
   ```bash
   # Analyze logs
   python scripts/security_analysis.py --incident
   
   # Check for data breaches
   python scripts/breach_detection.py
   ```

3. **Recovery:**
   ```bash
   # Rotate all credentials
   python scripts/emergency_credential_rotation.py
   
   # Restart with new security settings
   ./scripts/deploy.sh production --security-mode
   ```

## Getting Help

### Self-Service Resources

1. **Documentation:**
   - API Documentation: `docs/API_Documentation.md`
   - Setup Guide: `docs/Setup_Guide.md`
   - FAQ: `docs/FAQ.md`

2. **Diagnostic Tools:**
   ```bash
   # Comprehensive system check
   python scripts/system_diagnostic.py --full
   
   # Generate support bundle
   python scripts/generate_support_bundle.py
   ```

3. **Community Resources:**
   - GitHub Issues: https://github.com/yourusername/vitalflow-automation/issues
   - Discord Community: https://discord.gg/vitalflow
   - Knowledge Base: https://docs.vitalflow.com

### Professional Support

For complex issues requiring expert assistance:

1. **Support Tiers:**
   - **Community**: Free GitHub issues and Discord
   - **Professional**: Email support with 24-hour response
   - **Enterprise**: Phone support with 4-hour response

2. **Contact Information:**
   - Email: support@vitalflow.com
   - Phone: +1-555-VITAL-FLOW
   - Emergency: emergency@vitalflow.com

3. **Support Bundle:**
   ```bash
   # Generate comprehensive support bundle
   python scripts/generate_support_bundle.py --include-logs --include-config
   ```

### Escalation Process

1. **Level 1**: Community support and documentation
2. **Level 2**: Professional email support
3. **Level 3**: Engineering team escalation
4. **Level 4**: Emergency response team

When escalating, always include:
- System diagnostic output
- Relevant log files
- Steps to reproduce the issue
- Business impact assessment

## Prevention Best Practices

### Monitoring Setup

1. **Automated Monitoring:**
   ```bash
   # Set up monitoring alerts
   python scripts/setup_monitoring.py --alerts
   ```

2. **Health Check Automation:**
   ```bash
   # Add to crontab
   */5 * * * * /path/to/vitalflow/scripts/health_check.py --quiet
   ```

3. **Performance Monitoring:**
   ```bash
   # Enable performance tracking
   python scripts/enable_performance_monitoring.py
   ```

### Backup Strategy

1. **Automated Backups:**
   ```bash
   # Daily backups
   0 2 * * * /path/to/vitalflow/scripts/daily_backup.sh
   
   # Weekly full backups
   0 1 * * 0 /path/to/vitalflow/scripts/weekly_backup.sh
   ```

2. **Backup Verification:**
   ```bash
   # Test backup integrity
   python scripts/test_backup_integrity.py --all
   ```

### Security Hardening

1. **Regular Security Audits:**
   ```bash
   # Monthly security scan
   0 3 1 * * /path/to/vitalflow/scripts/security_audit.py
   ```

2. **Credential Rotation:**
   ```bash
   # Quarterly credential rotation
   python scripts/rotate_credentials.py --schedule quarterly
   ```

3. **Access Control:**
   ```bash
   # Review access permissions
   python scripts/audit_permissions.py --report
   ```

Remember: Prevention is always better than recovery. Regular maintenance and monitoring will help you avoid most issues before they become critical problems.

