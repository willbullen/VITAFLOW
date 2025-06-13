#!/usr/bin/env python3
"""
VitalFlow Automation Health Check Script
Monitors all services and provides detailed health status
"""

import argparse
import json
import requests
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path
import psutil
import sqlite3

class HealthChecker:
    def __init__(self, environment='staging', detailed=False):
        self.environment = environment
        self.detailed = detailed
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'environment': environment,
            'overall_status': 'unknown',
            'services': {},
            'system': {},
            'database': {},
            'external': {}
        }
        
    def check_service_health(self, service_name, url, expected_status=200):
        """Check if a service is responding"""
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == expected_status:
                self.results['services'][service_name] = {
                    'status': 'healthy',
                    'response_time': response.elapsed.total_seconds(),
                    'status_code': response.status_code
                }
                return True
            else:
                self.results['services'][service_name] = {
                    'status': 'unhealthy',
                    'response_time': response.elapsed.total_seconds(),
                    'status_code': response.status_code,
                    'error': f'Unexpected status code: {response.status_code}'
                }
                return False
        except Exception as e:
            self.results['services'][service_name] = {
                'status': 'unhealthy',
                'error': str(e)
            }
            return False
    
    def check_process_health(self, process_name, pid_file=None):
        """Check if a process is running"""
        try:
            if pid_file and Path(pid_file).exists():
                with open(pid_file, 'r') as f:
                    pid = int(f.read().strip())
                
                if psutil.pid_exists(pid):
                    process = psutil.Process(pid)
                    self.results['services'][process_name] = {
                        'status': 'healthy',
                        'pid': pid,
                        'cpu_percent': process.cpu_percent(),
                        'memory_percent': process.memory_percent(),
                        'create_time': datetime.fromtimestamp(process.create_time()).isoformat()
                    }
                    return True
            
            # Fallback: search by process name
            for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
                if process_name.lower() in ' '.join(proc.info['cmdline']).lower():
                    self.results['services'][process_name] = {
                        'status': 'healthy',
                        'pid': proc.info['pid'],
                        'cpu_percent': proc.cpu_percent(),
                        'memory_percent': proc.memory_percent()
                    }
                    return True
            
            self.results['services'][process_name] = {
                'status': 'unhealthy',
                'error': 'Process not found'
            }
            return False
            
        except Exception as e:
            self.results['services'][process_name] = {
                'status': 'unhealthy',
                'error': str(e)
            }
            return False
    
    def check_system_health(self):
        """Check system resources"""
        try:
            # CPU usage
            cpu_percent = psutil.cpu_percent(interval=1)
            
            # Memory usage
            memory = psutil.virtual_memory()
            
            # Disk usage
            disk = psutil.disk_usage('/')
            
            # Load average (Linux/Mac only)
            try:
                load_avg = psutil.getloadavg()
            except AttributeError:
                load_avg = [0, 0, 0]  # Windows fallback
            
            self.results['system'] = {
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_available_gb': round(memory.available / (1024**3), 2),
                'disk_percent': round((disk.used / disk.total) * 100, 2),
                'disk_free_gb': round(disk.free / (1024**3), 2),
                'load_average': load_avg,
                'status': 'healthy' if cpu_percent < 80 and memory.percent < 80 else 'warning'
            }
            
            return self.results['system']['status'] == 'healthy'
            
        except Exception as e:
            self.results['system'] = {
                'status': 'unhealthy',
                'error': str(e)
            }
            return False
    
    def check_database_health(self):
        """Check database connectivity and status"""
        try:
            # Check main database
            db_path = 'data/vitalflow.db'
            if Path(db_path).exists():
                conn = sqlite3.connect(db_path)
                cursor = conn.cursor()
                
                # Test query
                cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
                table_count = cursor.fetchone()[0]
                
                # Get database size
                db_size = Path(db_path).stat().st_size / (1024**2)  # MB
                
                conn.close()
                
                self.results['database']['main'] = {
                    'status': 'healthy',
                    'table_count': table_count,
                    'size_mb': round(db_size, 2),
                    'path': db_path
                }
            else:
                self.results['database']['main'] = {
                    'status': 'warning',
                    'error': 'Database file not found'
                }
            
            # Check analytics database
            analytics_db_path = 'data/analytics.db'
            if Path(analytics_db_path).exists():
                conn = sqlite3.connect(analytics_db_path)
                cursor = conn.cursor()
                
                cursor.execute("SELECT COUNT(*) FROM sqlite_master WHERE type='table'")
                table_count = cursor.fetchone()[0]
                
                db_size = Path(analytics_db_path).stat().st_size / (1024**2)  # MB
                
                conn.close()
                
                self.results['database']['analytics'] = {
                    'status': 'healthy',
                    'table_count': table_count,
                    'size_mb': round(db_size, 2),
                    'path': analytics_db_path
                }
            else:
                self.results['database']['analytics'] = {
                    'status': 'warning',
                    'error': 'Analytics database file not found'
                }
            
            return True
            
        except Exception as e:
            self.results['database'] = {
                'status': 'unhealthy',
                'error': str(e)
            }
            return False
    
    def check_external_dependencies(self):
        """Check external service dependencies"""
        external_services = {
            'TikTok API': 'https://open-api.tiktok.com/platform/oauth/connect/',
            'Supliful API': 'https://api.supliful.com/health',
            'OpenAI API': 'https://api.openai.com/v1/models'
        }
        
        all_healthy = True
        
        for service_name, url in external_services.items():
            try:
                response = requests.get(url, timeout=10)
                if response.status_code in [200, 401, 403]:  # 401/403 means API is up but needs auth
                    self.results['external'][service_name] = {
                        'status': 'healthy',
                        'response_time': response.elapsed.total_seconds(),
                        'status_code': response.status_code
                    }
                else:
                    self.results['external'][service_name] = {
                        'status': 'unhealthy',
                        'status_code': response.status_code,
                        'error': f'Unexpected status code: {response.status_code}'
                    }
                    all_healthy = False
            except Exception as e:
                self.results['external'][service_name] = {
                    'status': 'unhealthy',
                    'error': str(e)
                }
                all_healthy = False
        
        return all_healthy
    
    def run_health_checks(self):
        """Run all health checks"""
        print(f"🏥 Running VitalFlow health checks for {self.environment} environment...")
        
        # Service health checks
        service_checks = [
            ('API Service', 'http://localhost:5000/health', 'logs/api.pid'),
            ('TikTok Automation', 'http://localhost:5001/health', 'logs/tiktok.pid'),
            ('Analytics Service', 'http://localhost:5002/health', 'logs/analytics.pid'),
            ('n8n Workflows', 'http://localhost:5678/healthz', 'logs/n8n.pid')
        ]
        
        services_healthy = 0
        total_services = len(service_checks)
        
        for service_name, url, pid_file in service_checks:
            print(f"  🔍 Checking {service_name}...")
            
            # Try HTTP health check first
            if self.check_service_health(service_name, url):
                print(f"    ✅ {service_name} is healthy")
                services_healthy += 1
            else:
                # Fallback to process check
                if self.check_process_health(service_name, pid_file):
                    print(f"    ⚠️  {service_name} process is running but HTTP check failed")
                    services_healthy += 0.5
                else:
                    print(f"    ❌ {service_name} is unhealthy")
        
        # System health check
        print("  🔍 Checking system resources...")
        if self.check_system_health():
            print("    ✅ System resources are healthy")
        else:
            print("    ⚠️  System resources are under stress")
        
        # Database health check
        print("  🔍 Checking database connectivity...")
        if self.check_database_health():
            print("    ✅ Database is healthy")
        else:
            print("    ❌ Database issues detected")
        
        # External dependencies check
        if self.detailed:
            print("  🔍 Checking external dependencies...")
            if self.check_external_dependencies():
                print("    ✅ External services are accessible")
            else:
                print("    ⚠️  Some external services may be unavailable")
        
        # Determine overall status
        service_health_ratio = services_healthy / total_services
        
        if service_health_ratio >= 1.0:
            self.results['overall_status'] = 'healthy'
            print("\n🎉 Overall Status: HEALTHY")
            return True
        elif service_health_ratio >= 0.75:
            self.results['overall_status'] = 'warning'
            print("\n⚠️  Overall Status: WARNING")
            return True
        else:
            self.results['overall_status'] = 'unhealthy'
            print("\n❌ Overall Status: UNHEALTHY")
            return False
    
    def generate_report(self):
        """Generate detailed health report"""
        report_file = f"health_report_{self.environment}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        with open(report_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\n📊 Detailed health report saved to: {report_file}")
        
        if self.detailed:
            print("\n📋 Health Summary:")
            print(f"   Environment: {self.environment}")
            print(f"   Overall Status: {self.results['overall_status'].upper()}")
            print(f"   Timestamp: {self.results['timestamp']}")
            
            print("\n🔧 Services:")
            for service, status in self.results['services'].items():
                status_icon = "✅" if status['status'] == 'healthy' else "❌"
                print(f"   {status_icon} {service}: {status['status']}")
            
            print("\n💻 System:")
            system = self.results['system']
            print(f"   CPU: {system.get('cpu_percent', 'N/A')}%")
            print(f"   Memory: {system.get('memory_percent', 'N/A')}%")
            print(f"   Disk: {system.get('disk_percent', 'N/A')}%")
            
            if self.results['external']:
                print("\n🌐 External Services:")
                for service, status in self.results['external'].items():
                    status_icon = "✅" if status['status'] == 'healthy' else "❌"
                    print(f"   {status_icon} {service}: {status['status']}")

def main():
    parser = argparse.ArgumentParser(description='VitalFlow Automation Health Check')
    parser.add_argument('--environment', '-e', default='staging', 
                       choices=['staging', 'production'],
                       help='Environment to check (default: staging)')
    parser.add_argument('--detailed', '-d', action='store_true',
                       help='Run detailed health checks including external dependencies')
    parser.add_argument('--json', '-j', action='store_true',
                       help='Output results in JSON format')
    
    args = parser.parse_args()
    
    checker = HealthChecker(args.environment, args.detailed)
    
    try:
        is_healthy = checker.run_health_checks()
        
        if args.json:
            print(json.dumps(checker.results, indent=2))
        else:
            checker.generate_report()
        
        # Exit with appropriate code
        sys.exit(0 if is_healthy else 1)
        
    except KeyboardInterrupt:
        print("\n⏹️  Health check interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Health check failed with error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()

