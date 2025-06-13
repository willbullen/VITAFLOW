import json
import os
from datetime import datetime, timedelta
import schedule
import time
import threading
from flask import Flask, request, jsonify
import requests

class TikTokPostingAutomation:
    def __init__(self):
        self.content_dir = "/home/ubuntu/generated_content"
        self.posted_content_dir = "/home/ubuntu/posted_content"
        self.scheduling_enabled = True
        self.posting_schedule = {
            'times': ['08:00', '12:00', '18:00'],  # Optimal posting times
            'frequency': 'daily',
            'max_posts_per_day': 3
        }
        self.ensure_directories()
        self.setup_scheduler()
    
    def ensure_directories(self):
        """Ensure all necessary directories exist"""
        os.makedirs(self.content_dir, exist_ok=True)
        os.makedirs(self.posted_content_dir, exist_ok=True)
    
    def setup_scheduler(self):
        """Setup the posting scheduler"""
        for post_time in self.posting_schedule['times']:
            schedule.every().day.at(post_time).do(self.automated_post)
        
        # Start scheduler in background thread
        scheduler_thread = threading.Thread(target=self.run_scheduler, daemon=True)
        scheduler_thread.start()
        print(f"📅 Scheduler started with posting times: {self.posting_schedule['times']}")
    
    def run_scheduler(self):
        """Run the scheduler continuously"""
        while self.scheduling_enabled:
            schedule.run_pending()
            time.sleep(60)  # Check every minute
    
    def automated_post(self):
        """Automatically post content to TikTok"""
        try:
            print("🚀 Starting automated TikTok posting...")
            
            # Get ready content
            ready_content = self.get_ready_content()
            
            if not ready_content:
                print("📭 No content ready for posting")
                return
            
            # Select content to post
            content_to_post = ready_content[0]  # Get the oldest ready content
            
            # Post to TikTok
            success = self.post_to_tiktok(content_to_post)
            
            if success:
                # Move content to posted directory
                self.mark_content_as_posted(content_to_post)
                print(f"✅ Successfully posted content: {content_to_post['id']}")
            else:
                print(f"❌ Failed to post content: {content_to_post['id']}")
                
        except Exception as e:
            print(f"❌ Error in automated posting: {e}")
    
    def get_ready_content(self):
        """Get content that's ready for posting"""
        ready_content = []
        
        try:
            for filename in os.listdir(self.content_dir):
                if filename.startswith('content_package_') and filename.endswith('.json'):
                    filepath = os.path.join(self.content_dir, filename)
                    
                    with open(filepath, 'r') as f:
                        content_package = json.load(f)
                    
                    if content_package.get('status') == 'ready_for_posting':
                        ready_content.append(content_package)
            
            # Sort by creation time (oldest first)
            ready_content.sort(key=lambda x: x.get('generated_at', ''))
            
        except Exception as e:
            print(f"Error getting ready content: {e}")
        
        return ready_content
    
    def post_to_tiktok(self, content_package):
        """Post content to TikTok (simulated for now)"""
        try:
            print(f"📱 Posting to TikTok: {content_package['id']}")
            
            # In a real implementation, this would use TikTok's API
            # For now, we'll simulate the posting process
            
            post_data = {
                'video_description': self.create_tiktok_description(content_package),
                'hashtags': content_package['content']['hashtags'],
                'images': content_package.get('images', []),
                'product_id': content_package['product']['id'],
                'template_type': content_package['template']['type']
            }
            
            # Simulate API call delay
            time.sleep(2)
            
            # Simulate successful posting (90% success rate)
            import random
            success = random.random() > 0.1
            
            if success:
                print(f"✅ TikTok post successful!")
                print(f"📝 Description: {post_data['video_description'][:100]}...")
                print(f"🏷️ Hashtags: {' '.join(post_data['hashtags'][:5])}")
                return True
            else:
                print(f"❌ TikTok post failed!")
                return False
                
        except Exception as e:
            print(f"Error posting to TikTok: {e}")
            return False
    
    def create_tiktok_description(self, content_package):
        """Create TikTok post description"""
        content = content_package['content']
        product = content_package['product']
        
        description = f"{content['hook']}\n\n"
        description += f"{content['script'][:200]}...\n\n"
        description += f"{content['cta']}\n\n"
        description += f"Shop {product['name']} in our TikTok Shop! 🛒\n\n"
        description += " ".join(content['hashtags'])
        
        return description
    
    def mark_content_as_posted(self, content_package):
        """Mark content as posted and move to posted directory"""
        try:
            # Update content package
            content_package['status'] = 'posted'
            content_package['posted_at'] = datetime.now().isoformat()
            
            # Save to posted directory
            posted_filename = f"{self.posted_content_dir}/posted_{content_package['id']}.json"
            with open(posted_filename, 'w') as f:
                json.dump(content_package, f, indent=2)
            
            # Remove from ready directory
            original_filename = f"{self.content_dir}/content_package_{content_package['id']}.json"
            if os.path.exists(original_filename):
                os.remove(original_filename)
            
            print(f"📁 Content moved to posted directory: {posted_filename}")
            
        except Exception as e:
            print(f"Error marking content as posted: {e}")
    
    def schedule_immediate_post(self, content_id):
        """Schedule an immediate post"""
        try:
            content_file = f"{self.content_dir}/content_package_{content_id}.json"
            
            if not os.path.exists(content_file):
                return False, "Content not found"
            
            with open(content_file, 'r') as f:
                content_package = json.load(f)
            
            success = self.post_to_tiktok(content_package)
            
            if success:
                self.mark_content_as_posted(content_package)
                return True, "Posted successfully"
            else:
                return False, "Posting failed"
                
        except Exception as e:
            return False, f"Error: {e}"
    
    def get_posting_schedule(self):
        """Get current posting schedule"""
        return {
            'schedule': self.posting_schedule,
            'enabled': self.scheduling_enabled,
            'next_posts': self.get_next_scheduled_posts()
        }
    
    def get_next_scheduled_posts(self):
        """Get next scheduled post times"""
        next_posts = []
        now = datetime.now()
        
        for post_time in self.posting_schedule['times']:
            hour, minute = map(int, post_time.split(':'))
            next_post = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
            
            if next_post <= now:
                next_post += timedelta(days=1)
            
            next_posts.append({
                'time': next_post.strftime('%Y-%m-%d %H:%M'),
                'relative': self.get_relative_time(next_post)
            })
        
        return sorted(next_posts, key=lambda x: x['time'])
    
    def get_relative_time(self, target_time):
        """Get relative time string"""
        now = datetime.now()
        diff = target_time - now
        
        if diff.days > 0:
            return f"in {diff.days} day{'s' if diff.days > 1 else ''}"
        elif diff.seconds > 3600:
            hours = diff.seconds // 3600
            return f"in {hours} hour{'s' if hours > 1 else ''}"
        elif diff.seconds > 60:
            minutes = diff.seconds // 60
            return f"in {minutes} minute{'s' if minutes > 1 else ''}"
        else:
            return "in less than a minute"
    
    def update_schedule(self, new_schedule):
        """Update posting schedule"""
        try:
            self.posting_schedule.update(new_schedule)
            
            # Clear existing schedule
            schedule.clear()
            
            # Setup new schedule
            for post_time in self.posting_schedule['times']:
                schedule.every().day.at(post_time).do(self.automated_post)
            
            print(f"📅 Schedule updated: {self.posting_schedule['times']}")
            return True
            
        except Exception as e:
            print(f"Error updating schedule: {e}")
            return False
    
    def get_posting_analytics(self):
        """Get posting analytics"""
        try:
            posted_content = []
            
            if os.path.exists(self.posted_content_dir):
                for filename in os.listdir(self.posted_content_dir):
                    if filename.startswith('posted_') and filename.endswith('.json'):
                        filepath = os.path.join(self.posted_content_dir, filename)
                        
                        with open(filepath, 'r') as f:
                            content = json.load(f)
                            posted_content.append(content)
            
            # Calculate analytics
            total_posts = len(posted_content)
            posts_today = len([c for c in posted_content 
                             if c.get('posted_at', '').startswith(datetime.now().strftime('%Y-%m-%d'))])
            
            template_stats = {}
            product_stats = {}
            
            for content in posted_content:
                template_type = content.get('template', {}).get('type', 'unknown')
                product_name = content.get('product', {}).get('name', 'unknown')
                
                template_stats[template_type] = template_stats.get(template_type, 0) + 1
                product_stats[product_name] = product_stats.get(product_name, 0) + 1
            
            return {
                'total_posts': total_posts,
                'posts_today': posts_today,
                'template_distribution': template_stats,
                'product_distribution': product_stats,
                'recent_posts': posted_content[-5:] if posted_content else []
            }
            
        except Exception as e:
            print(f"Error getting analytics: {e}")
            return {}

# Flask API for TikTok automation
app = Flask(__name__)
automation = TikTokPostingAutomation()

@app.route('/api/tiktok/schedule', methods=['GET'])
def get_schedule():
    """Get current posting schedule"""
    return jsonify({
        'success': True,
        'schedule': automation.get_posting_schedule()
    })

@app.route('/api/tiktok/schedule', methods=['POST'])
def update_schedule():
    """Update posting schedule"""
    try:
        data = request.get_json()
        success = automation.update_schedule(data)
        
        return jsonify({
            'success': success,
            'message': 'Schedule updated successfully' if success else 'Failed to update schedule'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/tiktok/post-now', methods=['POST'])
def post_now():
    """Post content immediately"""
    try:
        data = request.get_json()
        content_id = data.get('content_id')
        
        success, message = automation.schedule_immediate_post(content_id)
        
        return jsonify({
            'success': success,
            'message': message
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/tiktok/analytics', methods=['GET'])
def get_analytics():
    """Get posting analytics"""
    try:
        analytics = automation.get_posting_analytics()
        
        return jsonify({
            'success': True,
            'analytics': analytics
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/api/tiktok/ready-content', methods=['GET'])
def get_ready_content():
    """Get content ready for posting"""
    try:
        ready_content = automation.get_ready_content()
        
        return jsonify({
            'success': True,
            'content': ready_content
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

if __name__ == '__main__':
    print("🚀 Starting TikTok Posting Automation System...")
    print("📅 Automated posting enabled")
    print(f"⏰ Posting times: {automation.posting_schedule['times']}")
    print("🌐 API server starting on port 5001...")
    
    app.run(host='0.0.0.0', port=5001, debug=True)

