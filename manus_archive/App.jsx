import React, { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button.jsx'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card.jsx'
import { Badge } from '@/components/ui/badge.jsx'
import { 
  Leaf, 
  Zap, 
  Heart, 
  Shield, 
  Star, 
  ArrowRight, 
  Play,
  CheckCircle,
  Users,
  Award,
  TrendingUp,
  Instagram,
  MessageCircle,
  ShoppingBag,
  Menu,
  X
} from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import vitalflowLogo from './assets/vitalflow_logo_primary.png'
import vitalflowIcon from './assets/vitalflow_icon.png'
import energyPackaging from './assets/vitalflow_packaging_energy.png'
import calmPackaging from './assets/vitalflow_packaging_calm.png'
import './App.css'

function App() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const [activeTestimonial, setActiveTestimonial] = useState(0)

  const testimonials = [
    {
      name: "Sarah M.",
      age: 28,
      text: "VitalFlow Energy completely transformed my mornings. I went from struggling to get out of bed to having sustained energy all day!",
      rating: 5,
      product: "VitalFlow Energy"
    },
    {
      name: "Mike R.",
      age: 34,
      text: "As someone who works high-stress job, VitalFlow Calm has been a game-changer for my sleep and stress levels.",
      rating: 5,
      product: "VitalFlow Calm"
    },
    {
      name: "Jessica L.",
      age: 26,
      text: "I've tried so many supplements before, but VitalFlow is the first one that actually delivered on its promises. Amazing quality!",
      rating: 5,
      product: "VitalFlow Energy"
    }
  ]

  const products = [
    {
      name: "VitalFlow Energy",
      description: "Natural energy boost with adaptogens and B-vitamins for sustained vitality without the crash.",
      price: "$39.99",
      image: energyPackaging,
      benefits: ["Sustained Energy", "Mental Clarity", "No Crash", "Natural Ingredients"],
      ingredients: ["Rhodiola Rosea", "B-Complex", "Ginseng", "Green Tea Extract"]
    },
    {
      name: "VitalFlow Calm",
      description: "Stress relief and better sleep with ashwagandha and magnesium for natural relaxation.",
      price: "$34.99",
      image: calmPackaging,
      benefits: ["Stress Relief", "Better Sleep", "Mood Support", "Natural Calm"],
      ingredients: ["Ashwagandha", "Magnesium", "L-Theanine", "Chamomile"]
    }
  ]

  useEffect(() => {
    const interval = setInterval(() => {
      setActiveTestimonial((prev) => (prev + 1) % testimonials.length)
    }, 5000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md border-b border-green-100 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-3">
              <img src={vitalflowIcon} alt="VitalFlow" className="h-10 w-10" />
              <span className="text-2xl font-bold text-green-800">VitalFlow</span>
            </div>
            
            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center space-x-8">
              <a href="#products" className="text-gray-700 hover:text-green-600 transition-colors">Products</a>
              <a href="#benefits" className="text-gray-700 hover:text-green-600 transition-colors">Benefits</a>
              <a href="#testimonials" className="text-gray-700 hover:text-green-600 transition-colors">Reviews</a>
              <a href="#about" className="text-gray-700 hover:text-green-600 transition-colors">About</a>
              <Button className="bg-green-600 hover:bg-green-700 text-white">
                <ShoppingBag className="w-4 h-4 mr-2" />
                Shop Now
              </Button>
            </div>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setIsMenuOpen(!isMenuOpen)}
              >
                {isMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
              </Button>
            </div>
          </div>
        </div>

        {/* Mobile Navigation */}
        <AnimatePresence>
          {isMenuOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: 'auto' }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden bg-white border-t border-green-100"
            >
              <div className="px-4 py-4 space-y-3">
                <a href="#products" className="block text-gray-700 hover:text-green-600">Products</a>
                <a href="#benefits" className="block text-gray-700 hover:text-green-600">Benefits</a>
                <a href="#testimonials" className="block text-gray-700 hover:text-green-600">Reviews</a>
                <a href="#about" className="block text-gray-700 hover:text-green-600">About</a>
                <Button className="w-full bg-green-600 hover:bg-green-700 text-white">
                  <ShoppingBag className="w-4 h-4 mr-2" />
                  Shop Now
                </Button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </nav>

      {/* Hero Section */}
      <section className="relative overflow-hidden py-20 lg:py-32">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <motion.div
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8 }}
            >
              <Badge className="mb-4 bg-green-100 text-green-800 hover:bg-green-200">
                <TrendingUp className="w-4 h-4 mr-1" />
                #1 Trending on TikTok Shop
              </Badge>
              <h1 className="text-4xl lg:text-6xl font-bold text-gray-900 mb-6">
                Unlock Your
                <span className="text-green-600 block">Natural Vitality</span>
              </h1>
              <p className="text-xl text-gray-600 mb-8 leading-relaxed">
                Premium wellness supplements crafted with science-backed ingredients to boost your energy, enhance focus, and support your wellness journey naturally.
              </p>
              <div className="flex flex-col sm:flex-row gap-4">
                <Button size="lg" className="bg-green-600 hover:bg-green-700 text-white px-8 py-4 text-lg">
                  <ShoppingBag className="w-5 h-5 mr-2" />
                  Shop TikTok Favorites
                  <ArrowRight className="w-5 h-5 ml-2" />
                </Button>
                <Button size="lg" variant="outline" className="border-green-600 text-green-600 hover:bg-green-50 px-8 py-4 text-lg">
                  <Play className="w-5 h-5 mr-2" />
                  Watch Reviews
                </Button>
              </div>
              <div className="flex items-center gap-6 mt-8">
                <div className="flex items-center">
                  <div className="flex -space-x-2">
                    {[1,2,3,4,5].map((i) => (
                      <div key={i} className="w-8 h-8 rounded-full bg-green-200 border-2 border-white"></div>
                    ))}
                  </div>
                  <span className="ml-3 text-sm text-gray-600">10,000+ happy customers</span>
                </div>
                <div className="flex items-center">
                  <Star className="w-5 h-5 text-yellow-400 fill-current" />
                  <span className="ml-1 text-sm font-semibold">4.9/5</span>
                  <span className="ml-1 text-sm text-gray-600">(2,847 reviews)</span>
                </div>
              </div>
            </motion.div>
            
            <motion.div
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
              className="relative"
            >
              <div className="relative z-10">
                <img 
                  src={energyPackaging} 
                  alt="VitalFlow Energy Supplement" 
                  className="w-full max-w-md mx-auto drop-shadow-2xl"
                />
              </div>
              <div className="absolute inset-0 bg-gradient-to-r from-green-400 to-blue-500 rounded-full blur-3xl opacity-20 scale-75"></div>
            </motion.div>
          </div>
        </div>
      </section>

      {/* Social Proof Section */}
      <section className="py-12 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-8">
            <h2 className="text-2xl font-bold text-gray-900 mb-4">Trending on Social Media</h2>
            <p className="text-gray-600">Join thousands sharing their VitalFlow transformation</p>
          </div>
          <div className="grid md:grid-cols-3 gap-8">
            <Card className="border-pink-200 hover:shadow-lg transition-shadow">
              <CardContent className="p-6 text-center">
                <Instagram className="w-8 h-8 text-pink-500 mx-auto mb-4" />
                <h3 className="font-semibold text-lg mb-2">Instagram</h3>
                <p className="text-gray-600 mb-4">#VitalFlowJourney</p>
                <Badge variant="secondary">15.2M views</Badge>
              </CardContent>
            </Card>
            <Card className="border-blue-200 hover:shadow-lg transition-shadow">
              <CardContent className="p-6 text-center">
                <MessageCircle className="w-8 h-8 text-blue-500 mx-auto mb-4" />
                <h3 className="font-semibold text-lg mb-2">TikTok</h3>
                <p className="text-gray-600 mb-4">#VitalFlowEnergy</p>
                <Badge variant="secondary">28.7M views</Badge>
              </CardContent>
            </Card>
            <Card className="border-green-200 hover:shadow-lg transition-shadow">
              <CardContent className="p-6 text-center">
                <Users className="w-8 h-8 text-green-500 mx-auto mb-4" />
                <h3 className="font-semibold text-lg mb-2">Community</h3>
                <p className="text-gray-600 mb-4">Active Members</p>
                <Badge variant="secondary">50K+ users</Badge>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Products Section */}
      <section id="products" className="py-20 bg-gradient-to-br from-green-50 to-blue-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Our Premium Collection
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Scientifically formulated supplements designed to support your wellness goals with natural, high-quality ingredients.
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 gap-8 lg:gap-12">
            {products.map((product, index) => (
              <motion.div
                key={product.name}
                initial={{ opacity: 0, y: 50 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.2 }}
              >
                <Card className="overflow-hidden hover:shadow-2xl transition-all duration-300 border-0 bg-white/80 backdrop-blur-sm">
                  <div className="relative">
                    <img 
                      src={product.image} 
                      alt={product.name}
                      className="w-full h-64 object-cover"
                    />
                    <Badge className="absolute top-4 left-4 bg-green-600 text-white">
                      Best Seller
                    </Badge>
                  </div>
                  <CardContent className="p-8">
                    <div className="flex justify-between items-start mb-4">
                      <h3 className="text-2xl font-bold text-gray-900">{product.name}</h3>
                      <span className="text-2xl font-bold text-green-600">{product.price}</span>
                    </div>
                    <p className="text-gray-600 mb-6">{product.description}</p>
                    
                    <div className="mb-6">
                      <h4 className="font-semibold text-gray-900 mb-3">Key Benefits:</h4>
                      <div className="grid grid-cols-2 gap-2">
                        {product.benefits.map((benefit) => (
                          <div key={benefit} className="flex items-center">
                            <CheckCircle className="w-4 h-4 text-green-500 mr-2" />
                            <span className="text-sm text-gray-700">{benefit}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                    
                    <div className="mb-6">
                      <h4 className="font-semibold text-gray-900 mb-3">Key Ingredients:</h4>
                      <div className="flex flex-wrap gap-2">
                        {product.ingredients.map((ingredient) => (
                          <Badge key={ingredient} variant="outline" className="text-xs">
                            {ingredient}
                          </Badge>
                        ))}
                      </div>
                    </div>
                    
                    <Button className="w-full bg-green-600 hover:bg-green-700 text-white py-3">
                      <ShoppingBag className="w-4 h-4 mr-2" />
                      Add to Cart
                    </Button>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section id="benefits" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Why Choose VitalFlow?
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              We're committed to providing the highest quality supplements with transparent ingredients and proven results.
            </p>
          </div>
          
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {[
              {
                icon: Leaf,
                title: "100% Natural",
                description: "Pure, natural ingredients sourced from trusted suppliers worldwide."
              },
              {
                icon: Shield,
                title: "Third-Party Tested",
                description: "Every batch is tested for purity, potency, and safety by independent labs."
              },
              {
                icon: Award,
                title: "Science-Backed",
                description: "Formulated based on the latest nutritional science and research."
              },
              {
                icon: Heart,
                title: "Made with Love",
                description: "Crafted with care to support your wellness journey every step of the way."
              }
            ].map((benefit, index) => (
              <motion.div
                key={benefit.title}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                className="text-center"
              >
                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <benefit.icon className="w-8 h-8 text-green-600" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-3">{benefit.title}</h3>
                <p className="text-gray-600">{benefit.description}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" className="py-20 bg-gradient-to-br from-green-50 to-blue-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 mb-4">
              Real Results from Real People
            </h2>
            <p className="text-xl text-gray-600 max-w-3xl mx-auto">
              Join thousands of satisfied customers who have transformed their wellness journey with VitalFlow.
            </p>
          </div>
          
          <div className="relative max-w-4xl mx-auto">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTestimonial}
                initial={{ opacity: 0, x: 50 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -50 }}
                transition={{ duration: 0.5 }}
              >
                <Card className="bg-white/80 backdrop-blur-sm border-0 shadow-xl">
                  <CardContent className="p-8 lg:p-12 text-center">
                    <div className="flex justify-center mb-4">
                      {[...Array(testimonials[activeTestimonial].rating)].map((_, i) => (
                        <Star key={i} className="w-6 h-6 text-yellow-400 fill-current" />
                      ))}
                    </div>
                    <blockquote className="text-xl lg:text-2xl text-gray-700 mb-6 italic">
                      "{testimonials[activeTestimonial].text}"
                    </blockquote>
                    <div className="flex items-center justify-center space-x-4">
                      <div className="w-12 h-12 bg-green-200 rounded-full flex items-center justify-center">
                        <span className="font-semibold text-green-800">
                          {testimonials[activeTestimonial].name.charAt(0)}
                        </span>
                      </div>
                      <div className="text-left">
                        <p className="font-semibold text-gray-900">
                          {testimonials[activeTestimonial].name}
                        </p>
                        <p className="text-sm text-gray-600">
                          {testimonials[activeTestimonial].product} Customer
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            </AnimatePresence>
            
            <div className="flex justify-center mt-8 space-x-2">
              {testimonials.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setActiveTestimonial(index)}
                  className={`w-3 h-3 rounded-full transition-colors ${
                    index === activeTestimonial ? 'bg-green-600' : 'bg-gray-300'
                  }`}
                />
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-green-600">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <h2 className="text-3xl lg:text-4xl font-bold text-white mb-4">
              Ready to Transform Your Wellness?
            </h2>
            <p className="text-xl text-green-100 mb-8 max-w-3xl mx-auto">
              Join the VitalFlow community and start your journey to natural vitality today. Free shipping on orders over $50.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Button size="lg" className="bg-white text-green-600 hover:bg-gray-100 px-8 py-4 text-lg">
                <ShoppingBag className="w-5 h-5 mr-2" />
                Shop Now - Free Shipping
              </Button>
              <Button size="lg" variant="outline" className="border-white text-white hover:bg-white hover:text-green-600 px-8 py-4 text-lg">
                Follow on TikTok
                <ArrowRight className="w-5 h-5 ml-2" />
              </Button>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid md:grid-cols-4 gap-8">
            <div>
              <div className="flex items-center space-x-3 mb-4">
                <img src={vitalflowIcon} alt="VitalFlow" className="h-8 w-8" />
                <span className="text-xl font-bold">VitalFlow</span>
              </div>
              <p className="text-gray-400 mb-4">
                Premium wellness supplements for natural vitality and optimal health.
              </p>
              <div className="flex space-x-4">
                <Instagram className="w-5 h-5 text-gray-400 hover:text-white cursor-pointer" />
                <MessageCircle className="w-5 h-5 text-gray-400 hover:text-white cursor-pointer" />
              </div>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Products</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white">VitalFlow Energy</a></li>
                <li><a href="#" className="hover:text-white">VitalFlow Calm</a></li>
                <li><a href="#" className="hover:text-white">Bundles</a></li>
                <li><a href="#" className="hover:text-white">Subscriptions</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Support</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white">Contact Us</a></li>
                <li><a href="#" className="hover:text-white">FAQ</a></li>
                <li><a href="#" className="hover:text-white">Shipping</a></li>
                <li><a href="#" className="hover:text-white">Returns</a></li>
              </ul>
            </div>
            
            <div>
              <h3 className="font-semibold mb-4">Company</h3>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white">About Us</a></li>
                <li><a href="#" className="hover:text-white">Our Story</a></li>
                <li><a href="#" className="hover:text-white">Careers</a></li>
                <li><a href="#" className="hover:text-white">Press</a></li>
              </ul>
            </div>
          </div>
          
          <div className="border-t border-gray-800 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; 2024 VitalFlow. All rights reserved. | Privacy Policy | Terms of Service</p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default App

