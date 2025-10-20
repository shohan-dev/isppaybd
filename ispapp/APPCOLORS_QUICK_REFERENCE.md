# AppColors Quick Reference Guide

## 🎯 Quick Color Lookup

### Common Usage Patterns

#### **Backgrounds**
```dart
AppColors.backgroundGrey    // Main scaffold background
AppColors.cardBackground    // Card/container backgrounds
AppColors.surface          // Surface elements
```

#### **Text**
```dart
AppColors.textPrimary      // Main headings/titles
AppColors.textSecondary    // Subtitles/descriptions
AppColors.textWhite        // White text on dark backgrounds
AppColors.textWhite70      // Secondary white text (70% opacity)
```

#### **Borders & Overlays**
```dart
AppColors.borderLight      // Light borders (30% white)
AppColors.borderWhite      // White borders
AppColors.overlay10        // 10% white overlay
AppColors.overlay12        // 12% white overlay
AppColors.overlay18        // 18% white overlay
AppColors.overlay20        // 20% white overlay
AppColors.shadowLight      // 8% black shadow
```

#### **Status Colors**
```dart
AppColors.success          // Success/active/connected
AppColors.warning          // Warning/pending
AppColors.error            // Error/failed/disconnected
AppColors.info             // Information
```

#### **Gradients** (use directly in LinearGradient)
```dart
AppColors.headerGradient         // Header gradient
AppColors.totalPaymentGradient   // Total payment card
AppColors.successGradient        // Success card
AppColors.pendingGradient        // Pending card
AppColors.supportGradient        // Support card
```

---

## 🎨 Common Code Snippets

### Card with Shadow
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        spreadRadius: 1,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

### Gradient Container
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: AppColors.headerGradient, // or any gradient
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Text Styles
```dart
// Primary heading
Text(
  'Title',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  ),
)

// Secondary text
Text(
  'Subtitle',
  style: TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  ),
)

// White text on dark background
Text(
  'Header Text',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  ),
)
```

### Overlay Container
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.overlay20,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderLight, width: 1),
  ),
)
```

### Error Message
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.errorBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.errorBorder, width: 1),
  ),
  child: Row(
    children: [
      Icon(Icons.warning_amber_rounded, color: AppColors.errorIcon),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'Error message',
          style: TextStyle(color: AppColors.errorText),
        ),
      ),
    ],
  ),
)
```

### Icon with Background
```dart
Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: AppColors.success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.check_circle,
    color: AppColors.success,
    size: 24,
  ),
)
```

---

## 🔍 Feature-Specific Colors

### Account Overview
```dart
receivedColor  → Green  (Payment received)
pendingColor   → Orange (Payment pending)
ticketColor    → Blue   (Support tickets)
```

### Usage Stats
```dart
uploadColor    → Light Blue (Upload usage)
downloadColor  → Light Blue (Download usage)
uptimeColor    → Teal       (Uptime)
```

### Traffic Chart
```dart
trafficDownload → Light Blue (Download line)
trafficUpload   → Light Green (Upload line)
```

### Payment Chart
```dart
paymentSuccessful → Light Blue (Successful bars)
paymentPending    → Light Green (Pending bars)
```

---

## 🛠️ Helper Methods

### Get Bandwidth Color
```dart
Color color = AppColors.getBandwidthColor(bandwidth);
// < 50 MBPS      → Grey
// 50-100 MBPS    → Blue
// 100-200 MBPS   → Orange
// > 200 MBPS     → Purple
```

### Get Status Color
```dart
Color color = AppColors.getStatusColor(status);
// 'active', 'connected', 'success'     → Green
// 'pending', 'inactive'                → Orange
// 'failed', 'disconnected', 'error'    → Red
// default                              → Blue
```

---

## 📋 Color Hex Values

### Quick Reference Table

| **Color Name** | **Hex Code** | **Usage** |
|----------------|--------------|-----------|
| `primary` | #282a35 | Dark blue-grey |
| `primaryLight` | #357ABD | Medium blue |
| `textPrimary` | #424242 | Dark grey text |
| `textSecondary` | #757575 | Grey text |
| `success` | #4CAF50 | Green |
| `warning` | #FF9800 | Orange |
| `error` | #F44336 | Red |
| `info` | #2196F3 | Blue |
| `uploadColor` | #64B5F6 | Light blue |
| `uptimeColor` | #4DB6AC | Teal |
| `trafficUpload` | #81C784 | Light green |

---

## ✅ Best Practices

1. **Always use AppColors** instead of hardcoded colors
2. **Use semantic names** (e.g., `textPrimary` instead of remembering `#424242`)
3. **Use gradients directly** from AppColors for consistency
4. **Use helper methods** for dynamic coloring
5. **Keep opacity in constants** (e.g., `overlay20` instead of `.withOpacity(0.2)`)

---

## 🚫 Don't Do This

```dart
// ❌ BAD - Hardcoded colors
Container(color: Color(0xFF424242))
Text(style: TextStyle(color: Colors.white70))
colors: [Color(0xFF282a35), Color(0xFF357ABD)]

// ✅ GOOD - Use AppColors
Container(color: AppColors.textPrimary)
Text(style: TextStyle(color: AppColors.textWhite70))
colors: AppColors.headerGradient
```

---

## 📱 Import Statement

```dart
import 'package:ispapp/core/config/constants/color.dart';
```

---

## 🎯 Complete Color List

### Alphabetical Reference
```dart
badgeBackground
badgeText
bandwidth100to200
bandwidth200Plus
bandwidth50Below
bandwidth50to100
borderLight
borderWhite
cardBackground
downloadColor
error
errorBackground
errorBorder
errorIcon
errorLight
errorText
headerGradient
info
infoLight
overlay10
overlay12
overlay18
overlay20
packageBorderActive
paymentPending
paymentSuccessful
pendingColor
pendingGradient
primary
primaryLight
primaryVariant
receivedColor
secondary
secondaryVariant
shadowLight
success
successDark
successGradient
successLight
successLighter
supportGradient
surface
textPrimary
textSecondary
textWhite
textWhite70
ticketColor
totalPaymentGradient
trafficDownload
trafficUpload
uploadColor
uptimeColor
warning
warningDark
warningLight
```

**Total:** 54 color constants + 3 helper methods

---

**Quick Tip:** Use your IDE's autocomplete by typing `AppColors.` to see all available options!
