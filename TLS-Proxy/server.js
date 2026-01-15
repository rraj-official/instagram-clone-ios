/**
 * TLS Proxy Server for Instagram Clone iOS App
 * 
 * This proxy server acts as an intermediary between the iOS app and external APIs,
 * bypassing TLS certificate issues caused by corporate proxies/firewalls.
 * 
 * Features:
 * - Downloads and caches images locally
 * - Replaces image URLs in API responses with local proxy URLs
 * - Serves cached images from local storage
 * 
 * Usage:
 *   1. Install dependencies: npm install express axios fs-extra
 *   2. Run server: node server.js
 *   3. Update iOS app baseURL to: http://localhost:3000 (or your machine's IP)
 */

const express = require('express');
const axios = require('axios');
const https = require('https');
const fs = require('fs-extra');
const path = require('path');
const crypto = require('crypto');
const app = express();
const PORT = 3000;

// Enable CORS for iOS app
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    if (req.method === 'OPTIONS') {
        return res.sendStatus(200);
    }
    next();
});

// Parse JSON bodies
app.use(express.json());

// Configuration
const CONFIG = {
    // Mock API base URL
    MOCK_API_BASE: 'https://dfbf9976-22e3-4bb2-ae02-286dfd0d7c42.mock.pstmn.io',
    
    // Image proxy base URL
    PRAVATAR_BASE: 'https://i.pravatar.cc',
    
    // Request timeout (ms)
    TIMEOUT: 30000,
    
    // Cache directory
    CACHE_DIR: path.join(__dirname, 'cache'),
    IMAGES_DIR: path.join(__dirname, 'cache', 'images'),
};

// Ensure cache directories exist
fs.ensureDirSync(CONFIG.IMAGES_DIR);

// Helper function to create a hash of a URL for caching
function hashURL(url) {
    return crypto.createHash('md5').update(url).digest('hex');
}

// Helper function to get file extension from URL or content type
function getFileExtension(url, contentType) {
    // Try to get extension from URL
    const urlMatch = url.match(/\.(jpg|jpeg|png|gif|webp|svg)(\?|$)/i);
    if (urlMatch) {
        return urlMatch[1].toLowerCase();
    }
    
    // Try to get extension from content type
    if (contentType) {
        const typeMap = {
            'image/jpeg': 'jpg',
            'image/jpg': 'jpg',
            'image/png': 'png',
            'image/gif': 'gif',
            'image/webp': 'webp',
            'image/svg+xml': 'svg',
        };
        return typeMap[contentType] || 'jpg';
    }
    
    return 'jpg'; // Default
}

// Get proxy base URL from request (for absolute URLs)
function getProxyBaseURL(req) {
    const protocol = req.protocol || 'http';
    const host = req.get('host') || `localhost:${PORT}`;
    return `${protocol}://${host}`;
}

// Download and cache an image
async function downloadAndCacheImage(imageUrl, req) {
    const urlHash = hashURL(imageUrl);
    const ext = getFileExtension(imageUrl);
    const cachePath = path.join(CONFIG.IMAGES_DIR, `${urlHash}.${ext}`);
    const proxyBase = req ? getProxyBaseURL(req) : `http://localhost:${PORT}`;
    
    // Check if already cached
    if (await fs.pathExists(cachePath)) {
        console.log(`📦 [CACHE HIT] ${imageUrl.substring(0, 50)}...`);
        return `${proxyBase}/cache/image/${urlHash}.${ext}`;
    }
    
    // Download image
    try {
        console.log(`⬇️  [DOWNLOAD] ${imageUrl.substring(0, 50)}...`);
        const response = await axios({
            url: imageUrl,
            method: 'GET',
            responseType: 'arraybuffer',
            timeout: CONFIG.TIMEOUT,
            httpsAgent: new https.Agent({
                rejectUnauthorized: false
            }),
        });
        
        // Save to cache
        await fs.writeFile(cachePath, response.data);
        console.log(`✅ [CACHED] ${imageUrl.substring(0, 50)}... -> ${urlHash}.${ext}`);
        
        return `${proxyBase}/cache/image/${urlHash}.${ext}`;
    } catch (error) {
        console.error(`❌ [DOWNLOAD FAILED] ${imageUrl}:`, error.message);
        // Return original URL if download fails (fallback)
        return imageUrl;
    }
}

// Process API response to replace image URLs with proxy URLs
async function processAPIResponse(data, req) {
    if (!data) return data;
    
    // Handle feed response
    if (data.feed && Array.isArray(data.feed)) {
        for (const post of data.feed) {
            if (post.user_image) {
                post.user_image = await downloadAndCacheImage(post.user_image, req);
            }
            if (post.post_image) {
                post.post_image = await downloadAndCacheImage(post.post_image, req);
            }
        }
    }
    
    // Handle reels response
    if (data.reels && Array.isArray(data.reels)) {
        for (const reel of data.reels) {
            if (reel.user_image) {
                reel.user_image = await downloadAndCacheImage(reel.user_image, req);
            }
            if (reel.reel_video) {
                // Videos can also be proxied, but for now we'll handle images
                // reel.reel_video = await downloadAndCacheVideo(reel.reel_video, req);
            }
        }
    }
    
    return data;
}

// Helper function to make proxied requests with error handling
async function proxyRequest(url, options = {}) {
    try {
        const response = await axios({
            url,
            method: options.method || 'GET',
            data: options.body,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers,
            },
            timeout: CONFIG.TIMEOUT,
            // Disable SSL verification if needed (for corporate proxies)
            // WARNING: Only use in development!
            httpsAgent: new https.Agent({
                rejectUnauthorized: false
            }),
            validateStatus: () => true, // Don't throw on any status
        });
        
        return {
            status: response.status,
            data: response.data,
            headers: response.headers,
        };
    } catch (error) {
        console.error(`Proxy request failed for ${url}:`, error.message);
        throw error;
    }
}

// ============================================================================
// API ENDPOINTS
// ============================================================================

/**
 * GET /user/feed
 * Fetches the user's feed posts and replaces image URLs with cached local URLs
 */
app.get('/user/feed', async (req, res) => {
    console.log('📥 [GET] /user/feed');
    
    try {
        const url = `${CONFIG.MOCK_API_BASE}/user/feed`;
        const result = await proxyRequest(url);
        
        if (result.status === 200 && result.data) {
            // Process response to download and cache images
            const processedData = await processAPIResponse(result.data, req);
            console.log(`✅ [GET] /user/feed - Status: ${result.status} (images cached)`);
            res.status(result.status).json(processedData);
        } else {
            res.status(result.status).json(result.data);
        }
    } catch (error) {
        console.error('❌ [GET] /user/feed - Error:', error.message);
        res.status(500).json({ 
            error: 'Failed to fetch feed',
            message: error.message 
        });
    }
});

/**
 * GET /user/reels
 * Fetches the user's reels and replaces image URLs with cached local URLs
 */
app.get('/user/reels', async (req, res) => {
    console.log('📥 [GET] /user/reels');
    
    try {
        const url = `${CONFIG.MOCK_API_BASE}/user/reels`;
        const result = await proxyRequest(url);
        
        if (result.status === 200 && result.data) {
            // Process response to download and cache images
            const processedData = await processAPIResponse(result.data, req);
            console.log(`✅ [GET] /user/reels - Status: ${result.status} (images cached)`);
            res.status(result.status).json(processedData);
        } else {
            res.status(result.status).json(result.data);
        }
    } catch (error) {
        console.error('❌ [GET] /user/reels - Error:', error.message);
        res.status(500).json({ 
            error: 'Failed to fetch reels',
            message: error.message 
        });
    }
});

/**
 * POST /user/like
 * Likes a post or reel
 */
app.post('/user/like', async (req, res) => {
    console.log('📥 [POST] /user/like', req.body);
    
    try {
        const url = `${CONFIG.MOCK_API_BASE}/user/like`;
        const result = await proxyRequest(url, {
            method: 'POST',
            body: req.body,
        });
        
        console.log(`✅ [POST] /user/like - Status: ${result.status}`);
        res.status(result.status).json(result.data || { success: true });
    } catch (error) {
        console.error('❌ [POST] /user/like - Error:', error.message);
        res.status(500).json({ 
            error: 'Failed to like',
            message: error.message 
        });
    }
});

/**
 * DELETE /user/dislike
 * Unlikes a post or reel
 */
app.delete('/user/dislike', async (req, res) => {
    console.log('📥 [DELETE] /user/dislike', req.body);
    
    try {
        const url = `${CONFIG.MOCK_API_BASE}/user/dislike`;
        const result = await proxyRequest(url, {
            method: 'DELETE',
            body: req.body,
        });
        
        console.log(`✅ [DELETE] /user/dislike - Status: ${result.status}`);
        res.status(result.status).json(result.data || { success: true });
    } catch (error) {
        console.error('❌ [DELETE] /user/dislike - Error:', error.message);
        res.status(500).json({ 
            error: 'Failed to dislike',
            message: error.message 
        });
    }
});

// ============================================================================
// IMAGE CACHE ENDPOINTS
// ============================================================================

/**
 * GET /cache/image/:hash.:ext
 * Serves cached images from local storage
 */
app.get('/cache/image/:hash.:ext', async (req, res) => {
    const { hash, ext } = req.params;
    const cachePath = path.join(CONFIG.IMAGES_DIR, `${hash}.${ext}`);
    
    try {
        if (await fs.pathExists(cachePath)) {
            const imageBuffer = await fs.readFile(cachePath);
            const contentType = `image/${ext === 'jpg' ? 'jpeg' : ext}`;
            
            res.setHeader('Content-Type', contentType);
            res.setHeader('Cache-Control', 'public, max-age=31536000'); // Cache for 1 year
            res.send(imageBuffer);
        } else {
            res.status(404).json({ error: 'Image not found in cache' });
        }
    } catch (error) {
        console.error(`❌ [CACHE SERVE] Error:`, error.message);
        res.status(500).json({ error: 'Failed to serve cached image' });
    }
});

/**
 * GET /proxy/image
 * Proxies image requests and caches them
 * Usage: /proxy/image?url=https://i.pravatar.cc/150?u=1
 */
app.get('/proxy/image', async (req, res) => {
    const imageUrl = req.query.url;
    
    if (!imageUrl) {
        return res.status(400).json({ error: 'Missing url parameter' });
    }
    
    console.log(`📥 [GET] /proxy/image - ${imageUrl}`);
    
    try {
        const cachedPath = await downloadAndCacheImage(imageUrl, req);
        
        // If download succeeded, redirect to cached version
        if (cachedPath.includes('/cache/image/')) {
            const relativePath = cachedPath.replace(getProxyBaseURL(req), '');
            return res.redirect(relativePath);
        }
        
        // Fallback: stream directly if cache failed
        const response = await axios({
            url: imageUrl,
            method: 'GET',
            responseType: 'stream',
            timeout: CONFIG.TIMEOUT,
            httpsAgent: new https.Agent({
                rejectUnauthorized: false
            }),
        });
        
        res.setHeader('Content-Type', response.headers['content-type'] || 'image/jpeg');
        res.setHeader('Cache-Control', 'public, max-age=86400');
        response.data.pipe(res);
    } catch (error) {
        console.error(`❌ [GET] /proxy/image - Error:`, error.message);
        res.status(500).json({ 
            error: 'Failed to fetch image',
            message: error.message 
        });
    }
});

/**
 * GET /pravatar/:id
 * Convenience endpoint for pravatar.cc images (downloads and caches)
 * Usage: /pravatar/1, /pravatar/2, etc.
 */
app.get('/pravatar/:id', async (req, res) => {
    const id = req.params.id;
    const imageUrl = `${CONFIG.PRAVATAR_BASE}/150?u=${id}`;
    
    console.log(`📥 [GET] /pravatar/${id}`);
    
    try {
        const cachedPath = await downloadAndCacheImage(imageUrl, req);
        
        // Redirect to cached version
        if (cachedPath.includes('/cache/image/')) {
            const relativePath = cachedPath.replace(getProxyBaseURL(req), '');
            return res.redirect(relativePath);
        }
        
        // Fallback: stream directly
        const response = await axios({
            url: imageUrl,
            method: 'GET',
            responseType: 'stream',
            timeout: CONFIG.TIMEOUT,
            httpsAgent: new https.Agent({
                rejectUnauthorized: false
            }),
        });
        
        res.setHeader('Content-Type', response.headers['content-type'] || 'image/jpeg');
        res.setHeader('Cache-Control', 'public, max-age=86400');
        response.data.pipe(res);
    } catch (error) {
        console.error(`❌ [GET] /pravatar/${id} - Error:`, error.message);
        res.status(500).json({ 
            error: 'Failed to fetch image',
            message: error.message 
        });
    }
});

// ============================================================================
// HEALTH CHECK
// ============================================================================

app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        timestamp: new Date().toISOString(),
        cacheDir: CONFIG.CACHE_DIR,
        endpoints: {
            feed: 'GET /user/feed',
            reels: 'GET /user/reels',
            like: 'POST /user/like',
            dislike: 'DELETE /user/dislike',
            imageProxy: 'GET /proxy/image?url=...',
            pravatar: 'GET /pravatar/:id',
            cachedImage: 'GET /cache/image/:hash.:ext',
        }
    });
});

// ============================================================================
// START SERVER
// ============================================================================

app.listen(PORT, '0.0.0.0', () => {
    console.log('\n🚀 TLS Proxy Server is running!');
    console.log(`📍 Server URL: http://localhost:${PORT}`);
    console.log(`📍 Health Check: http://localhost:${PORT}/health`);
    console.log(`📍 Cache Directory: ${CONFIG.CACHE_DIR}`);
    console.log('\n📱 To use from iOS Simulator:');
    console.log('   Use: http://localhost:3000');
    console.log('\n📱 To use from physical iOS device:');
    console.log('   1. Find your Mac\'s IP: ifconfig | grep "inet "');
    console.log('   2. Use: http://YOUR_MAC_IP:3000');
    console.log('   3. Make sure Mac and iOS device are on same network');
    console.log('\n💾 Images will be cached in:', CONFIG.IMAGES_DIR);
    console.log('\n⚠️  Note: SSL verification is disabled for development only!\n');
});
