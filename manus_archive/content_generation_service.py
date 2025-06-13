import requests
import json
import os
from datetime import datetime
import random

class ContentGenerationService:
    def __init__(self, api_base_url="http://localhost:5000/api/automation"):
        self.api_base_url = api_base_url
        self.content_output_dir = "/home/ubuntu/generated_content"
        self.ensure_output_directory()
    
    def ensure_output_directory(self):
        """Ensure the output directory exists"""
        if not os.path.exists(self.content_output_dir):
            os.makedirs(self.content_output_dir)
    
    def generate_automated_content(self):
        """Generate content automatically for TikTok posting"""
        try:
            # Get products from API
            products_response = requests.get(f"{self.api_base_url}/products")
            products_data = products_response.json()
            
            if not products_data.get('success'):
                raise Exception("Failed to fetch products")
            
            products = products_data['products']
            
            # Get content templates
            templates_response = requests.get(f"{self.api_base_url}/content-templates")
            templates_data = templates_response.json()
            
            if not templates_data.get('success'):
                raise Exception("Failed to fetch templates")
            
            templates = templates_data['templates']
            
            # Generate content for random product and template
            selected_product = random.choice(products)
            selected_template = random.choice(templates)
            
            # Generate content via API
            content_response = requests.post(f"{self.api_base_url}/generate-content", 
                                           json={
                                               'product_id': selected_product['id'],
                                               'template_type': selected_template['type']
                                           })
            
            content_data = content_response.json()
            
            if not content_data.get('success'):
                raise Exception("Failed to generate content")
            
            content = content_data['content']
            
            # Generate visual content (images/videos)
            visual_content = self.generate_visual_content(selected_product, selected_template, content)
            
            # Create complete content package
            content_package = {
                'id': f"content_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                'product': selected_product,
                'template': selected_template,
                'content': content,
                'visual_content': visual_content,
                'generated_at': datetime.now().isoformat(),
                'status': 'ready_for_posting'
            }
            
            # Save content package
            self.save_content_package(content_package)
            
            return content_package
            
        except Exception as e:
            print(f"Error generating automated content: {e}")
            return None
    
    def generate_visual_content(self, product, template, content):
        """Generate visual content (images/videos) for the post"""
        visual_content = {
            'images': [],
            'videos': [],
            'thumbnails': []
        }
        
        try:
            # Generate main content image based on template type
            if template['type'] == 'grwm':
                image_path = self.generate_grwm_image(product, content)
            elif template['type'] == 'education':
                image_path = self.generate_education_image(product, content)
            elif template['type'] == 'transformation':
                image_path = self.generate_transformation_image(product, content)
            elif template['type'] == 'myth_busting':
                image_path = self.generate_myth_busting_image(product, content)
            else:
                image_path = self.generate_trending_image(product, content)
            
            if image_path:
                visual_content['images'].append(image_path)
            
            # Generate product showcase image
            product_image_path = self.generate_product_showcase_image(product)
            if product_image_path:
                visual_content['images'].append(product_image_path)
            
            # Generate thumbnail for TikTok
            thumbnail_path = self.generate_thumbnail_image(product, template)
            if thumbnail_path:
                visual_content['thumbnails'].append(thumbnail_path)
            
        except Exception as e:
            print(f"Error generating visual content: {e}")
        
        return visual_content
    
    def generate_grwm_image(self, product, content):
        """Generate Get Ready With Me style image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/grwm_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok-style Get Ready With Me morning routine scene featuring {product['name']} supplement. 
        Modern, bright bathroom or bedroom setting with natural lighting. Young person in their 20s-30s taking 
        {product['name']} supplement as part of their morning routine. Clean, aesthetic setup with skincare products, 
        water bottle, and the supplement bottle prominently displayed. Warm, inviting atmosphere with soft morning 
        light. Professional lifestyle photography style, Instagram-worthy composition. The supplement bottle should 
        be clearly visible and well-lit. Include elements like a mirror, plants, and modern decor to create an 
        aspirational wellness lifestyle aesthetic."""
        
        # This would integrate with the image generation API
        # For now, we'll simulate the image generation
        print(f"Generating GRWM image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_education_image(self, product, content):
        """Generate educational content image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/education_{product['id']}_{timestamp}.png"
        
        main_ingredient = product['ingredients'][0]
        
        prompt = f"""Educational TikTok-style infographic about {main_ingredient} supplement ingredient. 
        Clean, modern design with scientific elements. Show molecular structure or plant source of {main_ingredient}. 
        Include text overlays with key benefits: {', '.join(product['benefits'])}. Professional medical/scientific 
        aesthetic with blue and green color scheme. Include {product['name']} bottle in corner. Modern typography, 
        clean layout, Instagram-worthy design. Scientific charts, graphs, or research elements in background. 
        Professional supplement education content style."""
        
        print(f"Generating education image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_transformation_image(self, product, content):
        """Generate transformation story image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/transformation_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok transformation before/after style image for {product['name']} supplement. 
        Split-screen or side-by-side comparison showing wellness journey. Left side: tired, low energy person. 
        Right side: energized, vibrant, healthy person. Include {product['name']} bottle as the connecting element. 
        Bright, motivational colors. Text overlays showing timeline (30 days, 3 months). Professional lifestyle 
        photography with good lighting. Inspirational wellness transformation aesthetic. Include elements showing 
        improved energy, better mood, healthier lifestyle."""
        
        print(f"Generating transformation image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_myth_busting_image(self, product, content):
        """Generate myth-busting content image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/myth_busting_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok myth-busting style image about supplement misconceptions. Bold, attention-grabbing design 
        with large "MYTH" text crossed out and "FACT" highlighted. Include {product['name']} bottle and scientific 
        elements. Red and green color scheme for myth vs fact. Modern, bold typography. Include research papers, 
        scientific symbols, or lab equipment in background. Professional, authoritative design that builds trust. 
        Clean, educational layout with clear visual hierarchy."""
        
        print(f"Generating myth-busting image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_trending_image(self, product, content):
        """Generate trending format image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/trending_{product['id']}_{timestamp}.png"
        
        prompt = f"""Trendy TikTok-style image for {product['name']} supplement using popular social media format. 
        Bright, colorful, Gen-Z aesthetic with bold graphics and modern design elements. Include {product['name']} 
        bottle as hero product. Use popular TikTok visual trends like neon colors, geometric shapes, or gradient 
        backgrounds. Text overlays with trending phrases. High-energy, youthful vibe. Professional product photography 
        with creative, eye-catching composition. Instagram and TikTok optimized visual style."""
        
        print(f"Generating trending image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_product_showcase_image(self, product):
        """Generate product showcase image"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/product_{product['id']}_{timestamp}.png"
        
        prompt = f"""Professional product photography of {product['name']} supplement bottle. Clean, minimalist 
        background with soft lighting. High-quality commercial photography style. Show supplement bottle clearly 
        with label visible. Include natural elements like plants or stones to emphasize natural ingredients. 
        Soft shadows and professional lighting setup. Premium supplement brand aesthetic. Clean, modern composition 
        suitable for e-commerce and social media. Professional studio photography quality."""
        
        print(f"Generating product showcase image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def generate_thumbnail_image(self, product, template):
        """Generate thumbnail for TikTok"""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        image_path = f"{self.content_output_dir}/thumbnail_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok thumbnail image for {product['name']} supplement content. Bright, eye-catching design 
        optimized for mobile viewing. Include {product['name']} bottle prominently. Bold, readable text overlay 
        with key benefit or hook. High contrast colors that stand out in TikTok feed. Professional but approachable 
        aesthetic. Clear, simple composition that works at small sizes. Engaging visual that encourages clicks. 
        Modern social media design style."""
        
        print(f"Generating thumbnail image: {image_path}")
        print(f"Prompt: {prompt}")
        
        return image_path
    
    def save_content_package(self, content_package):
        """Save content package to file"""
        filename = f"{self.content_output_dir}/content_package_{content_package['id']}.json"
        
        with open(filename, 'w') as f:
            json.dump(content_package, f, indent=2)
        
        print(f"Content package saved: {filename}")
    
    def get_ready_content(self):
        """Get content that's ready for posting"""
        ready_content = []
        
        try:
            for filename in os.listdir(self.content_output_dir):
                if filename.startswith('content_package_') and filename.endswith('.json'):
                    filepath = os.path.join(self.content_output_dir, filename)
                    
                    with open(filepath, 'r') as f:
                        content_package = json.load(f)
                    
                    if content_package.get('status') == 'ready_for_posting':
                        ready_content.append(content_package)
        
        except Exception as e:
            print(f"Error getting ready content: {e}")
        
        return ready_content
    
    def mark_content_as_posted(self, content_id):
        """Mark content as posted"""
        try:
            filename = f"{self.content_output_dir}/content_package_{content_id}.json"
            
            if os.path.exists(filename):
                with open(filename, 'r') as f:
                    content_package = json.load(f)
                
                content_package['status'] = 'posted'
                content_package['posted_at'] = datetime.now().isoformat()
                
                with open(filename, 'w') as f:
                    json.dump(content_package, f, indent=2)
                
                print(f"Content {content_id} marked as posted")
                return True
        
        except Exception as e:
            print(f"Error marking content as posted: {e}")
        
        return False

# Example usage and testing
if __name__ == "__main__":
    service = ContentGenerationService()
    
    # Generate automated content
    content = service.generate_automated_content()
    
    if content:
        print("Content generated successfully!")
        print(f"Content ID: {content['id']}")
        print(f"Product: {content['product']['name']}")
        print(f"Template: {content['template']['type']}")
        print(f"Hook: {content['content']['hook']}")
    else:
        print("Failed to generate content")

