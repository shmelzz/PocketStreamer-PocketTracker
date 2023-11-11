# MetaTracking Project Documentation

## Overview

MetaTracking is a multi-component system involving an iOS application for face tracking, a Go server for data processing and broadcasting, and a Unity project for visualizing or utilizing the tracked data. This system is designed to capture and transmit real-time facial feature data for various applications.

## Components

### 1. FaceTrackingStreamer (iOS App)
- **Purpose**: Captures real-time facial feature data using the iOS device's camera.
- **Key Files**:
  - `AppDelegate.swift`, `SceneDelegate.swift`, `ViewController.swift`: Standard iOS app components.
  - `FaceTrackerExtension.swift`, `FaceTrackingViewController.swift`: Handle the face tracking logic.
- **Functionality**: Streams facial feature data to the server.

### 2. PocketCenter (Go Server)
- **Purpose**: Receives, processes, and broadcasts facial feature data.
- **Key Files**:
  - `main.go`: Entry point of the server, sets up WebSocket connections.
  - `app.go`: Defines the application structure and server startup logic.
  - `config.go`: Manages server configuration settings.
  - `handler.go`: Handles WebSocket connections and data transmission.
  - `model/FaceTrackingFeatures.go`: Defines the data structure for face tracking features.
  - `router.go`: Configures HTTP routes for the application.
- **Functionality**: Acts as a central hub for data transmission between the iOS app and Unity project.

### 3. MetaComposer (Unity Project)
- **Purpose**: Utilizes the facial feature data for various applications, such as animation or interaction in a Unity environment.
- **Key Files**:
  - C# Scripts like `FaceDecoder.cs`, `FaceTrackingData.cs`, `Movement.cs`, `WebsocketConnection.cs`: Handle the reception and utilization of facial feature data.
- **Functionality**: Receives and processes facial feature data broadcasted by the server.

## Setup and Installation

1. **FaceTrackingStreamer**:
   - Requires an iOS device.
   - Install Xcode and open the project.
   - Build and run on an iOS device.

2. **PocketCenter**:
   - Requires Go environment.
   - Navigate to the `PocketCenter` directory.
   - Run `go build` and `./PocketCenter` to start the server.

3. **MetaComposer**:
   - Requires Unity Editor.
   - Open the project in Unity.
   - Configure to connect to the PocketCenter server.

## Usage

1. Start the PocketCenter server.
2. Run the FaceTrackingStreamer app on an iOS device.
3. Open the MetaComposer project in Unity.
4. Ensure all components are communicating correctly.

## Contributing

Contributions to the MetaTracking project are welcome. Please follow the standard procedures for submitting issues, feature requests, and pull requests.
