# 🌐 Ping Test Feature

## Overview
The Ping Test feature allows users to test their network connectivity by sending ping requests to their ISP router. The feature displays detailed ping statistics including packet loss, latency, and individual ping results.

## Features
- ✅ Real-time ping testing with visual feedback
- ✅ Extended timeout (90 seconds) for slow connections
- ✅ Detailed ping statistics (packets sent, received, loss percentage)
- ✅ Beautiful UI with status indicators
- ✅ Shows individual ping results (up to 10 displayed)
- ✅ Auto-fetches router_id and username from dashboard

## API Endpoint
```
GET {{Base_Url}}/pingUserApi?router_id={router_id}&name={username}
```

### Query Parameters
- `router_id`: User's router ID (fetched from dashboard)
- `name`: User's PPPoE ID/username (fetched from dashboard)

### Response Example
```json
{
    "status": "success",
    "data": [
        {
            "seq": "0",
            "host": "10.100.12.12",
            "status": "timeout",
            "sent": "1",
            "received": "0",
            "packet-loss": "100"
        },
        ...
    ],
    "average_latency": "N/A",
    "packets": {
        "sent": 25,
        "received": 0,
        "loss": "100%"
    }
}
```

## File Structure
```
lib/features/ping/
├── controllers/
│   └── ping_controller.dart      # Handles API calls and state management
├── models/
│   └── ping_model.dart           # Data models for ping response
└── ping_screen.dart              # UI screen
```

## Usage

### 1. Model Classes
The ping response is parsed into structured models:
- `PingResponse`: Main response wrapper
- `PingData`: Individual ping result
- `PingPackets`: Summary statistics

### 2. Controller
The `PingController` manages:
- Loading user information from dashboard
- Making ping API requests with extended timeout
- Processing and displaying results
- Status calculations based on packet loss

### 3. Screen
The `PingScreen` provides:
- Header with gradient background
- Loading states
- Results display with statistics
- Status indicators (Excellent, Good, Fair, Poor, No Connection)
- Detailed ping results list

## Implementation Details

### Extended Timeout
The ping API requires up to 1 minute to complete, so we use a custom Dio instance with 90-second timeout:

```dart
final dio = Dio(BaseOptions(
  baseUrl: AppApi.baseUrl,
  connectTimeout: const Duration(seconds: 90),
  receiveTimeout: const Duration(seconds: 90),
));
```

### Status Colors
- 🟢 **Green (Excellent)**: 0% packet loss
- 🟢 **Light Green (Good)**: < 10% packet loss
- 🟡 **Amber (Fair)**: < 30% packet loss
- 🟠 **Orange (Poor)**: < 100% packet loss
- 🔴 **Red (No Connection)**: 100% packet loss

### Data Flow
1. User opens Ping Screen
2. Controller loads user_id from storage
3. Controller fetches dashboard data to get router_id and pppoe_id
4. User clicks "Run Ping Test"
5. Controller makes ping API call with 90s timeout
6. Results are displayed with status indicators

## Error Handling
- ✅ No internet connection detection
- ✅ Timeout handling (90 seconds)
- ✅ User not found handling
- ✅ API error messages
- ✅ Network error handling

## UI States
1. **Initial State**: Shows placeholder with "No ping test run yet"
2. **Loading**: Shows spinner when fetching user info
3. **Pinging**: Shows progress indicator with "Running ping test..." message
4. **Results**: Displays detailed statistics and ping results
5. **Error**: Shows error message via snackbar

## Testing
To test the ping feature:
1. Ensure user is logged in
2. Navigate to Ping screen
3. Click "Run Ping Test" button
4. Wait for results (may take up to 1 minute)
5. View detailed statistics and individual ping results

## Notes
- The API response may contain 25+ ping results, but we only display the first 10 for better UX
- The feature requires a valid user_id, router_id, and pppoe_id
- Network connectivity is checked before making the request
- The feature uses GetX for state management

## Future Enhancements
- [ ] Add ability to ping custom hosts
- [ ] Show real-time ping progress
- [ ] Add ping history
- [ ] Export ping results
- [ ] Add graph visualization of ping times
- [ ] Add ability to configure ping count
