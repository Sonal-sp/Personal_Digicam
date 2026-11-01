# 🎀 Aesthetic Digicam — Premium Mobile Camera & Photo Editing Studio

<div align="center">

![Aesthetic Digicam Banner](https://img.shields.io/badge/Aesthetic-Digicam%20%26%20Scrapbook-pink?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.44.7-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android 14](https://img.shields.io/badge/Android-14%20(API%2034)-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Security](https://img.shields.io/badge/Security-JWT%20%7C%20OAuth%202.0%20PKCE-blueviolet?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

<p align="center">
  <b>Transform ordinary mobile pictures into nostalgic, Instagram-worthy, Pinterest-inspired, Y2K, vintage, coquette, and digital-camera-style photographs.</b>
</p>

[Overview](#-overview) •
[Key Features](#-key-features--screen-tour) •
[Security & Auth Architecture](#-security--authentication-architecture) •
[Design System](#-design-system--color-palette) •
[Device Deployment](#-physical-device-deployment--verification) •
[Firebase Setup](#-firebase--database-configuration) •
[Directory Structure](#-project-architecture--directory-structure)

</div>

---

## 📸 Overview

**Aesthetic Digicam** is an all-in-one mobile camera, non-destructive photo editor, and creative scrapbook studio designed with the tactile nostalgia of early 2000s Olympus Camedia and Sony Cyber-shot CCD digital cameras.

Instead of looking like a generic photo editor, the app delivers a distinct personality:
- **Y2K Digital Camera & CCD Color Science**: Harsh xenon flash simulation, blown highlights, cool shadows, and glowing orange date stamps.
- **Coquette & Soft Girl Aesthetics**: Silk bows, pearlescent angel glow, rosy cherry blush, and pastel palettes.
- **Pinterest-Worthy Editorial Styling**: Soft beige cafe tones, warm 35mm film grain, polaroid borders, and scrapbook collages.
- **RFC 7519 JWT & RFC 7636 OAuth 2.0 PKCE**: Enterprise-grade security architecture with client-side cryptographic token signing and state nonce verification.
- **Friction-Free Dual Operation**: Shoot, edit, and export immediately in offline Guest Mode without mandatory account registration, with optional Cloud Firestore & Storage synchronization.
- **Hardware-Accelerated Real-Time Rendering**: Impeller-powered Vulkan & OpenGL ES shaders executing ColorMatrix presets at 60 FPS.

---

## ✨ Key Features & Screen Tour

```
┌────────────────────────────────────────────────────────────────────────┐
│                        MAIN NAVIGATION (5 TABS)                        │
├─────────────┬─────────────┬─────────────┬──────────────┬───────────────┤
│   1. HOME   │  2. CAMERA  │ 3. DISCOVER │  4. STUDIO   │  5. MY SHOTS  │
└─────────────┴─────────────┴─────────────┴──────────────┴───────────────┘
```

### 1. 📷 In-App Camera with Retro LCD Viewfinder HUD
- **Real-Time 60fps Filter Previews**: Powered by hardware-accelerated color matrices.
- **Tactile Digicam Viewfinder (OSD)**:
  - Battery charge level (`85%`) with LED indicator.
  - SD Memory card indicator (`SD: 16GB`).
  - Remaining shot counter `[024 / 999]`.
  - Exposure & ISO readout (`ISO 200`, `1/250s`, `F2.8`, `1.0X`).
  - Rule-of-thirds framing grid (toggleable).
  - Glowing orange LCD date stamp burned into bottom corner.
  - Front / rear camera flip, flash modes (Auto, Always, Torch, Off).
  - Tactile metallic shutter button with haptic feedback.

### 2. 🪄 Signature Feature: Mood-to-Photo 1-Tap Recipes
Select your desired aesthetic mood and apply a coordinated recipe in one tap:
1. Coordinated Filter Preset
2. Non-Destructive Adjustments (brightness, contrast, saturation, temperature, grain)
3. Themed Sticker Pack
4. Retro Frame & Customizable Timestamp
5. Contextual Caption Suggestions

| Mood | Filter Preset | Frame & Date Stamp | Sticker Pack | Vibe |
|---|---|---|---|---|
| **Pookie Pink** 🎀 | Pink Dream | Coquette Ribbon + Cyber Pink Date | Silk Bows, Sparkle Hearts | Soft girl sweetness, balletcore |
| **2000s Digicam** 📷 | Y2K Flash | Polaroid + 90s Orange Date | Holographic CD, Flip Phone | Cyber party, memory card nostalgia |
| **Pinterest Girl** ☕ | Soft Beige | Scrapbook Paper + White Minimal Date | Daisies, White Heart | Clean neutral aesthetic, iced matcha |
| **Night Out** 🍸 | Night Flash | 35mm Film + 90s Orange Date | Glow Burst, Cyber Star | Direct xenon flash, moody club shadows |
| **Vintage Memories** 🎞️ | Old Film | 35mm Film + 90s Orange Date | Vintage Rose, Crown | Warm analog 35mm print stock & grain |
| **Soft Girl** 🌸 | Angel Glow | Scrapbook + White Minimal Date | Lavender Butterfly, Angel Wings | Pearlescent dream haze & butterflies |
| **Messy Photo Dump** 📦 | Retro CCD | Scrapbook + 90s Orange Date | Glossy Cherries, Soft Teddy | Uncensored week recaps & candids |
| **Summer Diaries** ☀️ | Golden Hour | Polaroid + 90s Orange Date | Pastel Star, Magic Twinkle | Amber sunset glow, ocean haze |
| **Cafe Aesthetic** 🥐 | Cafe Aesthetic | Vintage Border + White Minimal Date | White Heart, Dream Cloud | Oat milk latte warmth, book chapters |

### 3. 🎨 24 Curated Filter Presets across 5 Collections
- **Digicam**: Y2K Flash, Retro CCD, 2000s Party, Soft Digicam, Cool Flash.
- **Coquette**: Pink Dream, Cherry Blush, Soft Romance, Bow Effect, Angel Glow.
- **Vintage**: Old Film, Warm Memories, Faded Summer, Film Grain, Retro Brown.
- **Night**: Night Flash, City Lights, Party Camera, Midnight Glow.
- **Pinterest**: Soft Beige, Cafe Aesthetic, Golden Hour, Dreamy Light.

### 4. 🛠️ Professional Photo Editor (Studio)
- **Non-Destructive Editing**: Adjustments remain separate from original images.
- **10 Fine-Tuning Sliders**: Brightness, Contrast, Saturation, Exposure, Temperature, Highlights, Shadows, Sharpness, Film Grain, Vignette.
- **Interactive Split Comparison**: Draggable before/after wipe divider with retro OSD labels.
- **20-Step Undo/Redo**: Non-destructive history stack with reset button.
- **High-Resolution Export**: High-fidelity export pipeline burning optional date stamps directly to disk.

### 5. 🎀 Creative Scrapbook Studio & Multi-Touch Stickers
- **10 Sticker Categories**: Bows, Hearts, Stars, Cherries, Flowers, Teddy Bears, Butterflies, Sparkles, Doodles, Y2K Decorations.
- **Multi-Touch Manipulation**: Freeform drag, corner resize/rotate knobs, bring-to-front layer order, delete.

### 6. 📅 Retro Frames & Customizable Date Stamps
- **Frames**: Classic Polaroid with caption margin, 35mm Film with perforations, Scrapbook torn paper, Coquette Ribbon, Y2K Chrome.
- **Date Stamps**: 90s Olympus Glowing Orange, Pinterest Minimal White, Green Camcorder LED, Cyber Pink.
- **Customizable**: Position cycler (BR, BL, TR, TL), custom date/time picker, and clear distinction between verified EXIF metadata and decorative timestamps.

### 7. 📦 Collage & Photo Dump Maker
- **Layouts**: 2-photo horizontal/vertical split, 3-photo spotlight trio, 4-grid classic, magazine editorial, scrapbook scattered dump.
- **Customizable Canvas**: Pastel palette background selector, spacing slider (0–20px), corner rounding slider (0–28px).

### 8. ✍️ AI Caption Generator
- **10 Tone Styles**: Cute, Funny, Sarcastic, Pinterest, Y2K, Mysterious, Confident, Minimal, Travel Diary, Best Friends.
- **Hybrid Engine**: Supports secure backend proxy endpoints with a built-in offline aesthetic quote library. One-tap copy to clipboard and favorites.

### 9. 💾 My Shots & Personal Gallery
- Filter by All Shots, Exported Edits, Saved Projects, and Studio Samples.
- Full-screen viewer with instant system sharing (`share_plus`) and non-destructive re-editing.

---

## 🔒 Security & Authentication Architecture

Aesthetic Digicam implements an **RFC-compliant, zero-trust cryptographic security architecture**:

```mermaid
sequenceDiagram
    autonumber
    actor User as User / Client
    participant App as Flutter App
    participant OAuth as OAuth 2.0 PKCE Engine
    participant JWT as RFC 7519 JWT Service
    participant API as Backend Services / Firebase

    User->>App: Initiate Sign-In (Google / Apple / Email)
    App->>OAuth: Generate High-Entropy Code Verifier & State Nonce
    OAuth->>OAuth: Compute Code Challenge (BASE64URL(SHA256(verifier)))
    OAuth->>App: Launch Auth Flow with Challenge & State
    User->>OAuth: Authorize Application
    OAuth-->>App: Return Authorization Code & State
    App->>OAuth: Validate State Nonce & Exchange Code + Verifier for Tokens
    OAuth-->>JWT: Issue Access & Refresh Tokens
    JWT->>JWT: Cryptographically Verify HMAC-SHA256 Signature & Claims
    JWT-->>App: Store Encrypted TokenPair (Memory & Secure Cache)
    App->>API: Authenticated Request with Bearer JWT
    API-->>App: Authorized Response
```

### 1. RFC 7519 JWT Service (`JwtService`)
- **Cryptographic Signature Engine**: HMAC-SHA256 token encoding, validation, and decoding.
- **Claim Enforcement**: Validates standard claims (`iss`, `sub`, `aud`, `exp`, `iat`, `jti`) alongside custom user scopes and role claims.
- **Automatic TTL Expiry & Refresh**: Proactively triggers refresh flows prior to expiration.
- **Live Claims Inspector**: Built-in visual inspector in the Auth Sheet displaying parsed token payload data, active scopes, and remaining TTL in real time.

### 2. RFC 7636 OAuth 2.0 PKCE Flow (`OAuthService`)
- **Proof Key for Code Exchange (PKCE)**: Eliminates vulnerability to authorization code interception on mobile devices without relying on client secrets.
- **High-Entropy Verifier**: Cryptographically random 43-character to 128-character verifier strings.
- **SHA-256 Code Challenge**: `Base64URL(SHA256(code_verifier))` transformations.
- **State Nonce Verification**: Protects against cross-site request forgery (CSRF).

### 3. Zero-Leak Security & Sanitization
- **Client Sanitization**: All production secrets, private keys, and sensitive tokens are completely decoupled from client code.
- **Clean Git Tracking**: `.gitignore` strictly protects `.env`, `google-services.json`, `GoogleService-Info.plist`, keystores, and local credentials from version control.

---

## 🎨 Design System & Color Palette

The UI adopts a soft pastel aesthetic accented with vintage metallic camera hardware:

| Color Token | Hex Code | Visual Application |
|---|---|---|
| **Blush Pink** | `#F8C8DC` | Primary buttons, active highlights, badges |
| **Soft Pink** | `#FCE4EF` | Subtle surface cards, chip containers |
| **Lavender** | `#DCD6F7` | Secondary accents, tags, collage backgrounds |
| **Cream** | `#FFF8F0` | Warm vintage scaffold background, paper frames |
| **Deep Plum** | `#503047` | High-contrast typography, primary dark buttons |
| **Retro Orange** | `#FF7A00` | Glowing 90s digital camera LCD date stamps |
| **LED Green** | `#4ADE80` | Camcorder OSD status, battery level, verified badges |
| **LCD Cyan** | `#38BDF8` | Camera viewfinder HUD telemetry |

---

## 📲 Physical Device Deployment & Verification

The application has been compiled, deployed, and verified on physical hardware:

- **Target Device**: Samsung Galaxy F23 5G (`SM-E236B`)
- **Operating System**: Android 14 (API Level 34)
- **Rendering Engine**: Impeller (Vulkan / OpenGL ES) running real-time 60 FPS shaders
- **Android Gradle Plugin (AGP)**: `8.9.1`
- **Gradle Version**: `8.11.1`
- **Kotlin Version**: `2.1.0`

### Optimized Android Build Settings (`android/gradle.properties`)
To avoid memory exhaustion and Windows IPv6 DNS timeouts on resource-constrained development hosts:
```properties
org.gradle.jvmargs=-Xmx1536m -XX:MaxMetaspaceSize=768m -XX:+UseG1GC -Djava.net.preferIPv4Stack=true
android.useAndroidX=true
android.newDsl=false
android.builtInKotlin=false
kotlin.incremental=false
org.gradle.workers.max=2
```

### Installation & Launch via ADB
```bash
# Build debug APK
flutter build apk --debug --android-skip-build-dependency-validation

# Streamed install to connected physical device
adb -s <DEVICE_ID> install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch directly into MainActivity
adb -s <DEVICE_ID> shell am start -n com.digicam.aesthetic.personal_digicam/.MainActivity
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `^3.44.0` (or higher)
- **Dart SDK**: `^3.12.0` (or higher)
- **JDK**: Java 17 or 21
- **Android SDK**: API 34+ with platform-tools (ADB)

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/Sonal-sp/Personal_Digicam.git
cd Personal_Digicam

# Fetch Flutter packages
flutter pub get
```

### 2. Generate Aesthetic Studio Sample Assets
The app includes a built-in asset generator that creates high-resolution sample photos for immediate offline testing:
```bash
dart run tool/generate_sample_assets.dart
```

### 3. Run the App
```bash
# Launch on connected Android device
flutter run

# Or run on Windows desktop / Web
flutter run -d windows
flutter run -d chrome
```

---

## 🔥 Firebase & Database Configuration

Aesthetic Digicam operates in **Dual Mode**:
1. **Offline-First / Guest Mode (Default)**: Full camera, filter engine, studio editor, sticker studio, collage maker, and local storage run without requiring Firebase setup.
2. **Connected Cloud Mode**: When Firebase is configured, user authentication, Cloud Firestore sync, and Firebase Storage cloud backups are enabled.

```mermaid
flowchart LR
    App["Flutter Client\n(Aesthetic Digicam)"] --> Local["Local Storage\n(SharedPreferences & Cache)"]
    App -.->|"When Configured"| FB["Firebase Services"]
    FB --> Auth["Firebase Authentication\n(Email & Google)"]
    FB --> Store["Cloud Firestore\n(User Profiles & Projects)"]
    FB --> Storage["Firebase Storage\n(Exported Shots Backup)"]
```

### Step 1: Connect your Firebase Project
1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Configure project:
   ```bash
   flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
   ```
3. Place `google-services.json` at `android/app/google-services.json`.

### Step 2: Cloud Firestore Database Schema
```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── displayName: string
│       ├── photoUrl: string?
│       ├── lastActiveAt: timestamp
│       │
│       ├── projects/
│       │   └── {projectId}/
│       │       ├── id: string
│       │       ├── title: string
│       │       ├── filterId: string
│       │       ├── filterIntensity: number
│       │       ├── brightness: number
│       │       ├── contrast: number
│       │       ├── saturation: number
│       │       ├── temperature: number
│       │       ├── grain: number
│       │       ├── vignette: number
│       │       ├── rotationDegrees: number
│       │       └── lastModified: timestamp
│       │
│       └── presets/
│           └── {presetId}/
│               ├── name: string
│               └── settings: map
│
└── public_filters/
    └── {filterId}/
        ├── name: string
        ├── category: string
        └── matrix: array<number>
```

### Step 3: Deploy Security Rules
The repository contains hardened security rules:
- [`firestore.rules`](file:///d:/ALL%20PROJECTS/personal_digicam/firestore.rules): User-isolated document permissions.
- [`storage.rules`](file:///d:/ALL%20PROJECTS/personal_digicam/storage.rules): Access restricted to authenticated user directories.

Deploy to Firebase:
```bash
firebase deploy --only firestore:rules,storage
```

---

## 🧪 Testing & Code Quality

```bash
# Static analysis (0 errors, 0 warnings)
flutter analyze

# Run unit and widget test suite (100% passing)
flutter test
```

---

## 📁 Project Architecture & Directory Structure

```
lib/
├── firebase_options.dart          # Multi-platform Firebase configuration (sanitized)
├── main.dart                      # App entrypoint, theme bootstrap & orientation lock
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Blush, lavender, cream, retro orange & silver tokens
│   │   └── app_typography.dart    # Playfair Display, Plus Jakarta Sans, VT323 LCD fonts
│   ├── theme/
│   │   └── app_theme.dart         # Material 3 light & dark theme specifications
│   ├── security/
│   │   ├── jwt_service.dart       # RFC 7519 HMAC-SHA256 JWT cryptographic token engine
│   │   └── oauth_service.dart     # RFC 7636 OAuth 2.0 PKCE challenge & state engine
│   ├── services/
│   │   ├── firebase_service.dart  # Resilient Firebase initializer with offline fallback
│   │   ├── auth_service.dart      # Email, Google, OAuth PKCE, and Guest authentication
│   │   ├── firestore_service.dart # Cloud Firestore sync for projects and presets
│   │   ├── firebase_storage_service.dart # Optional photo backup service
│   │   ├── image_processing_service.dart # Color matrices, grain, vignette, and export
│   │   ├── storage_service.dart   # SharedPreferences local persistence
│   │   ├── permission_service.dart# Explanatory camera & photo permission prompts
│   │   └── ai_caption_service.dart# 10-tone aesthetic caption engine with offline quotes
│   └── utils/
│       └── haptic_feedback.dart   # Tactile shutter, dial, and tap feedback
│
├── data/
│   ├── models/
│   │   ├── filter_preset.dart     # 4x5 Color filter matrices and adjustment defaults
│   │   ├── photo_project.dart     # Non-destructive project model with undo/redo
│   │   ├── sticker_item.dart      # Interactive placed sticker model (drag/scale/rotate)
│   │   ├── frame_style.dart       # Polaroid, 35mm film, scrapbook, and date configs
│   │   ├── collage_layout.dart    # Multi-photo grid and dump layout models
│   │   └── mood_preset.dart       # Coordinated 1-tap aesthetic recipe definitions
│   └── repositories/
│       ├── filter_repository.dart # All 24 presets across 5 aesthetic categories
│       ├── sticker_repository.dart# 10 sticker packs (Bows, Hearts, Stars, etc.)
│       ├── mood_repository.dart   # 9 signature Mood-to-Photo recipes
│       └── sample_photos_data.dart# Curated high-res studio test assets
│
└── presentation/
    ├── navigation/
    │   └── main_navigation_screen.dart # 5-tab responsive navigation bar
    ├── screens/
    │   ├── home/
    │   │   └── home_screen.dart        # Featured collections, quick launch, inspo
    │   ├── camera/
    │   │   ├── camera_screen.dart      # Full-screen camera with real-time preview
    │   │   └── widgets/
    │   │       ├── digicam_hud.dart    # Retro LCD indicators, ISO, battery, date
    │   │       └── filter_carousel.dart# Horizontal filter carousel & intensity
    │   ├── discover/
    │   │   └── discover_screen.dart    # Curated aesthetic collections & favorites
    │   ├── studio/
    │   │   ├── studio_screen.dart      # 10-slider editor with undo/redo & export
    │   │   └── widgets/
    │   │       └── before_after_viewer.dart # Interactive split wipe comparison
    │   ├── stickers/
    │   │   └── sticker_studio_screen.dart # Interactive multi-touch canvas
    │   ├── frames/
    │   │   └── frames_datestamps_screen.dart # Polaroid, 35mm, and date stamp picker
    │   ├── collage/
    │   │   └── collage_maker_screen.dart # Multi-photo grids & background palettes
    │   ├── mood/
    │   │   └── mood_to_photo_screen.dart # 1-tap Mood-to-Photo recipe studio
    │   ├── captions/
    │   │   └── caption_generator_screen.dart # AI tone generator & copy clipboard
    │   ├── shots/
    │   │   └── my_shots_screen.dart    # Personal photo gallery & project manager
    │   └── auth/
    │       └── auth_sheet.dart         # Modal auth sheet with live JWT claims inspector
    └── widgets/
        ├── aesthetic_button.dart       # Glossy pill buttons & metallic shutter button
        ├── aesthetic_card.dart         # Rounded pastel container cards
        ├── retro_date_stamp_widget.dart# Stylized LCD digital date stamp
        └── sticker_painter.dart        # Draggable, rotatable, scalable sticker widget
```

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
