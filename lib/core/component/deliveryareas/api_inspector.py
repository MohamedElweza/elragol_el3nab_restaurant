#!/usr/bin/env python3
"""
Detailed API response inspector to debug the endpoint issue
"""

import urllib.request
import urllib.error
import json

BASE_URL = "https://c8ee04b37e9b.ngrok-free.app"
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTAxNDg4OGU4M2UxMzg2MDExOTc4ZTUiLCJpYXQiOjE3NjE2OTI3NTR9.YaozXiuzOlCUP3TV1dguGcdcyb21HF3qks7bWZRIgxg"
API_KEY = "ca36503d5358b81d9c3d0242738362f0"

def inspect_response(url, headers=None, method="GET", data=None):
    """Inspect what the API endpoint actually returns"""
    print(f"\n🔍 Testing: {method} {url}")
    if headers:
        print("📤 Headers:")
        for key, value in headers.items():
            if 'token' in key.lower() or 'key' in key.lower():
                print(f"   {key}: {value[:20]}...{value[-10:]}")
            else:
                print(f"   {key}: {value}")
    
    try:
        if data:
            json_data = json.dumps(data).encode('utf-8')
            req = urllib.request.Request(url, data=json_data)
        else:
            req = urllib.request.Request(url)
        
        # Add headers
        if headers:
            for key, value in headers.items():
                req.add_header(key, value)
        
        with urllib.request.urlopen(req, timeout=10) as response:
            # Print response info
            print(f"📥 Response: {response.getcode()} {response.reason}")
            print(f"📋 Response Headers:")
            for header, value in response.headers.items():
                print(f"   {header}: {value}")
            
            # Read response body
            response_data = response.read()
            response_text = response_data.decode('utf-8')
            
            print(f"\n📄 Response Body ({len(response_data)} bytes):")
            print("-" * 50)
            print(response_text[:1000])  # First 1000 chars
            if len(response_text) > 1000:
                print(f"\n... (truncated, total length: {len(response_text)} chars)")
            print("-" * 50)
            
            # Try to parse as JSON
            try:
                json_data = json.loads(response_text)
                print("✅ Valid JSON response!")
                print(f"📊 JSON structure: {json.dumps(json_data, indent=2, ensure_ascii=False)}")
            except json.JSONDecodeError as e:
                print(f"❌ Invalid JSON: {e}")
                if response_text.strip().startswith('<'):
                    print("🌐 Looks like HTML response (probably an error page)")
                elif not response_text.strip():
                    print("📭 Empty response")
                else:
                    print("📝 Plain text or other format")
            
            return True
            
    except urllib.error.HTTPError as e:
        print(f"❌ HTTP Error: {e.code} {e.reason}")
        try:
            error_body = e.read().decode('utf-8')
            print(f"Error body: {error_body}")
        except:
            pass
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("🔍 Detailed API Response Inspector")
    print("=" * 60)
    
    # Test different endpoints and methods
    tests = [
        # Test base URL
        {
            "url": BASE_URL,
            "headers": {},
            "description": "Base URL (no auth)"
        },
        
        # Test API base
        {
            "url": f"{BASE_URL}/api",
            "headers": {},
            "description": "API base endpoint"
        },
        
        # Test delivery areas endpoint without auth
        {
            "url": f"{BASE_URL}/api/v1/admin/deliveryAreas",
            "headers": {},
            "description": "Delivery areas endpoint (no auth)"
        },
        
        # Test with just JWT token
        {
            "url": f"{BASE_URL}/api/v1/admin/deliveryAreas",
            "headers": {
                "Authorization": f"Bearer {JWT_TOKEN}",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            "description": "Delivery areas endpoint (JWT only)"
        },
        
        # Test with just API key
        {
            "url": f"{BASE_URL}/api/v1/admin/deliveryAreas",
            "headers": {
                "x-api-key": API_KEY,
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            "description": "Delivery areas endpoint (API key only)"
        },
        
        # Test with both auth methods
        {
            "url": f"{BASE_URL}/api/v1/admin/deliveryAreas",
            "headers": {
                "Authorization": f"Bearer {JWT_TOKEN}",
                "x-api-key": API_KEY,
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            "description": "Delivery areas endpoint (full auth)"
        },
        
        # Test POST to create area
        {
            "url": f"{BASE_URL}/api/v1/admin/deliveryAreas",
            "headers": {
                "Authorization": f"Bearer {JWT_TOKEN}",
                "x-api-key": API_KEY,
                "Content-Type": "application/json",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            },
            "method": "POST",
            "data": {
                "name": "Test Area",
                "deliveryFee": 15,
                "estimatedTime": 30
            },
            "description": "POST test delivery area"
        }
    ]
    
    for i, test in enumerate(tests, 1):
        print(f"\n{i}️⃣ {test['description']}")
        inspect_response(
            test["url"], 
            test.get("headers", {}),
            test.get("method", "GET"),
            test.get("data")
        )
        
        if i < len(tests):
            input("\nPress Enter to continue to next test...")
    
    print(f"\n🎉 Inspection complete!")
    input("Press Enter to exit...")

if __name__ == "__main__":
    main()