# 📡 POST Request Testing Guide

## ✅ Current POST Configuration

The authentication system is already configured to use **POST requests** for the login API:

### **1. AuthRepo POST Method** ✅
- Uses `_postRequest()` method
- Sends POST to `/api/v1/auth/login`
- Includes `X-api-key` header
- Properly formatted JSON body

### **2. Request Format** ✅
```json
POST /api/v1/auth/login
Headers:
{
  "X-api-key": "e542bbe1d99355815db41ec9379805d5",
  "Content-Type": "application/json",
  "ngrok-skip-browser-warning": "true"
}

Body:
{
  "phone": 1220020078,
  "password": "your_password"
}
```

## 🧪 Testing POST Requests

### **Option 1: Use the App**
1. Enter phone: `1220020078`
2. Enter your password
3. Tap login button
4. Check debug console for POST request details

### **Option 2: Manual cURL Test**
```bash
curl -X POST https://c8ee04b37e9b.ngrok-free.app/api/v1/auth/login \
  -H "X-api-key: e542bbe1d99355815db41ec9379805d5" \
  -H "Content-Type: application/json" \
  -H "ngrok-skip-browser-warning: true" \
  -d '{"phone": 1220020078, "password": "your_password"}'
```

### **Option 3: Postman Test**
1. Method: **POST**
2. URL: `https://c8ee04b37e9b.ngrok-free.app/api/v1/auth/login`
3. Headers:
   - `X-api-key`: `e542bbe1d99355815db41ec9379805d5`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
   ```json
   {
     "phone": 1220020078,
     "password": "your_password"
   }
   ```

### **Option 4: Use Built-in Tester**
Add this to your `main.dart` temporarily:
```dart
import 'package:your_app/core/utils/post_request_tester.dart';

void main() {
  // Test POST with dummy data
  PostRequestTester.testPost();
  
  // Test POST with real credentials
  PostRequestTester.testWithRealCredentials(
    phone: 1220020078,
    password: 'your_real_password'
  );
  
  runApp(MyApp());
}
```

## 🔍 Debug Output

When you run the app, you'll see detailed POST request logs:

```
🟡 Making POST request:
   Endpoint: /api/v1/auth/login
   Full URL: https://c8ee04b37e9b.ngrok-free.app/api/v1/auth/login
   Headers: {X-api-key: e542bbe1d99355815db41ec9379805d5, Content-Type: application/json}
   Request Data: {phone: 1220020078, password: [your_password]}

🟡 TokenInterceptor - Request:
   Method: POST
   URL: https://c8ee04b37e9b.ngrok-free.app/api/v1/auth/login
```

## ✅ Expected Responses

### **Success (200)**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "_id": "user_id",
      "name": "User Name",
      "phone": 1220020078,
      ...
    },
    "accessToken": "jwt_token",
    "refreshToken": "refresh_token"
  }
}
```

### **Auth Error (400/401)**
```json
{
  "status": "error",
  "message": "Invalid credentials"
}
```

## 🚀 The POST System is Ready!

- ✅ **POST Method**: Correctly configured
- ✅ **Headers**: X-api-key included
- ✅ **Body**: JSON formatted with phone/password
- ✅ **Error Handling**: Comprehensive logging
- ✅ **Token Management**: Automatic save on success

Just make sure your backend server is running and accepting POST requests at `/api/v1/auth/login`! 🎯