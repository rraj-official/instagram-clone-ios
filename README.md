# Instagram Clone

## Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **UI**: SwiftUI (Custom Design System matching Instagram)
- **Concurrency**: Swift Async/Await
- **Networking**: URLSession + Codable
- **Persistence**: Core Data (Offline caching)
- **Sync**: Custom `PendingActionSyncer` for offline actions

## Features
1. **Login**: 
   - Authentic UI with language selector and footer.
   - Hardcoded auth (`user@example.com` / `password123`). 
   - Persists via `UserDefaults`.
2. **Feed**:
   - **Stories Row**: Horizontal scroll with gradient rings.
   - **Post Cell**: Pixel-polished layout with double-tap-to-like animation.
   - **Optimistic UI**: Instant like toggles.
   - **Offline**: Subtle banner notification.
3. **Reels**:
   - Full-screen vertical paging.
   - Video playback (AVPlayer) with play/pause interaction.
   - Custom overlay with right-aligned actions and bottom metadata.

## Offline Logic
1. **Fetching**: `Repository` checks `NetworkMonitor`.
   - If **Online**: Fetch API -> Save to Core Data -> Return data.
   - If **Offline**: Return data from Core Data immediately.
2. **Actions (Like/Unlike)**:
   - UI updates immediately (Optimistic).
   - Core Data updates immediately.
   - If **Online**: Call API. If API fails, revert Core Data + UI.
   - If **Offline**: Create `PendingLikeActionEntity` in Core Data.
3. **Sync**:
   - `PendingActionSyncer` observes `NetworkMonitor`.
   - When connection returns, it iterates pending actions and executes them against the API.

## Setup
1. Open `Instagram.xcodeproj`.
2. Wait for Swift Package Manager (if any deps) or Indexing.
3. Build and Run on Simulator (iPhone 15/16 recommended).

## Testing Offline Mode
1. Run App.
2. Toggle "Link Conditioner" or disable WiFi on host.
3. Verify red "No Internet Connection" banner appears.
4. Verify previously loaded content is visible.
5. Perform Likes (observe UI updates).
6. Re-enable WiFi -> Watch console for Sync logs (`✅ Synced action...`).
