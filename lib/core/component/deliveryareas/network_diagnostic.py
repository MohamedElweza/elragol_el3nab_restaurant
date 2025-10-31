#!/usr/bin/env python3
"""
Network diagnostic script to test API connectivity
"""

import urllib.request
import urllib.error
import socket
import json

BASE_URL = "https://c8ee04b37e9b.ngrok-free.app"
JWT_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OTAxNDg4OGU4M2UxMzg2MDExOTc4ZTUiLCJpYXQiOjE3NjE2OTI3NTR9.YaozXiuzOlCUP3TV1dguGcdcyb21HF3qks7bWZRIgxg"
API_KEY = "ca36503d5358b81d9c3d0242738362f0"

def test_dns_resolution():
    """Test if we can resolve the ngrok domain"""
    try:
        hostname = "c8ee04b37e9b.ngrok-free.app"
        ip = socket.gethostbyname(hostname)
        print(f"✅ DNS Resolution: {hostname} -> {ip}")
        return True
    except socket.gaierror as e:
        print(f"❌ DNS Resolution Failed: {e}")
        return False

def test_basic_connectivity():
    """Test basic HTTP connectivity"""
    try:
        req = urllib.request.Request(BASE_URL)
        req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        with urllib.request.urlopen(req, timeout=10) as response:
            print(f"✅ Basic HTTP: {response.getcode()} {response.reason}")
            return True
    except urllib.error.URLError as e:
        print(f"❌ Basic HTTP Failed: {e}")
        return False
    except Exception as e:
        print(f"❌ Basic HTTP Error: {e}")
        return False

def test_api_endpoint():
    """Test the specific API endpoint"""
    try:
        url = f"{BASE_URL}/api/v1/admin/deliveryAreas"
        req = urllib.request.Request(url)
        req.add_header('Authorization', f'Bearer {JWT_TOKEN}')
        req.add_header('x-api-key', API_KEY)
        req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        
        with urllib.request.urlopen(req, timeout=10) as response:
            result = json.loads(response.read().decode('utf-8'))
            print(f"✅ API Endpoint: {response.getcode()} {response.reason}")
            print(f"   Response: {json.dumps(result, indent=2, ensure_ascii=False)}")
            return True
    except urllib.error.HTTPError as e:
        error_detail = ""
        try:
            error_detail = e.read().decode('utf-8')
        except:
            pass
        print(f"❌ API Endpoint HTTP Error: {e.code} {e.reason}")
        print(f"   Details: {error_detail}")
        return False
    except urllib.error.URLError as e:
        print(f"❌ API Endpoint URL Error: {e}")
        return False
    except Exception as e:
        print(f"❌ API Endpoint Error: {e}")
        return False

def test_alternative_endpoints():
    """Test some alternative endpoints to check if ngrok is working"""
    alternatives = [
        "https://httpbin.org/get",
        "https://jsonplaceholder.typicode.com/posts/1",
        "https://google.com"
    ]
    
    print("\n🌐 Testing alternative endpoints:")
    for url in alternatives:
        try:
            req = urllib.request.Request(url)
            req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
            with urllib.request.urlopen(req, timeout=5) as response:
                print(f"   ✅ {url}: {response.getcode()}")
        except Exception as e:
            print(f"   ❌ {url}: {e}")

def main():
    print("🔍 Network Diagnostic Tool")
    print("=" * 50)
    print(f"Target: {BASE_URL}")
    print()
    
    print("1️⃣ Testing DNS Resolution...")
    dns_ok = test_dns_resolution()
    print()
    
    if dns_ok:
        print("2️⃣ Testing Basic HTTP Connectivity...")
        http_ok = test_basic_connectivity()
        print()
        
        if http_ok:
            print("3️⃣ Testing API Endpoint with Authentication...")
            test_api_endpoint()
            print()
    
    print("4️⃣ Testing Internet Connectivity...")
    test_alternative_endpoints()
    
    print("\n" + "=" * 50)
    print("💡 Troubleshooting Tips:")
    print("- If DNS fails: Check your internet connection")
    print("- If HTTP fails: The ngrok tunnel might be expired")
    print("- If API fails: Check your authentication credentials")
    print("- If alternatives fail: Check your firewall/proxy settings")
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    main()