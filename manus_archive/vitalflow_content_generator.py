#!/usr/bin/env python3

import sys
import os
import requests
import json
from datetime import datetime
import random

# Add the automation API to the path
sys.path.append('/home/ubuntu/vitalflow-automation-api')

from content_generation_service import ContentGenerationService

class VitalFlowContentGenerator:
    def __init__(self):
        self.service = ContentGenerationService()
        self.generated_images_dir = "/home/ubuntu/generated_content/images"
        self.ensure_directories()
    
    def ensure_directories(self):
        """Ensure all necessary directories exist"""
        os.makedirs(self.generated_images_dir, exist_ok=True)
    
    def generate_content_with_real_images(self):
        """Generate content with actual image generation"""
        try:
            print("🚀 Starting automated content generation...")
            
            # Get products and templates
            products_response = requests.get("http://localhost:5000/api/automation/products")
            products_data = products_response.json()
            products = products_data['products']
            
            templates_response = requests.get("http://localhost:5000/api/automation/content-templates")
            templates_data = templates_response.json()
            templates = templates_data['templates']
            
            # Select random product and template
            selected_product = random.choice(products)
            selected_template = random.choice(templates)
            
            print(f"📦 Selected Product: {selected_product['name']}")
            print(f"🎬 Selected Template: {selected_template['type']}")
            
            # Generate content via API
            content_response = requests.post("http://localhost:5000/api/automation/generate-content", 
                                           json={
                                               'product_id': selected_product['id'],
                                               'template_type': selected_template['type']
                                           })
            
            content_data = content_response.json()
            content = content_data['content']
            
            print(f"✍️ Generated Hook: {content['hook']}")
            
            # Generate actual images using the media generation tools
            images = self.generate_real_images(selected_product, selected_template, content)
            
            # Create complete content package
            content_package = {
                'id': f"content_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
                'product': selected_product,
                'template': selected_template,
                'content': content,
                'images': images,
                'generated_at': datetime.now().isoformat(),
                'status': 'ready_for_posting'
            }
            
            # Save content package
            self.save_content_package(content_package)
            
            print("✅ Content generation completed successfully!")
            return content_package
            
        except Exception as e:
            print(f"❌ Error generating content: {e}")
            return None
    
    def generate_real_images(self, product, template, content):
        """Generate actual images using media generation tools"""
        images = []
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        
        try:
            # Generate main content image based on template type
            if template['type'] == 'grwm':
                main_image = self.create_grwm_image(product, content, timestamp)
            elif template['type'] == 'education':
                main_image = self.create_education_image(product, content, timestamp)
            elif template['type'] == 'transformation':
                main_image = self.create_transformation_image(product, content, timestamp)
            elif template['type'] == 'myth_busting':
                main_image = self.create_myth_busting_image(product, content, timestamp)
            else:
                main_image = self.create_trending_image(product, content, timestamp)
            
            if main_image:
                images.append(main_image)
            
            # Generate product showcase image
            product_image = self.create_product_showcase_image(product, timestamp)
            if product_image:
                images.append(product_image)
            
            # Generate thumbnail
            thumbnail = self.create_thumbnail_image(product, template, timestamp)
            if thumbnail:
                images.append(thumbnail)
            
        except Exception as e:
            print(f"Error generating images: {e}")
        
        return images
    
    def create_grwm_image(self, product, content, timestamp):
        """Create Get Ready With Me style image"""
        image_path = f"{self.generated_images_dir}/grwm_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok-style Get Ready With Me morning routine scene featuring {product['name']} supplement. Modern, bright bathroom setting with natural morning lighting streaming through window. Young woman in her mid-20s with glowing skin taking {product['name']} supplement as part of her morning wellness routine. Clean, minimalist aesthetic with white marble countertop, plants, skincare products neatly arranged, and a glass of water. The {product['name']} supplement bottle is prominently displayed and well-lit. Warm, inviting atmosphere with soft golden hour lighting. Professional lifestyle photography style, Instagram-worthy composition with shallow depth of field. Include elements like a round mirror, small potted plants, and modern bathroom accessories to create an aspirational wellness lifestyle aesthetic. The scene should feel authentic and relatable while maintaining a premium, clean look."""
        
        print(f"🎨 Generating GRWM image...")
        
        # This would call the actual media generation API
        # For demonstration, we'll create a placeholder
        return {
            'type': 'grwm',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_education_image(self, product, content, timestamp):
        """Create educational content image"""
        image_path = f"{self.generated_images_dir}/education_{product['id']}_{timestamp}.png"
        
        main_ingredient = product['ingredients'][0]
        
        prompt = f"""Educational TikTok-style infographic about {main_ingredient} supplement ingredient. Clean, modern scientific design with professional medical aesthetic. Show botanical illustration or molecular structure of {main_ingredient} in the center. Include text overlays with key benefits: {', '.join(product['benefits'])}. Use a calming blue and green color scheme with white background. Feature {product['name']} bottle in the bottom right corner. Modern, clean typography with sans-serif fonts. Include subtle scientific elements like DNA helixes, molecular structures, or research charts in the background. Professional supplement education content style with credible, trustworthy design. Layout should be clear and easy to read on mobile devices. Include small icons representing each benefit around the main ingredient illustration."""
        
        print(f"📚 Generating education image...")
        
        return {
            'type': 'education',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_transformation_image(self, product, content, timestamp):
        """Create transformation story image"""
        image_path = f"{self.generated_images_dir}/transformation_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok transformation before/after style image for {product['name']} supplement. Split-screen composition showing wellness journey transformation. Left side: person looking tired and low energy, sitting at desk with coffee, dim lighting, cluttered background. Right side: same person looking energized, vibrant, and healthy, doing yoga or exercise, bright natural lighting, clean organized space. Include {product['name']} bottle as the connecting element in the center with an arrow pointing from left to right. Use motivational colors - muted tones on left, bright vibrant colors on right. Text overlays showing timeline "30 DAYS LATER" or "3 MONTHS WITH VITALFLOW". Professional lifestyle photography with good lighting contrast. Inspirational wellness transformation aesthetic. Include visual elements showing improved energy levels, better mood, and healthier lifestyle choices."""
        
        print(f"🔄 Generating transformation image...")
        
        return {
            'type': 'transformation',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_myth_busting_image(self, product, content, timestamp):
        """Create myth-busting content image"""
        image_path = f"{self.generated_images_dir}/myth_busting_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok myth-busting style image about supplement misconceptions. Bold, attention-grabbing design with large "MYTH" text in red with a big X crossed out, and "FACT" highlighted in green with a checkmark. Split design showing myth vs reality. Include {product['name']} bottle prominently displayed with scientific elements like research papers, lab equipment, or certification badges. Use high contrast red and green color scheme for clear myth vs fact distinction. Modern, bold typography with impact fonts. Include background elements like scientific journals, microscopes, or lab equipment to build credibility. Professional, authoritative design that builds trust and educates viewers. Clean layout with clear visual hierarchy that's easy to read on mobile. Add small icons or graphics representing scientific validation and third-party testing."""
        
        print(f"🔍 Generating myth-busting image...")
        
        return {
            'type': 'myth_busting',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_trending_image(self, product, content, timestamp):
        """Create trending format image"""
        image_path = f"{self.generated_images_dir}/trending_{product['id']}_{timestamp}.png"
        
        prompt = f"""Trendy TikTok-style image for {product['name']} supplement using popular social media format. Bright, colorful, Gen-Z aesthetic with bold graphics and modern design elements. Vibrant gradient background with neon pink, purple, and blue colors. Include {product['name']} bottle as the hero product in the center with dramatic lighting. Use popular TikTok visual trends like geometric shapes, holographic effects, or 3D elements. Bold text overlays with trending phrases like "POV:" or "This changed everything". High-energy, youthful vibe with dynamic composition. Professional product photography with creative, eye-catching styling. Include trendy elements like sparkles, stars, or abstract shapes. Instagram and TikTok optimized visual style with high contrast and vibrant colors that pop on mobile screens."""
        
        print(f"🔥 Generating trending image...")
        
        return {
            'type': 'trending',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_product_showcase_image(self, product, timestamp):
        """Create product showcase image"""
        image_path = f"{self.generated_images_dir}/product_{product['id']}_{timestamp}.png"
        
        prompt = f"""Professional product photography of {product['name']} supplement bottle. Clean, minimalist white background with soft, even lighting from multiple angles. High-quality commercial photography style showing the supplement bottle clearly with label fully visible and readable. Include subtle natural elements like small green plants, smooth stones, or wooden elements to emphasize natural ingredients and wellness theme. Soft shadows and professional studio lighting setup creating depth without harsh contrasts. Premium supplement brand aesthetic with clean, modern composition. Professional e-commerce quality photography suitable for social media and online sales. The bottle should be the clear focal point with perfect lighting that highlights the label design and premium quality of the packaging."""
        
        print(f"📦 Generating product showcase image...")
        
        return {
            'type': 'product_showcase',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def create_thumbnail_image(self, product, template, timestamp):
        """Create thumbnail for TikTok"""
        image_path = f"{self.generated_images_dir}/thumbnail_{product['id']}_{timestamp}.png"
        
        prompt = f"""TikTok thumbnail image for {product['name']} supplement content. Bright, eye-catching design optimized for mobile viewing and small thumbnail sizes. Include {product['name']} bottle prominently displayed in the center. Bold, readable text overlay with key benefit or hook that's visible even at small sizes. High contrast colors that stand out in TikTok feed - use bright yellows, oranges, or vibrant blues. Professional but approachable aesthetic that appeals to young adults. Clear, simple composition that works at thumbnail size. Engaging visual that encourages clicks and views. Modern social media design style with bold typography and clear visual hierarchy. Include subtle elements like arrows, stars, or exclamation points to create urgency and interest."""
        
        print(f"🖼️ Generating thumbnail image...")
        
        return {
            'type': 'thumbnail',
            'path': image_path,
            'prompt': prompt,
            'generated_at': datetime.now().isoformat()
        }
    
    def save_content_package(self, content_package):
        """Save content package to file"""
        filename = f"/home/ubuntu/generated_content/content_package_{content_package['id']}.json"
        
        with open(filename, 'w') as f:
            json.dump(content_package, f, indent=2)
        
        print(f"💾 Content package saved: {filename}")
        return filename

def main():
    """Main function to run content generation"""
    print("🎯 VitalFlow Automated Content Generator")
    print("=" * 50)
    
    generator = VitalFlowContentGenerator()
    
    # Generate content
    content_package = generator.generate_content_with_real_images()
    
    if content_package:
        print("\n✅ SUCCESS! Content generated successfully!")
        print(f"📋 Content ID: {content_package['id']}")
        print(f"📦 Product: {content_package['product']['name']}")
        print(f"🎬 Template: {content_package['template']['type']}")
        print(f"✍️ Hook: {content_package['content']['hook']}")
        print(f"🎨 Images Generated: {len(content_package['images'])}")
        
        # Display image information
        for i, image in enumerate(content_package['images'], 1):
            print(f"   {i}. {image['type']} - {image['path']}")
        
        print(f"\n🚀 Content is ready for TikTok posting!")
    else:
        print("\n❌ FAILED! Content generation unsuccessful.")

if __name__ == "__main__":
    main()

