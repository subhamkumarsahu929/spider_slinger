# Spiderman: Web Slinger 🕸️

**Spiderman: Web Slinger** is a fast-paced, 2D procedural side-scrolling platformer where you take control of Spider-Man. Traverse a dynamically generated world, swing from ceilings, shoot web projectiles, dodge spikes, and defeat waves of enemies, culminating in an intense boss fight against Venom!

This project was built to be played on mobile devices with a live, real-time sync to a dedicated web-hosted Leaderboard Screen optimized for large auditorium projectors.

---

## 🌟 Features
- **Procedural Level Generation**: Platforms, enemies, and spike hazards spawn infinitely and procedurally as the camera seamlessly follows the player.
- **Advanced Physics & Traversal**: Run, jump, and hang upside down from ceilings using vertical web-anchors. Chain a drop into a massive momentum-based horizontal swing to cross massive gaps!
- **Dynamic Combat System**: Shoot horizontal web projectiles to take down hovering flies and crawler enemies. Face off against the multi-phase Venom Boss once you survive long enough!
- **Auditorium Projector Leaderboard**: A dedicated web route (`/#/leaderboard`) optimized for a 1080p projector, displaying a live-updating scoreboard of student runs sorted by their best score.
- **Student Registration System**: On the first launch, the app prompts players for their Name and Roll Number and persists it locally via `SharedPreferences`.

---

## 🎮 How to Play

### Controls
The game is played in Landscape mode.
- **Left / Right Buttons**: Press and hold to run across the platforms.
- **Green Button (Jump)**: Tap to jump over gaps and spikes.
- **Red Button (Attack)**: Tap to shoot a horizontal web projectile.
- **Blue Button (Ceiling Attach)**: Tap **while in mid-air** to shoot a vertical web and hang upside down from the ceiling.
- **Purple Button (Swing)**: 
  - Tap while hanging to drop and swing forward a short distance.
  - **Momentum Swing**: Hold the Right Arrow and tap Swing while hanging to launch forward in a massive arc!

### Mechanics
- **Health**: You have 3 Hearts. Falling off the map or hitting spikes/enemies loses a heart.
- **Scoring**: Defeat enemies, survive longer, and deal damage to Venom to rack up a high score!

---

## 🛠 Tech Stack Used
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Game Engine**: [Flame Engine](https://flame-engine.org/) v1.9.0
- **Database / Auth**: [Firebase](https://firebase.google.com/) (Firestore & Anonymous Authentication)
- **Local Storage**: `shared_preferences`
- **Audio**: `audioplayers` for SFX and music
- **Platform Targets**: Android (APK) and Web (HTML/JS)

---

## 🚀 How to Clone and Run the Game Locally

1. **Clone the Repository**
   ```bash
   git clone <your-repo-url>
   cd spider_slinger
   ```
2. **Install Dependencies**
   ```bash
   flutter pub get
   ```
3. **Run on a Device or Emulator**
   *(Ensure you have an Android device connected or an emulator running in landscape mode)*
   ```bash
   flutter run
   ```

---

## 📦 How to Build the Release APK

To generate a production-ready APK to distribute to players for testing on their Android devices, run:

```bash
flutter build apk --release
```
Once the build completes successfully, you will find the generated universal APK at:
`build/app/outputs/flutter-apk/app-release.apk`

*Note: This APK includes the required `INTERNET` permissions to automatically sync scores with Firebase.*

---

## 🖥️ How to Set Up the Web Server (Live Leaderboard)

To display the live leaderboard in an auditorium, you must build the Web version of the app and host it on a local network.

1. **Compile the Web Build**
   ```bash
   flutter build web
   ```
2. **Serve the Application**
   Navigate into the web build directory and start a local HTTP server. (If you have Python installed, you can use the following command):
   ```bash
   cd build/web
   python3 -m http.server 8000
   ```
3. **Open the Projector UI**
   - Open **Google Chrome** on the laptop connected to the projector.
   - Navigate to `http://localhost:8000/#/leaderboard`.
   - Press **F11** to enter full-screen mode!

As players play the game on their phones and log scores, this projector screen will dynamically update in real-time without needing a page refresh.
