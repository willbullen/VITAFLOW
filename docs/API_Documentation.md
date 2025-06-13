# VitalFlow Automation API Documentation

## Overview

The VitalFlow Automation API provides comprehensive endpoints for managing your automated TikTok Shop business. This RESTful API enables you to control content generation, monitor system performance, manage posting schedules, and access detailed analytics.

**Base URL**: `http://localhost:5000/api` (development) | `https://api.vitalflow.com/api` (production)

**API Version**: v1.0

**Authentication**: Bearer Token (JWT)

## Authentication

All API requests require authentication using a Bearer token in the Authorization header.

```http
Authorization: Bearer <your_jwt_token>
```

### Obtaining an Access Token

```http
POST /auth/login
Content-Type: application/json

{
  "username": "your_username",
  "password": "your_password"
}
```

**Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

## Content Generation API

### Generate New Content

Creates new TikTok content based on specified parameters and templates.

```http
POST /automation/generate-content
Content-Type: application/json
Authorization: Bearer <token>

{
  "product_category": "energy",
  "content_type": "transformation",
  "target_audience": "fitness_enthusiasts",
  "trending_hashtags": ["#energyboost", "#morningroutine"],
  "custom_prompt": "Focus on pre-workout benefits"
}
```

**Response:**
```json
{
  "success": true,
  "content_id": "content_20241213_001",
  "data": {
    "script": "🌅 My morning energy transformation...",
    "hooks": [
      "POV: You finally found the energy supplement that works",
      "This changed my entire morning routine"
    ],
    "cta": "Link in bio for 20% off your first order! #VitalFlow",
    "hashtags": ["#energyboost", "#morningroutine", "#vitalflow"],
    "estimated_engagement": 8.5,
    "content_type": "transformation",
    "duration_seconds": 30
  },
  "images": {
    "thumbnail": "/generated/thumbnail_energy_20241213_001.png",
    "product_shot": "/generated/product_energy_20241213_001.png",
    "transformation": "/generated/transformation_energy_20241213_001.png"
  },
  "metadata": {
    "created_at": "2024-12-13T10:30:00Z",
    "template_used": "transformation_v2",
    "ai_confidence": 0.92
  }
}
```

### Get Content Queue

Retrieves the current content queue with all pending and scheduled posts.

```http
GET /automation/content-queue
Authorization: Bearer <token>
```

**Query Parameters:**
- `status` (optional): Filter by status (`pending`, `scheduled`, `posted`, `failed`)
- `limit` (optional): Number of items to return (default: 50)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "total_count": 25,
  "data": [
    {
      "content_id": "content_20241213_001",
      "status": "scheduled",
      "scheduled_time": "2024-12-13T18:00:00Z",
      "content_type": "transformation",
      "product_category": "energy",
      "estimated_engagement": 8.5,
      "created_at": "2024-12-13T10:30:00Z"
    }
  ],
  "pagination": {
    "limit": 50,
    "offset": 0,
    "has_more": false
  }
}
```

### Update Content

Modifies existing content before posting.

```http
PUT /automation/content/{content_id}
Content-Type: application/json
Authorization: Bearer <token>

{
  "script": "Updated script content...",
  "hashtags": ["#updated", "#hashtags"],
  "scheduled_time": "2024-12-13T20:00:00Z"
}
```

### Delete Content

Removes content from the queue.

```http
DELETE /automation/content/{content_id}
Authorization: Bearer <token>
```

## Product Management API

### Get Products

Retrieves available products from Supliful integration.

```http
GET /automation/products
Authorization: Bearer <token>
```

**Query Parameters:**
- `category` (optional): Filter by category (`energy`, `sleep`, `focus`, `immunity`)
- `active_only` (optional): Return only active products (default: true)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "product_id": "vf_energy_001",
      "name": "VitalFlow Energy Boost",
      "category": "energy",
      "description": "Natural energy supplement with B-vitamins and adaptogens",
      "price": 29.99,
      "cost": 12.50,
      "margin": 58.3,
      "stock_status": "in_stock",
      "supliful_id": "SUP_12345",
      "images": [
        "https://cdn.supliful.com/products/energy_001_main.jpg"
      ],
      "benefits": [
        "Sustained energy without crash",
        "Enhanced mental clarity",
        "Natural ingredients"
      ],
      "ingredients": [
        "B-Complex Vitamins",
        "Rhodiola Rosea",
        "Ginseng Extract"
      ]
    }
  ]
}
```

### Update Product

Updates product information and pricing.

```http
PUT /automation/products/{product_id}
Content-Type: application/json
Authorization: Bearer <token>

{
  "price": 34.99,
  "description": "Updated product description",
  "active": true
}
```

## TikTok Automation API

### Post Content Now

Immediately posts content to TikTok.

```http
POST /tiktok/post-now
Content-Type: application/json
Authorization: Bearer <token>

{
  "content_id": "content_20241213_001",
  "caption_override": "Custom caption for this post",
  "hashtags_override": ["#custom", "#hashtags"]
}
```

**Response:**
```json
{
  "success": true,
  "tiktok_post_id": "7312345678901234567",
  "post_url": "https://www.tiktok.com/@vitalflow/video/7312345678901234567",
  "posted_at": "2024-12-13T15:30:00Z",
  "status": "published"
}
```

### Get Posting Schedule

Retrieves the current posting schedule.

```http
GET /tiktok/schedule
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "schedule": {
    "timezone": "UTC",
    "posting_times": ["08:00", "12:00", "18:00"],
    "max_posts_per_day": 3,
    "active_days": ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
  },
  "next_scheduled_posts": [
    {
      "content_id": "content_20241213_002",
      "scheduled_time": "2024-12-13T18:00:00Z",
      "content_type": "educational"
    }
  ]
}
```

### Update Posting Schedule

Modifies the automated posting schedule.

```http
POST /tiktok/schedule
Content-Type: application/json
Authorization: Bearer <token>

{
  "posting_times": ["09:00", "13:00", "19:00"],
  "max_posts_per_day": 4,
  "timezone": "America/New_York",
  "active_days": ["monday", "tuesday", "wednesday", "thursday", "friday"]
}
```

### Get TikTok Analytics

Retrieves posting performance and engagement metrics.

```http
GET /tiktok/analytics
Authorization: Bearer <token>
```

**Query Parameters:**
- `start_date` (optional): Start date for analytics (YYYY-MM-DD)
- `end_date` (optional): End date for analytics (YYYY-MM-DD)
- `metric` (optional): Specific metric (`views`, `likes`, `shares`, `comments`, `engagement_rate`)

**Response:**
```json
{
  "success": true,
  "period": {
    "start_date": "2024-12-01",
    "end_date": "2024-12-13"
  },
  "summary": {
    "total_posts": 39,
    "total_views": 125000,
    "total_likes": 8750,
    "total_shares": 1200,
    "total_comments": 450,
    "average_engagement_rate": 8.32,
    "follower_growth": 1250
  },
  "top_performing_posts": [
    {
      "tiktok_post_id": "7312345678901234567",
      "content_type": "transformation",
      "views": 15000,
      "likes": 1200,
      "engagement_rate": 12.5,
      "posted_at": "2024-12-10T18:00:00Z"
    }
  ],
  "daily_metrics": [
    {
      "date": "2024-12-13",
      "posts": 3,
      "views": 8500,
      "likes": 650,
      "engagement_rate": 9.1
    }
  ]
}
```

## Analytics API

### Get Dashboard Data

Retrieves comprehensive dashboard metrics.

```http
GET /analytics/dashboard
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "total_revenue": 15750.00,
      "total_orders": 315,
      "conversion_rate": 2.52,
      "average_order_value": 50.00,
      "profit_margin": 62.5
    },
    "content_performance": {
      "total_posts": 39,
      "average_engagement": 8.32,
      "top_content_type": "transformation",
      "content_success_rate": 94.9
    },
    "system_health": {
      "uptime_percentage": 99.8,
      "api_response_time": 0.045,
      "error_rate": 0.2,
      "last_health_check": "2024-12-13T15:45:00Z"
    },
    "growth_metrics": {
      "follower_growth_rate": 15.2,
      "revenue_growth_rate": 28.5,
      "engagement_growth_rate": 12.8
    }
  }
}
```

### Get Performance Insights

Retrieves AI-powered insights and recommendations.

```http
GET /analytics/insights
Authorization: Bearer <token>
```

**Query Parameters:**
- `type` (optional): Insight type (`content`, `posting`, `product`, `audience`)
- `priority` (optional): Priority level (`high`, `medium`, `low`)

**Response:**
```json
{
  "success": true,
  "insights": [
    {
      "id": "insight_001",
      "type": "content",
      "priority": "high",
      "title": "Transformation content performs 40% better",
      "description": "Your transformation-style content consistently outperforms other formats with 40% higher engagement rates.",
      "recommendation": "Increase transformation content from 30% to 50% of your posting schedule",
      "potential_impact": "Estimated 25% increase in overall engagement",
      "confidence": 0.89,
      "data_points": 156,
      "created_at": "2024-12-13T14:30:00Z"
    }
  ],
  "summary": {
    "total_insights": 8,
    "high_priority": 2,
    "medium_priority": 4,
    "low_priority": 2
  }
}
```

### Export Analytics Data

Exports analytics data in various formats.

```http
GET /analytics/export
Authorization: Bearer <token>
```

**Query Parameters:**
- `format`: Export format (`json`, `csv`, `xlsx`)
- `start_date`: Start date (YYYY-MM-DD)
- `end_date`: End date (YYYY-MM-DD)
- `metrics`: Comma-separated list of metrics to include

**Response:**
Returns file download with requested format and data.

## System Management API

### Get System Status

Retrieves overall system health and status.

```http
GET /system/status
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "status": "healthy",
  "services": {
    "api": {
      "status": "healthy",
      "uptime": "5d 12h 30m",
      "response_time": 0.045
    },
    "automation": {
      "status": "healthy",
      "last_post": "2024-12-13T12:00:00Z",
      "queue_size": 8
    },
    "analytics": {
      "status": "healthy",
      "last_update": "2024-12-13T15:30:00Z"
    }
  },
  "system_resources": {
    "cpu_usage": 25.5,
    "memory_usage": 68.2,
    "disk_usage": 45.8
  }
}
```

### Update System Configuration

Updates system-wide configuration settings.

```http
POST /system/config
Content-Type: application/json
Authorization: Bearer <token>

{
  "content_generation": {
    "ai_creativity_level": 0.8,
    "content_safety_filter": true,
    "auto_hashtag_generation": true
  },
  "posting": {
    "auto_posting_enabled": true,
    "content_approval_required": false,
    "duplicate_detection": true
  },
  "analytics": {
    "data_retention_days": 365,
    "real_time_updates": true,
    "export_enabled": true
  }
}
```

## Error Handling

The API uses standard HTTP status codes and returns detailed error information.

### Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": {
      "field": "content_type",
      "issue": "Must be one of: transformation, educational, grwm, trending, mythbusting"
    },
    "request_id": "req_20241213_15301234"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `AUTHENTICATION_REQUIRED` | 401 | Missing or invalid authentication token |
| `AUTHORIZATION_FAILED` | 403 | Insufficient permissions for requested action |
| `VALIDATION_ERROR` | 400 | Invalid request parameters or format |
| `RESOURCE_NOT_FOUND` | 404 | Requested resource does not exist |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests in time window |
| `INTERNAL_ERROR` | 500 | Unexpected server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

## Rate Limiting

API requests are rate limited to ensure system stability:

- **Standard endpoints**: 100 requests per minute
- **Content generation**: 10 requests per minute
- **Analytics exports**: 5 requests per hour

Rate limit headers are included in all responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1702478400
```

## Webhooks

The system supports webhooks for real-time notifications of important events.

### Webhook Events

- `content.generated` - New content created
- `post.published` - Content posted to TikTok
- `post.failed` - Posting attempt failed
- `analytics.milestone` - Performance milestone reached
- `system.alert` - System health alert

### Webhook Configuration

```http
POST /webhooks
Content-Type: application/json
Authorization: Bearer <token>

{
  "url": "https://your-app.com/webhooks/vitalflow",
  "events": ["content.generated", "post.published"],
  "secret": "your_webhook_secret"
}
```

### Webhook Payload Example

```json
{
  "event": "post.published",
  "timestamp": "2024-12-13T18:00:00Z",
  "data": {
    "content_id": "content_20241213_001",
    "tiktok_post_id": "7312345678901234567",
    "post_url": "https://www.tiktok.com/@vitalflow/video/7312345678901234567"
  },
  "signature": "sha256=abc123..."
}
```

## SDK and Libraries

Official SDKs are available for popular programming languages:

- **Python**: `pip install vitalflow-sdk`
- **JavaScript/Node.js**: `npm install vitalflow-sdk`
- **PHP**: `composer require vitalflow/sdk`

### Python SDK Example

```python
from vitalflow import VitalFlowClient

client = VitalFlowClient(api_key='your_api_key')

# Generate new content
content = client.content.generate(
    product_category='energy',
    content_type='transformation'
)

# Post to TikTok
result = client.tiktok.post_now(content.id)

# Get analytics
analytics = client.analytics.get_dashboard()
```

## Testing

A comprehensive test suite is available for API validation:

### Test Environment

**Base URL**: `https://api-staging.vitalflow.com/api`

Test credentials are provided in the developer portal.

### Postman Collection

Import the official Postman collection for easy API testing:

```bash
curl -o vitalflow-api.postman_collection.json \
  https://api.vitalflow.com/docs/postman-collection
```

## Support

For API support and questions:

- **Documentation**: https://docs.vitalflow.com
- **Support Email**: api-support@vitalflow.com
- **Developer Portal**: https://developers.vitalflow.com
- **Status Page**: https://status.vitalflow.com

