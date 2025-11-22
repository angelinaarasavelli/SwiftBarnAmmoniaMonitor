# 🏭 Barn Ammonia Monitor - iOS App

A comprehensive iOS application for real-time monitoring and management of ammonia levels in livestock barns. Built with SwiftUI and SceneKit for an intuitive, interactive experience.

![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.7+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📱 Features

### Dashboard
- **Multi-Barn Monitoring**: View all barns at a glance with real-time data
- **Color-Coded Alerts**: Instant visual indicators for ammonia levels
  - 🟢 Green: Healthy (< 20 ppm)
  - 🟠 Orange: Medium (20-50 ppm)
  - 🔴 Red: Critical (> 50 ppm)
- **Live Metrics**: Temperature, humidity, ventilation status, and ammonia PPM
- **Progress Bars**: Quick visual assessment of barn conditions

### 3D Heat Map Visualization
- **Interactive 3D Model**: Explore barn interior with touch controls
  - Pinch to zoom
  - Swipe to rotate 360°
  - Two-finger pan to move view
- **Real-Time Heat Mapping**: Color-coded spheres show ammonia concentration distribution
- **Smart Distribution**: Higher concentrations near floor and back (realistic modeling)
- **Animated Zones**: Pulsing indicators for active monitoring
- **Livestock Context**: 3D cow models for scale reference

### Individual Barn Controls
- **Remote Management**: Toggle barn systems on/off
  - 🌡️ Temperature monitoring
  - ☁️ Ammonia tracking
  - 🌀 Fan control
  - 💨 Ventilation system
  - 💧 Humidity monitoring
- **Live Values**: Real-time data display on each control
- **Haptic Feedback**: Physical response on interactions
- **Smart Toggle**: Green when active, gray when off

### Sensor Management
- **Multiple Sensors**: Monitor individual sensor readings per barn
- **Status Tracking**: See which sensors are online/offline
- **PPM Readings**: Precise ammonia measurements from each sensor

### Analytics
- **Trend Analysis**: Historical ammonia level charts
- **Custom Controls**: Adjustable vent temperature and bedding height
- **Data Visualization**: Multi-line charts with color-coded severity levels

## 🛠️ Technical Stack

- **Language**: Swift 5.7+
- **Framework**: SwiftUI
- **3D Graphics**: SceneKit
- **Charts**: Swift Charts
- **Minimum iOS**: 16.0
- **Architecture**: MVVM pattern with SwiftUI state management

## 📋 Requirements

- Xcode 14.0 or later
- iOS 16.0 or later
- macOS 12.0 or later (for development)

## 🚀 Installation

### Clone the Repository
```bash
git clone https://github.com/angelinaarasavelli/SwiftBarnAmmoniaMonitor.git
cd SwiftBarnAmmoniaMonitor
```

### Open in Xcode
```bash
open AmmoniaSensorDashboard.xcodeproj
```

### Build and Run
1. Select your target device (simulator or physical iPhone)
2. Press `⌘ + R` or click the Play button
3. App will build and launch

## 📱 Usage

### Adding a New Barn
1. Tap the **"+"** button in the Dashboard
2. Enter barn name and target temperature
3. Tap **"Add"**

### Viewing Barn Details
1. Tap any barn card on the Dashboard
2. Explore the 3D heat map with touch gestures
3. Toggle controls to manage barn systems
4. View individual sensor readings

### Monitoring Trends
1. Navigate to the **"Ammonia"** tab
2. Adjust controls with sliders
3. View historical trend chart
4. Monitor safe, warning, and critical levels

## 🎨 Color Coding System

### Ammonia PPM Levels
| Level | PPM Range | Color | Action |
|-------|-----------|-------|--------|
| Healthy | < 20 ppm | 🟢 Green | Normal operations |
| Medium | 20-50 ppm | 🟠 Orange | Increase ventilation |
| Critical | > 50 ppm | 🔴 Red | Immediate action required |

## 🏗️ Project Structure
```
AmmoniaSensorDashboard/
├── ContentView.swift           # Main app entry point
├── Models/
│   ├── Barn                   # Barn data model
│   ├── Sensor                 # Sensor data model
│   └── AmmoniaReading         # Historical data model
├── Views/
│   ├── DashboardView          # Main barn grid
│   ├── BarnDetailView         # Individual barn details
│   ├── Barn3DHeatMapView      # SceneKit 3D visualization
│   ├── AmmoniaDetailView      # Analytics & trends
│   └── Components/            # Reusable UI components
└── Assets.xcassets            # Images and colors
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👩‍💻 Author

**Angelina Arasavelli**
- GitHub: [@angelinaarasavelli](https://github.com/angelinaarasavelli)


## 📞 Support

For support, email aarasavelli@wisc.edu



