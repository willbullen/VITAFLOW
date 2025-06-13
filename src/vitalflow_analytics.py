import json
import os
from datetime import datetime, timedelta
import sqlite3
from flask import Flask, request, jsonify, render_template_string
import requests
import threading
import time

class VitalFlowAnalytics:
    def __init__(self):
        self.db_path = "/home/ubuntu/vitalflow_analytics.db"
        self.init_database()
        self.monitoring_enabled = True
        self.start_monitoring()
    
    def init_database(self):
        """Initialize analytics database"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        # Create tables
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS content_performance (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                content_id TEXT UNIQUE,
                product_name TEXT,
                template_type TEXT,
                generated_at TIMESTAMP,
                posted_at TIMESTAMP,
                views INTEGER DEFAULT 0,
                likes INTEGER DEFAULT 0,
                shares INTEGER DEFAULT 0,
                comments INTEGER DEFAULT 0,
                engagement_rate REAL DEFAULT 0,
                conversion_rate REAL DEFAULT 0,
                revenue REAL DEFAULT 0
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS system_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                content_queue_size INTEGER,
                posts_today INTEGER,
                system_status TEXT,
                api_response_time REAL,
                error_count INTEGER DEFAULT 0
            )
        ''')
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS business_metrics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                date DATE UNIQUE,
                total_views INTEGER DEFAULT 0,
                total_engagement INTEGER DEFAULT 0,
                total_revenue REAL DEFAULT 0,
                conversion_rate REAL DEFAULT 0,
                cost_per_acquisition REAL DEFAULT 0,
                return_on_ad_spend REAL DEFAULT 0
            )
        ''')
        
        conn.commit()
        conn.close()
        print("📊 Analytics database initialized")
    
    def start_monitoring(self):
        """Start background monitoring"""
        monitor_thread = threading.Thread(target=self.monitor_system, daemon=True)
        monitor_thread.start()
        print("🔍 System monitoring started")
    
    def monitor_system(self):
        """Monitor system performance continuously"""
        while self.monitoring_enabled:
            try:
                self.collect_system_metrics()
                self.update_content_performance()
                self.calculate_business_metrics()
                time.sleep(300)  # Check every 5 minutes
            except Exception as e:
                print(f"❌ Monitoring error: {e}")
                time.sleep(60)  # Wait 1 minute on error
    
    def collect_system_metrics(self):
        """Collect system performance metrics"""
        try:
            # Check automation API
            start_time = time.time()
            response = requests.get("http://localhost:5000/api/automation/automation-status", timeout=10)
            api_response_time = time.time() - start_time
            
            if response.status_code == 200:
                data = response.json()
                status = data.get('status', {})
                
                conn = sqlite3.connect(self.db_path)
                cursor = conn.cursor()
                
                cursor.execute('''
                    INSERT INTO system_metrics 
                    (content_queue_size, posts_today, system_status, api_response_time)
                    VALUES (?, ?, ?, ?)
                ''', (
                    status.get('content_queue', 0),
                    status.get('posts_published_today', 0),
                    status.get('system_status', 'unknown'),
                    api_response_time
                ))
                
                conn.commit()
                conn.close()
                
        except Exception as e:
            print(f"Error collecting system metrics: {e}")
    
    def update_content_performance(self):
        """Update content performance metrics"""
        try:
            # Get posted content
            posted_dir = "/home/ubuntu/posted_content"
            if not os.path.exists(posted_dir):
                return
            
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            for filename in os.listdir(posted_dir):
                if filename.startswith('posted_') and filename.endswith('.json'):
                    filepath = os.path.join(posted_dir, filename)
                    
                    with open(filepath, 'r') as f:
                        content = json.load(f)
                    
                    content_id = content.get('id')
                    
                    # Check if already in database
                    cursor.execute('SELECT id FROM content_performance WHERE content_id = ?', (content_id,))
                    if cursor.fetchone():
                        continue
                    
                    # Simulate performance metrics (in real implementation, get from TikTok API)
                    import random
                    views = random.randint(1000, 50000)
                    likes = int(views * random.uniform(0.02, 0.08))
                    shares = int(views * random.uniform(0.005, 0.02))
                    comments = int(views * random.uniform(0.01, 0.03))
                    engagement_rate = (likes + shares + comments) / views * 100
                    
                    cursor.execute('''
                        INSERT INTO content_performance 
                        (content_id, product_name, template_type, generated_at, posted_at, 
                         views, likes, shares, comments, engagement_rate)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        content_id,
                        content.get('product', {}).get('name', 'Unknown'),
                        content.get('template', {}).get('type', 'Unknown'),
                        content.get('generated_at'),
                        content.get('posted_at'),
                        views, likes, shares, comments, engagement_rate
                    ))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            print(f"Error updating content performance: {e}")
    
    def calculate_business_metrics(self):
        """Calculate daily business metrics"""
        try:
            today = datetime.now().date()
            
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Get today's content performance
            cursor.execute('''
                SELECT SUM(views), SUM(likes + shares + comments), COUNT(*)
                FROM content_performance 
                WHERE DATE(posted_at) = ?
            ''', (today,))
            
            result = cursor.fetchone()
            total_views = result[0] or 0
            total_engagement = result[1] or 0
            posts_count = result[2] or 0
            
            # Simulate revenue (in real implementation, get from TikTok Shop API)
            import random
            if total_views > 0:
                conversion_rate = random.uniform(0.01, 0.03)  # 1-3% conversion
                avg_order_value = random.uniform(35, 45)  # Average product price
                total_revenue = total_views * conversion_rate * avg_order_value
            else:
                conversion_rate = 0
                total_revenue = 0
            
            # Update or insert business metrics
            cursor.execute('''
                INSERT OR REPLACE INTO business_metrics 
                (date, total_views, total_engagement, total_revenue, conversion_rate)
                VALUES (?, ?, ?, ?, ?)
            ''', (today, total_views, total_engagement, total_revenue, conversion_rate))
            
            conn.commit()
            conn.close()
            
        except Exception as e:
            print(f"Error calculating business metrics: {e}")
    
    def get_dashboard_data(self):
        """Get comprehensive dashboard data"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # System overview
            cursor.execute('''
                SELECT content_queue_size, posts_today, system_status, api_response_time
                FROM system_metrics 
                ORDER BY timestamp DESC LIMIT 1
            ''')
            system_data = cursor.fetchone()
            
            # Content performance summary
            cursor.execute('''
                SELECT 
                    COUNT(*) as total_posts,
                    SUM(views) as total_views,
                    SUM(likes) as total_likes,
                    SUM(shares) as total_shares,
                    SUM(comments) as total_comments,
                    AVG(engagement_rate) as avg_engagement
                FROM content_performance
            ''')
            content_summary = cursor.fetchone()
            
            # Top performing content
            cursor.execute('''
                SELECT content_id, product_name, template_type, views, engagement_rate
                FROM content_performance 
                ORDER BY views DESC LIMIT 5
            ''')
            top_content = cursor.fetchall()
            
            # Template performance
            cursor.execute('''
                SELECT 
                    template_type,
                    COUNT(*) as posts,
                    AVG(views) as avg_views,
                    AVG(engagement_rate) as avg_engagement
                FROM content_performance 
                GROUP BY template_type
                ORDER BY avg_engagement DESC
            ''')
            template_performance = cursor.fetchall()
            
            # Business metrics (last 7 days)
            cursor.execute('''
                SELECT date, total_views, total_engagement, total_revenue
                FROM business_metrics 
                ORDER BY date DESC LIMIT 7
            ''')
            business_trends = cursor.fetchall()
            
            # Recent system metrics
            cursor.execute('''
                SELECT timestamp, content_queue_size, posts_today, api_response_time
                FROM system_metrics 
                ORDER BY timestamp DESC LIMIT 24
            ''')
            system_trends = cursor.fetchall()
            
            conn.close()
            
            return {
                'system_overview': {
                    'content_queue': system_data[0] if system_data else 0,
                    'posts_today': system_data[1] if system_data else 0,
                    'system_status': system_data[2] if system_data else 'unknown',
                    'api_response_time': system_data[3] if system_data else 0
                },
                'content_summary': {
                    'total_posts': content_summary[0] if content_summary else 0,
                    'total_views': content_summary[1] if content_summary else 0,
                    'total_likes': content_summary[2] if content_summary else 0,
                    'total_shares': content_summary[3] if content_summary else 0,
                    'total_comments': content_summary[4] if content_summary else 0,
                    'avg_engagement': round(content_summary[5] or 0, 2)
                },
                'top_content': [
                    {
                        'content_id': row[0],
                        'product_name': row[1],
                        'template_type': row[2],
                        'views': row[3],
                        'engagement_rate': round(row[4], 2)
                    } for row in top_content
                ],
                'template_performance': [
                    {
                        'template_type': row[0],
                        'posts': row[1],
                        'avg_views': int(row[2]),
                        'avg_engagement': round(row[3], 2)
                    } for row in template_performance
                ],
                'business_trends': [
                    {
                        'date': row[0],
                        'views': row[1],
                        'engagement': row[2],
                        'revenue': round(row[3], 2)
                    } for row in business_trends
                ],
                'system_trends': [
                    {
                        'timestamp': row[0],
                        'queue_size': row[1],
                        'posts_today': row[2],
                        'response_time': round(row[3], 3)
                    } for row in system_trends
                ]
            }
            
        except Exception as e:
            print(f"Error getting dashboard data: {e}")
            return {}
    
    def get_performance_insights(self):
        """Get AI-powered performance insights"""
        try:
            dashboard_data = self.get_dashboard_data()
            
            insights = []
            
            # Analyze template performance
            template_perf = dashboard_data.get('template_performance', [])
            if template_perf:
                best_template = max(template_perf, key=lambda x: x['avg_engagement'])
                insights.append({
                    'type': 'template_optimization',
                    'title': 'Best Performing Template',
                    'message': f"'{best_template['template_type']}' templates have the highest engagement rate at {best_template['avg_engagement']}%. Consider creating more content with this template.",
                    'priority': 'high'
                })
            
            # Analyze posting frequency
            system_overview = dashboard_data.get('system_overview', {})
            posts_today = system_overview.get('posts_today', 0)
            
            if posts_today < 2:
                insights.append({
                    'type': 'posting_frequency',
                    'title': 'Low Posting Frequency',
                    'message': f"Only {posts_today} posts today. Consider increasing posting frequency to 3-4 posts per day for better reach.",
                    'priority': 'medium'
                })
            
            # Analyze content queue
            queue_size = system_overview.get('content_queue', 0)
            if queue_size < 5:
                insights.append({
                    'type': 'content_queue',
                    'title': 'Low Content Queue',
                    'message': f"Content queue has only {queue_size} items. Generate more content to maintain consistent posting.",
                    'priority': 'medium'
                })
            
            # Analyze engagement trends
            content_summary = dashboard_data.get('content_summary', {})
            avg_engagement = content_summary.get('avg_engagement', 0)
            
            if avg_engagement > 5:
                insights.append({
                    'type': 'engagement_success',
                    'title': 'High Engagement Rate',
                    'message': f"Excellent engagement rate of {avg_engagement}%! Your content strategy is working well.",
                    'priority': 'positive'
                })
            elif avg_engagement < 2:
                insights.append({
                    'type': 'engagement_improvement',
                    'title': 'Low Engagement Rate',
                    'message': f"Engagement rate is {avg_engagement}%. Try more interactive content formats and trending hashtags.",
                    'priority': 'high'
                })
            
            return insights
            
        except Exception as e:
            print(f"Error generating insights: {e}")
            return []

# Flask app for analytics dashboard
app = Flask(__name__)
analytics = VitalFlowAnalytics()

@app.route('/api/analytics/dashboard', methods=['GET'])
def get_dashboard():
    """Get dashboard data"""
    try:
        data = analytics.get_dashboard_data()
        return jsonify({
            'success': True,
            'data': data
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/analytics/insights', methods=['GET'])
def get_insights():
    """Get performance insights"""
    try:
        insights = analytics.get_performance_insights()
        return jsonify({
            'success': True,
            'insights': insights
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/dashboard')
def dashboard():
    """Analytics dashboard HTML"""
    dashboard_html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>VitalFlow Analytics Dashboard</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
            .container { max-width: 1200px; margin: 0 auto; }
            .header { background: #2c3e50; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
            .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 20px; }
            .metric-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .metric-value { font-size: 2em; font-weight: bold; color: #3498db; }
            .metric-label { color: #7f8c8d; margin-top: 5px; }
            .chart-container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
            .insights { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .insight { padding: 10px; margin: 10px 0; border-left: 4px solid #3498db; background: #ecf0f1; }
            .insight.high { border-color: #e74c3c; }
            .insight.positive { border-color: #27ae60; }
            .status-running { color: #27ae60; }
            .status-error { color: #e74c3c; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🚀 VitalFlow Analytics Dashboard</h1>
                <p>Real-time monitoring and analytics for your automated TikTok Shop business</p>
            </div>
            
            <div class="metrics-grid" id="metrics-grid">
                <!-- Metrics will be loaded here -->
            </div>
            
            <div class="chart-container">
                <h3>📊 Performance Overview</h3>
                <div id="performance-charts">
                    <!-- Charts will be loaded here -->
                </div>
            </div>
            
            <div class="insights">
                <h3>💡 AI Insights & Recommendations</h3>
                <div id="insights-container">
                    <!-- Insights will be loaded here -->
                </div>
            </div>
        </div>
        
        <script>
            async function loadDashboard() {
                try {
                    // Load dashboard data
                    const response = await fetch('/api/analytics/dashboard');
                    const result = await response.json();
                    
                    if (result.success) {
                        updateMetrics(result.data);
                        updateCharts(result.data);
                    }
                    
                    // Load insights
                    const insightsResponse = await fetch('/api/analytics/insights');
                    const insightsResult = await insightsResponse.json();
                    
                    if (insightsResult.success) {
                        updateInsights(insightsResult.insights);
                    }
                    
                } catch (error) {
                    console.error('Error loading dashboard:', error);
                }
            }
            
            function updateMetrics(data) {
                const metricsGrid = document.getElementById('metrics-grid');
                const system = data.system_overview || {};
                const content = data.content_summary || {};
                
                metricsGrid.innerHTML = `
                    <div class="metric-card">
                        <div class="metric-value">${system.posts_today || 0}</div>
                        <div class="metric-label">Posts Today</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${system.content_queue || 0}</div>
                        <div class="metric-label">Content Queue</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${(content.total_views || 0).toLocaleString()}</div>
                        <div class="metric-label">Total Views</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${content.avg_engagement || 0}%</div>
                        <div class="metric-label">Avg Engagement</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value ${system.system_status === 'running' ? 'status-running' : 'status-error'}">${system.system_status || 'Unknown'}</div>
                        <div class="metric-label">System Status</div>
                    </div>
                    <div class="metric-card">
                        <div class="metric-value">${(system.api_response_time || 0).toFixed(3)}s</div>
                        <div class="metric-label">API Response Time</div>
                    </div>
                `;
            }
            
            function updateCharts(data) {
                const chartsContainer = document.getElementById('performance-charts');
                const templates = data.template_performance || [];
                const topContent = data.top_content || [];
                
                let templatesHtml = '<h4>Template Performance</h4><ul>';
                templates.forEach(template => {
                    templatesHtml += `<li><strong>${template.template_type}</strong>: ${template.avg_views} avg views, ${template.avg_engagement}% engagement</li>`;
                });
                templatesHtml += '</ul>';
                
                let topContentHtml = '<h4>Top Performing Content</h4><ul>';
                topContent.forEach(content => {
                    topContentHtml += `<li><strong>${content.product_name}</strong> (${content.template_type}): ${content.views.toLocaleString()} views, ${content.engagement_rate}% engagement</li>`;
                });
                topContentHtml += '</ul>';
                
                chartsContainer.innerHTML = templatesHtml + topContentHtml;
            }
            
            function updateInsights(insights) {
                const insightsContainer = document.getElementById('insights-container');
                
                if (insights.length === 0) {
                    insightsContainer.innerHTML = '<p>No insights available at the moment.</p>';
                    return;
                }
                
                let insightsHtml = '';
                insights.forEach(insight => {
                    insightsHtml += `
                        <div class="insight ${insight.priority}">
                            <strong>${insight.title}</strong><br>
                            ${insight.message}
                        </div>
                    `;
                });
                
                insightsContainer.innerHTML = insightsHtml;
            }
            
            // Load dashboard on page load
            loadDashboard();
            
            // Refresh every 30 seconds
            setInterval(loadDashboard, 30000);
        </script>
    </body>
    </html>
    '''
    return dashboard_html

if __name__ == '__main__':
    print("📊 Starting VitalFlow Analytics System...")
    print("🔍 Monitoring system performance...")
    print("📈 Dashboard available at http://localhost:5002/dashboard")
    print("🌐 API server starting on port 5002...")
    
    app.run(host='0.0.0.0', port=5002, debug=True)

