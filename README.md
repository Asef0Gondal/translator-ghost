# 👻 TranslatorGhost (Live Screen Translator V6 Omega)

An elegant, native macOS screen capture and real-time translation HUD designed for playing Japanese/Chinese indie games with zero performance impact.

---

## ✨ Outstanding Features

- **👾 Ghost Mode (Click-Through)**: Lock the selection frame to make it completely invisible to mouse clicks. You can click your game buttons, navigate, and play right through the overlay!
- **⚡️ Rapid Vision OCR**: Powered by Apple's native Vision framework to instantly extract Japanese/Chinese characters with accurate layout mapping.
- **🌎 Dual-Engine Translation**: High-speed, zero-dependency translation using local Apple Translation models with automatic Google API cURL fallback for reliable English dialogue.
- **🛡️ Sequoia TCC Safety Switch**: Resolves macOS Sequoia's screen capture loop. If permissions are restricted, the scanner cleanly pauses and presents a single manual resumption trigger.
- **💎 Dark Glassmorphic HUD**: Floating translation overlays designed using pure Apple system materials (`.hudWindow` glassmorphic backings) to match premium macOS aesthetics.

---

## 🛠️ Build & Installation

To compile `TranslatorGhost` and install it natively into your macOS Applications folder:

1. Open your terminal in this repository.
2. Grant execute permission and run the build script:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```
3. Launch the application from your Applications folder:
   ```bash
   open /Applications/TranslatorGhost.app
   ```

---

## 🎮 How to Play

1. **Resize the Frame**: Drag and resize the Selection Box overlay to frame the dialogue region of your game.
2. **Lock Ghost Mode**: Click the **Lock icon** in the HUD to enable click-through. The border will turn cyan and dashed.
3. **Toggle Raw/Translation**: Click the **Bubble icon** to instantly switch between the translated English text and the raw Japanese OCR.
4. **Safety Reset**: If permission prompts arise, toggle the app's Screen Recording privilege OFF and back ON in macOS System Settings.
