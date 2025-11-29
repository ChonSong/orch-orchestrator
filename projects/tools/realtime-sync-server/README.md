# Real-Time Sync Server

A Node.js server providing real-time synchronization across multiple devices for seamless user experience.

## Features

- **Real-time WebSocket connections** using Socket.IO
- **User authentication** with JWT tokens
- **Device management** with unique device IDs
- **Session persistence** with SQLite + Redis
- **Cross-device synchronization** with conflict resolution
- **Graceful disconnect handling** with session restoration

## Quick Start

```bash
# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Start development server
npm run dev

# Start production server
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create new user account
- `POST /api/auth/login` - Authenticate user and get JWT token

### Device Management
- `GET /api/devices` - Get all user's devices (requires auth)

### Session Management
- `GET /api/session` - Get persisted session data (requires auth)

### Health Check
- `GET /api/health` - Server health status

## WebSocket Events

### Client -> Server

#### Connection
```javascript
const socket = io('wss://your-domain.com:3001', {
  auth: { token: 'jwt-token' },
  query: {
    deviceInfo: JSON.stringify({
      name: 'My Device',
      type: 'desktop',
      viewport: '1920x1080'
    })
  }
});
```

#### Session Updates
```javascript
socket.emit('session-update', {
  sessionKey: 'editor-state',
  state: { text: 'Hello World', cursor: 5 }
});
```

#### Real-time Events
```javascript
socket.emit('realtime-event', {
  type: 'cursor-move',
  payload: { position: 10 }
});
```

#### Device Messages
```javascript
socket.emit('device-message', {
  targetDeviceId: 'device-uuid',
  message: { type: 'ping', data: {} }
});
```

### Server -> Client

#### Session Events
- `session-restored` - Initial session data on connection
- `session-updated` - Session state changed on another device

#### Device Events
- `device-connected` - New device connected for this user
- `device-disconnected` - Device disconnected

#### Real-time Events
- `realtime-event` - Real-time updates from other devices
- `device-message` - Direct messages from other devices

#### Error Handling
- `error` - Server error messages

## Usage Example

```javascript
// Client-side integration
class CrossDeviceSync {
  constructor(token, deviceInfo) {
    this.socket = io('wss://your-domain.com:3001', {
      auth: { token },
      query: { deviceInfo: JSON.stringify(deviceInfo) }
    });

    this.setupEventHandlers();
  }

  setupEventHandlers() {
    this.socket.on('session-restored', ({ sessionData, deviceId }) => {
      console.log('Session restored:', sessionData);
      this.deviceId = deviceId;
      // Restore UI state
    });

    this.socket.on('session-updated', ({ sessionKey, state, deviceId }) => {
      if (deviceId !== this.deviceId) {
        console.log('Session updated by another device:', sessionKey, state);
        // Update UI with new state
      }
    });

    this.socket.on('realtime-event', ({ type, payload, sourceDeviceId }) => {
      if (sourceDeviceId !== this.deviceId) {
        console.log('Real-time event:', type, payload);
        // Handle real-time updates
      }
    });
  }

  updateSession(key, state) {
    this.socket.emit('session-update', { sessionKey: key, state });
  }

  sendRealtimeEvent(type, payload) {
    this.socket.emit('realtime-event', { type, payload });
  }
}

// Usage
const sync = new CrossDeviceSync('jwt-token', {
  name: 'Chrome Desktop',
  type: 'desktop',
  viewport: '1920x1080'
});

// Update editor state
sync.updateSession('editor', {
  content: 'Hello World',
  cursor: 5,
  selection: { start: 0, end: 11 }
});

// Send cursor position
sync.sendRealtimeEvent('cursor', { line: 1, column: 5 });
```

## Architecture

```
┌─────────────────┐    WebSocket     ┌─────────────────┐
│   Device A      │ ◄──────────────► │                 │
│ (dev.codeovertcp.com)  │                 │
│                 │                  │   Sync Server   │
└─────────────────┘                  │   (Node.js)     │
                                    │                 │
┌─────────────────┐    WebSocket     │  • Socket.IO    │
│   Device B      │ ◄──────────────► │  • JWT Auth     │
│ (mobile.codeovertcp.com) │                 │  • Redis Cache  │
│                 │                  │  • SQLite DB    │
└─────────────────┘                  └─────────────────┘
```

## Configuration

Set these environment variables:

```bash
PORT=3001                    # Server port
JWT_SECRET=your-secret-key   # JWT signing key
REDIS_URL=redis://localhost:6379  # Redis connection string
```

## Database Schema

### Users Table
- `id` - User UUID
- `email` - Email address (unique)
- `password_hash` - Bcrypt hash
- `created_at` - Account creation time
- `updated_at` - Last update time

### Devices Table
- `id` - Device UUID
- `user_id` - Owner user ID
- `name` - Device display name
- `type` - Device type (desktop, mobile, tablet)
- `last_seen` - Last connection time
- `metadata` - JSON device metadata

### Sessions Table
- `id` - Session ID (user:sessionKey format)
- `user_id` - Owner user ID
- `device_id` - Device that created session
- `data` - JSON session state
- `created_at` - Session creation time
- `updated_at` - Last update time