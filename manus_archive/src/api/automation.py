from flask import Blueprint, request, jsonify
import requests
import json
import os
from datetime import datetime, timedelta
import random

automation_bp = Blueprint('automation', __name__)

# VitalFlow product data
PRODUCTS = [
    {
        "id": "vitalflow_energy",
        "name": "VitalFlow Energy",
        "description": "Natural energy boost with adaptogens and B-vitamins for sustained vitality without the crash",
        "price": "$39.99",
        "benefits": ["Sustained Energy", "Mental Clarity", "No Crash", "Natural Ingredients"],
        "ingredients": ["Rhodiola Rosea", "B-Complex", "Ginseng", "Green Tea Extract"],
        "category": "energy"
    },
    {
        "id": "vitalflow_calm",
        "name": "VitalFlow Calm",
        "description": "Stress relief and better sleep with ashwagandha and magnesium for natural relaxation",
        "price": "$34.99",
        "benefits": ["Stress Relief", "Better Sleep", "Mood Support", "Natural Calm"],
        "ingredients": ["Ashwagandha", "Magnesium", "L-Theanine", "Chamomile"],
        "category": "calm"
    }
]

# Content templates based on successful TikTok formats
CONTENT_TEMPLATES = [
    {
        "type": "grwm",
        "hook": "POV: You finally found a supplement that actually works",
        "structure": "Morning routine with supplement integration",
        "cta": "Try this for 30 days and see the difference"
    },
    {
        "type": "education",
        "hook": "This ingredient changed my {benefit} in {timeframe}",
        "structure": "Ingredient spotlight with scientific backing",
        "cta": "Comment '{keyword}' for my supplement recommendations"
    },
    {
        "type": "transformation",
        "hook": "I wish I knew about {ingredient} sooner",
        "structure": "Before/after wellness journey",
        "cta": "Link in bio for the supplement that changed my {benefit}"
    },
    {
        "type": "myth_busting",
        "hook": "Stop believing this supplement myth",
        "structure": "Debunk common misconceptions",
        "cta": "Follow for more wellness facts"
    },
    {
        "type": "trending",
        "hook": "Using trending audio for wellness education",
        "structure": "Adapt viral format for supplement education",
        "cta": "Save this for your wellness journey"
    }
]

@automation_bp.route('/generate-content', methods=['POST'])
def generate_content():
    """Generate TikTok content based on product and template"""
    try:
        data = request.get_json()
        product_id = data.get('product_id', random.choice(PRODUCTS)['id'])
        template_type = data.get('template_type', random.choice(CONTENT_TEMPLATES)['type'])
        
        # Find product and template
        product = next((p for p in PRODUCTS if p['id'] == product_id), PRODUCTS[0])
        template = next((t for t in CONTENT_TEMPLATES if t['type'] == template_type), CONTENT_TEMPLATES[0])
        
        # Generate content based on template
        content = generate_content_from_template(product, template)
        
        return jsonify({
            'success': True,
            'content': content,
            'product': product,
            'template': template
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@automation_bp.route('/schedule-post', methods=['POST'])
def schedule_post():
    """Schedule a TikTok post"""
    try:
        data = request.get_json()
        content = data.get('content')
        schedule_time = data.get('schedule_time')
        
        # In a real implementation, this would integrate with TikTok's API
        # For now, we'll simulate the scheduling
        
        post_data = {
            'id': f"post_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
            'content': content,
            'scheduled_for': schedule_time,
            'status': 'scheduled',
            'created_at': datetime.now().isoformat()
        }
        
        # Store in database or queue system
        save_scheduled_post(post_data)
        
        return jsonify({
            'success': True,
            'post_id': post_data['id'],
            'message': 'Post scheduled successfully'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@automation_bp.route('/automation-status', methods=['GET'])
def automation_status():
    """Get current automation status and metrics"""
    try:
        status = {
            'active_workflows': 3,
            'posts_scheduled': 15,
            'posts_published_today': 2,
            'engagement_rate': '4.8%',
            'last_post': '2 hours ago',
            'next_post': '4 hours',
            'system_status': 'running',
            'content_queue': 8
        }
        
        return jsonify({
            'success': True,
            'status': status
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

@automation_bp.route('/products', methods=['GET'])
def get_products():
    """Get all available products"""
    return jsonify({
        'success': True,
        'products': PRODUCTS
    })

@automation_bp.route('/content-templates', methods=['GET'])
def get_content_templates():
    """Get all content templates"""
    return jsonify({
        'success': True,
        'templates': CONTENT_TEMPLATES
    })

@automation_bp.route('/analytics', methods=['GET'])
def get_analytics():
    """Get content performance analytics"""
    try:
        # Simulate analytics data
        analytics = {
            'total_posts': 45,
            'total_views': 125000,
            'total_likes': 8500,
            'total_shares': 1200,
            'total_comments': 650,
            'engagement_rate': 8.2,
            'top_performing_content': [
                {
                    'type': 'grwm',
                    'views': 25000,
                    'engagement': 12.5
                },
                {
                    'type': 'education',
                    'views': 18000,
                    'engagement': 9.8
                }
            ],
            'best_posting_times': ['8:00 AM', '12:00 PM', '6:00 PM'],
            'audience_demographics': {
                'age_18_24': 35,
                'age_25_34': 45,
                'age_35_44': 20
            }
        }
        
        return jsonify({
            'success': True,
            'analytics': analytics
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500

def generate_content_from_template(product, template):
    """Generate specific content based on product and template"""
    
    # Select random benefit and ingredient
    benefit = random.choice(product['benefits']).lower()
    ingredient = random.choice(product['ingredients'])
    
    # Generate hook based on template
    hook = template['hook']
    if '{benefit}' in hook:
        hook = hook.replace('{benefit}', benefit)
    if '{ingredient}' in hook:
        hook = hook.replace('{ingredient}', ingredient)
    if '{timeframe}' in hook:
        timeframes = ['2 weeks', '30 days', '1 month', '3 weeks']
        hook = hook.replace('{timeframe}', random.choice(timeframes))
    
    # Generate CTA
    cta = template['cta']
    if '{benefit}' in cta:
        cta = cta.replace('{benefit}', benefit)
    if '{keyword}' in cta:
        keywords = ['ENERGY', 'CALM', 'WELLNESS', 'NATURAL']
        cta = cta.replace('{keyword}', random.choice(keywords))
    
    # Generate script based on template type
    if template['type'] == 'grwm':
        script = generate_grwm_script(product, hook, cta)
    elif template['type'] == 'education':
        script = generate_education_script(product, ingredient, hook, cta)
    elif template['type'] == 'transformation':
        script = generate_transformation_script(product, hook, cta)
    elif template['type'] == 'myth_busting':
        script = generate_myth_busting_script(product, hook, cta)
    else:
        script = generate_trending_script(product, hook, cta)
    
    return {
        'hook': hook,
        'script': script,
        'cta': cta,
        'hashtags': generate_hashtags(product, template['type']),
        'visual_elements': generate_visual_elements(product, template['type'])
    }

def generate_grwm_script(product, hook, cta):
    """Generate Get Ready With Me script"""
    return f"""
{hook}

*Shows morning routine*

First thing I do is take my {product['name']} - it's literally changed my entire morning energy.

*Takes supplement with water*

The {product['ingredients'][0]} in this gives me sustained energy without the crash I used to get from coffee.

*Continues morning routine*

I've been taking this for a month now and the difference is incredible. No more afternoon energy crashes.

*Shows final look*

{cta}

#VitalFlowJourney #MorningRoutine #NaturalEnergy #WellnessTok
"""

def generate_education_script(product, ingredient, hook, cta):
    """Generate educational content script"""
    return f"""
{hook}

Let me tell you about {ingredient} - this ingredient is a game changer.

*Shows supplement bottle*

{ingredient} is clinically proven to support {random.choice(product['benefits']).lower()}.

*Visual of ingredient or research*

Studies show it can improve your wellness in just 2-3 weeks of consistent use.

*Shows taking supplement*

That's why I chose {product['name']} - it has the right dosage of {ingredient} plus other powerful ingredients.

{cta}

#WellnessEducation #{ingredient.replace(' ', '')} #SupplementFacts #NaturalWellness
"""

def generate_transformation_script(product, hook, cta):
    """Generate transformation story script"""
    return f"""
{hook}

3 months ago I was struggling with low energy every single day.

*Shows 'before' state*

I tried everything - more sleep, better diet, exercise - nothing worked.

*Shows supplement*

Then I discovered {product['name']} and everything changed.

*Shows 'after' state*

Now I wake up energized, stay focused all day, and actually enjoy my workouts.

*Shows current routine*

The {product['ingredients'][0]} and {product['ingredients'][1]} in this formula are scientifically proven to work.

{cta}

#TransformationTuesday #WellnessJourney #EnergyBoost #NaturalSupplements
"""

def generate_myth_busting_script(product, hook, cta):
    """Generate myth-busting content script"""
    myths = [
        "All supplements are the same",
        "Natural supplements don't work",
        "You don't need supplements if you eat well",
        "Supplements work immediately"
    ]
    
    myth = random.choice(myths)
    
    return f"""
{hook}

MYTH: {myth}

*Shows dramatic reaction*

This is completely false and here's why:

*Shows product and ingredients*

{product['name']} contains {product['ingredients'][0]} which is clinically studied and proven effective.

*Shows research or facts*

Quality matters - not all supplements use the right dosages or bioavailable forms.

*Shows taking supplement*

That's why I only trust brands that are third-party tested and science-backed.

{cta}

#MythBusting #SupplementFacts #WellnessEducation #ScienceBacked
"""

def generate_trending_script(product, hook, cta):
    """Generate trending format script"""
    return f"""
{hook}

*Uses trending audio/format*

POV: You discover the supplement that actually works

*Shows supplement dramatically*

Me before {product['name']}: tired, unfocused, struggling

*Shows transformation*

Me after {product['name']}: energized, clear-minded, thriving

*Shows ingredients*

The secret? {product['ingredients'][0]} + {product['ingredients'][1]} in the perfect ratio.

{cta}

#POV #SupplementTok #WellnessTransformation #TikTokMadeMeBuyIt
"""

def generate_hashtags(product, content_type):
    """Generate relevant hashtags"""
    base_hashtags = ['#VitalFlow', '#WellnessTok', '#SupplementTok', '#NaturalWellness']
    
    product_hashtags = []
    if product['category'] == 'energy':
        product_hashtags = ['#EnergyBoost', '#NaturalEnergy', '#MorningRoutine']
    else:
        product_hashtags = ['#StressRelief', '#BetterSleep', '#CalmVibes']
    
    content_hashtags = []
    if content_type == 'grwm':
        content_hashtags = ['#GRWM', '#MorningVibes', '#HealthyHabits']
    elif content_type == 'education':
        content_hashtags = ['#WellnessEducation', '#SupplementFacts', '#HealthTips']
    elif content_type == 'transformation':
        content_hashtags = ['#TransformationTuesday', '#WellnessJourney', '#GlowUp']
    
    return base_hashtags + product_hashtags + content_hashtags

def generate_visual_elements(product, content_type):
    """Generate visual elements suggestions"""
    elements = {
        'shots': [],
        'props': [],
        'effects': [],
        'transitions': []
    }
    
    if content_type == 'grwm':
        elements['shots'] = ['Close-up of supplement', 'Morning routine sequence', 'Before/after energy levels']
        elements['props'] = ['Water bottle', 'Morning skincare', 'Healthy breakfast']
        elements['effects'] = ['Time-lapse morning routine', 'Energy level graphics']
        elements['transitions'] = ['Quick cuts between routine steps']
    
    elif content_type == 'education':
        elements['shots'] = ['Ingredient close-up', 'Scientific facts overlay', 'Product demonstration']
        elements['props'] = ['Research papers', 'Ingredient samples', 'Measuring tools']
        elements['effects'] = ['Text overlays with facts', 'Zoom effects on ingredients']
        elements['transitions'] = ['Smooth slides between facts']
    
    return elements

def save_scheduled_post(post_data):
    """Save scheduled post to database or file"""
    # In a real implementation, this would save to a database
    # For now, we'll save to a JSON file
    
    posts_file = '/home/ubuntu/vitalflow-automation-api/scheduled_posts.json'
    
    try:
        if os.path.exists(posts_file):
            with open(posts_file, 'r') as f:
                posts = json.load(f)
        else:
            posts = []
        
        posts.append(post_data)
        
        with open(posts_file, 'w') as f:
            json.dump(posts, f, indent=2)
            
    except Exception as e:
        print(f"Error saving post: {e}")

