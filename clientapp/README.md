# IsppayBD User Portal

This is a Flutter mobile application for the IsppayBD User Portal - an ISP (Internet Service Provider) management system.

## Features

### Authentication
- Splash screen with animated logo
- Login screen with demo credentials
- Email: 34003395@gmail.com
- Password: 123456

### Dashboard
- User statistics cards (Total Payment, Successful Payments, Pending Payments, Support Tickets)
- Network usage chart
- Current package information
- Sidebar navigation menu

### Package Management
- View available internet packages (10MB to 100MB)
- Package pricing and bandwidth information
- Activate/deactivate packages

### Payment Management
- Payment history table
- Invoice tracking
- Payment status monitoring

### Profile Management
- User profile details
- Account information
- Subscription details

### Navigation
- Bottom navigation bar
- Sidebar drawer menu
- Smooth page transitions

## Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **Architecture**: MVC (Model-View-Controller)
- **Routing**: GetX Navigation
- **Theme**: Material 3 with custom ISP portal colors
- **Data**: Local JSON dummy data

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── constants/     # Colors, API endpoints, sizes
│   │   ├── localization/  # Multi-language support
│   │   └── theme/         # App theme configuration
│   ├── helpers/           # Utility functions
│   ├── routes/            # GetX routing setup
│   ├── services/          # Data and network services
│   └── utils/             # Common utilities
├── features/
│   ├── auth/             # Authentication (login, splash)
│   ├── dashboard/        # Main dashboard
│   ├── packages/         # Package management
│   ├── payment/          # Payment history
│   └── profile/          # User profile
└── shared/
    ├── models/           # Data models
    └── widgets/          # Reusable UI components
```

## Getting Started

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

3. **Login with demo credentials**:
   - Email: 34003395@gmail.com
   - Password: 123456

## Screenshots

The app includes all the screens shown in the UI mockups:
- Dashboard with payment statistics
- Package configuration table
- Payment history
- User profile with tabs
- Support ticket management

## Demo Data

The app uses dummy data stored in `assets/data/dummy_data.json` to simulate:
- User profile information
- Payment statistics
- Package configurations
- Network usage data
- Transaction history

## Development

This app follows clean architecture principles with:
- Separation of concerns
- Dependency injection using GetX
- Responsive design
- Material 3 theming
- Professional ISP portal UI/UX

Built with Flutter 3.x and GetX state management for optimal performance and maintainability.
