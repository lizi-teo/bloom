# Font Setup Instructions

## Required Font: Questrial

This app uses **Questrial** as the brand font for display, headline, and title text styles to match the Figma design system.

### Download Instructions

1. **Download Questrial Font**
   - Visit: https://fonts.google.com/specimen/Questrial
   - Click the "Download family" button
   - Extract the ZIP file

2. **Add to Project**
   - Copy `Questrial-Regular.ttf` from the extracted files
   - Place it in this `fonts/` directory

3. **Verify Setup**
   ```bash
   flutter pub get
   flutter run
   ```

### Font Structure

```
fonts/
├── README.md (this file)
├── LICENSE.txt (font license)
└── Questrial-Regular.ttf (font file - you need to add this)
```

### Typography System

The app uses a two-font system:
- **Questrial**: Brand font for larger text (Display, Headline, Title)
- **Roboto**: System font for body text and UI elements (Body, Label)

### License

Questrial is licensed under the SIL Open Font License (OFL), which allows:
- ✅ Free use in commercial projects
- ✅ Bundling with applications
- ✅ Modification and redistribution

### Troubleshooting

If the font doesn't appear:
1. Ensure `Questrial-Regular.ttf` is in the `fonts/` directory
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart your app completely

### Fallback Behavior

If Questrial is not properly loaded, the app will fall back to system fonts:
- iOS: San Francisco
- Android: Roboto
- Web: System sans-serif

However, this will break the design consistency, so ensure the font is properly installed.