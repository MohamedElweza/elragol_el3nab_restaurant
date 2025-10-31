#!/usr/bin/env python3
"""
Clean delivery areas script with API key authentication
"""

import json
import time
import urllib.request
import urllib.error
from typing import Dict, Optional

# Configuration
BASE_URL = "https://c8ee04b37e9b.ngrok-free.app"
CREATE_ENDPOINT = f"{BASE_URL}/api/v1/admin/deliveryAreas"
LIST_ENDPOINT = f"{BASE_URL}/api/v1/admin/deliveryAreas"
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTAxNDg4OGU4M2UxMzg2MDExOTc4ZTUiLCJpYXQiOjE3NjE2OTI3NTR9.YaozXiuzOlCUP3TV1dguGcdcyb21HF3qks7bWZRIgxg"
API_KEY = "ca36503d5358b81d9c3d0242738362f0"

# Delivery areas to add
DELIVERY_AREAS = [
    ("سمنود", 20),
    ("جراح", 40),
    ("الناصريه", 35),
    ("ابوصير", 50),
    ("بنا ابو صير", 75),
    ("ميت حبيب", 85),
    ("ميت بدر", 95),
    ("العجزيه", 120),
    ("المحله", 75),
    ("ابو علي", 50),
    ("الراهبين", 40),
    ("منيا", 25),
    ("اجا", 55),
    ("الديرس", 55),
    ("نوسه البحر", 90),
    ("نوسه الغيط", 90),
    ("كفر التعابنيه", 40),
    ("محله خلف", 40),
    ("الناوية", 50),
    ("عساس", 60),
    ("بهبيت", 75),
    ("طليمه", 75),
    ("كفر حسان", 70),
    ("كفر العرب", 130),
    ("الجمزتين", 25),
    ("منيا سمنود", 25),
    ("سنبخت", 55)
]

def make_request(url: str, data: Optional[Dict] = None) -> Dict:
    """Make HTTP request with API key authentication"""
    try:
        if data:
            json_data = json.dumps(data).encode('utf-8')
            req = urllib.request.Request(url, data=json_data)
            req.add_header('Content-Type', 'application/json')
        else:
            req = urllib.request.Request(url)
        
        # Add both JWT token and API key as required by the API
        req.add_header('Authorization', f'Bearer {JWT_TOKEN}')
        req.add_header('x-api-key', API_KEY)
        
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
            
    except urllib.error.HTTPError as e:
        error_msg = f"HTTP {e.code}: {e.reason}"
        try:
            error_detail = e.read().decode('utf-8')
            error_msg += f" - {error_detail}"
        except:
            pass
        return {"error": error_msg}
    except Exception as e:
        return {"error": str(e)}

def add_delivery_area(name: str, fee: int) -> Dict:
    """Add a delivery area"""
    data = {
        "name": name,
        "deliveryFee": fee,
        "estimatedTime": 30
    }
    return make_request(CREATE_ENDPOINT, data)

def get_delivery_areas() -> Dict:
    """Get all delivery areas"""
    return make_request(LIST_ENDPOINT)

def main():
    print("🚚 Delivery Areas Manager")
    print("=" * 40)
    print(f"JWT Token: {JWT_TOKEN[:20]}...{JWT_TOKEN[-10:]}")
    print(f"API Key: {API_KEY[:8]}...{API_KEY[-4:]}")
    print(f"Endpoint: {BASE_URL}")
    print()
    
    success_count = 0
    fail_count = 0
    
    # Add each area
    for i, (name, fee) in enumerate(DELIVERY_AREAS, 1):
        print(f"[{i:2d}/{len(DELIVERY_AREAS)}] Adding: {name} (Fee: {fee} EGP)")
        
        result = add_delivery_area(name, fee)
        
        if "error" in result:
            print(f"     ❌ FAILED: {result['error']}")
            fail_count += 1
        else:
            print(f"     ✅ SUCCESS")
            success_count += 1
        
        time.sleep(0.3)  # Small delay
    
    # Summary
    print("\n" + "=" * 40)
    print(f"✅ Added: {success_count}")
    print(f"❌ Failed: {fail_count}")
    
    # Verify
    print("\n🔍 Verifying delivery areas...")
    result = get_delivery_areas()
    
    if "error" in result:
        print(f"❌ Could not verify: {result['error']}")
    elif "data" in result and "deliveryAreas" in result["data"]:
        areas = result["data"]["deliveryAreas"]
        print(f"✅ Total areas in system: {len(areas)}")
        
        # Show all areas
        print("\n📍 All delivery areas:")
        for area in sorted(areas, key=lambda x: x.get("name", "")):
            name = area.get("name", "Unknown")
            fee = area.get("deliveryFee", 0)
            active = "✅" if area.get("isActive", True) else "❌"
            print(f"  {active} {name}: {fee} EGP")
    else:
        print("❌ Unexpected response format")
    
    print(f"\n🎉 Done! Press Enter to exit...")
    input()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⏹️ Cancelled by user")
    except Exception as e:
        print(f"\n\n💥 Error: {e}")
        input("Press Enter to exit...")