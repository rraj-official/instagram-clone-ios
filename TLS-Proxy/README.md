# TLS Proxy Server for Instagram Clone iOS App

This proxy server acts as an intermediary between the iOS app and external APIs, bypassing TLS certificate issues caused by corporate proxies/firewalls.

## Features

- ✅ Proxies all API calls to the mock backend
- ✅ Proxies image requests from pravatar.cc
- ✅ Handles CORS for iOS app
- ✅ Bypasses SSL certificate validation issues
- ✅ Single file implementation
- ✅ Easy to run and configure

## Setup

### 1. Install Dependencies

```bash
cd TLS-Proxy
npm install
```

### 2. Start the Server

```bash
npm start
```

Or for development with auto-reload:

```bash
npm run dev
```

The server will start on `http://localhost:3000`

## Configuration

### For iOS Simulator

Update your iOS app's `APIEndpoints.swift`:

```swift
static let baseURL = URL(string: "http://localhost:3000")!
```

### For Physical iOS Device

1. Find your Mac's IP address:
   ```bash
   ifconfig | grep "inet "
   ```
   Look for an IP like `192.168.x.x` or `10.x.x.x`

2. Update your iOS app's `APIEndpoints.swift`:
   ```swift
   static let baseURL = URL(string: "http://YOUR_MAC_IP:3000")!
   ```
   Replace `YOUR_MAC_IP` with your actual IP (e.g., `http://192.168.1.100:3000`)

3. Make sure your Mac and iOS device are on the same Wi-Fi network

## API Endpoints

The proxy server provides the following endpoints:

### API Endpoints (Proxied to Mock API)

- `GET /user/feed` - Fetch user feed posts
- `GET /user/reels` - Fetch user reels
- `POST /user/like` - Like a post or reel
- `DELETE /user/dislike` - Unlike a post or reel

### Image Proxy Endpoints

- `GET /proxy/image?url=<image_url>` - Proxy any image URL
- `GET /pravatar/:id` - Convenience endpoint for pravatar.cc images
  - Example: `/pravatar/1` → `https://i.pravatar.cc/150?u=1`

### Utility

- `GET /health` - Health check endpoint

## Updating iOS App to Use Proxy

### 1. Update API Base URL

In `Instagram/Networking/APIEndpoints.swift`:

```swift
enum APIEndpoints {
    // Change this line:
    static let baseURL = URL(string: "http://localhost:3000")!  // For simulator
    // Or for physical device:
    // static let baseURL = URL(string: "http://192.168.1.100:3000")!
    
    // ... rest of the code stays the same
}
```

### 2. Update Image URLs (Optional)

If you want to use the proxy for images, update `IGStoriesRow.swift`:

```swift
// Instead of:
imageURL: "https://i.pravatar.cc/150?u=0"

// Use:
imageURL: "http://localhost:3000/pravatar/0"  // For simulator
// Or: "http://YOUR_MAC_IP:3000/pravatar/0"  // For physical device
```

## Troubleshooting

### Server won't start

- Make sure port 3000 is not already in use
- Check if Node.js is installed: `node --version`
- Install dependencies: `npm install`

### iOS app can't connect

- **Simulator**: Make sure server is running and use `http://localhost:3000`
- **Physical Device**: 
  - Verify Mac and device are on same Wi-Fi
  - Check Mac's firewall isn't blocking port 3000
  - Use Mac's IP address, not `localhost`
  - Try disabling Mac firewall temporarily: System Settings → Firewall

### Images not loading

- Make sure you've updated image URLs to use the proxy endpoints
- Check server logs for image proxy errors
- Verify the original image URLs are accessible from your Mac

## Security Note

⚠️ **This proxy disables SSL certificate verification for development purposes only!**

Do NOT use this in production. The `rejectUnauthorized: false` setting bypasses SSL validation, which is only acceptable in a development environment behind a corporate proxy.

## License

MIT
