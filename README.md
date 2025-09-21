# Bloom App

A Flutter application for session feedback and sentiment analysis.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart
- A Supabase project
- Giphy API key (optional, for animated feedback)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd bloom-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Copy the template configuration files and update them with your actual values:
   ```bash
   cp .config/config.development.template.json .config/config.development.json
   cp .config/config.production.template.json .config/config.production.json
   ```

   Update the following values in your config files:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key
   - `GIPHY_API_KEY`: Your Giphy API key (get one at https://developers.giphy.com/)
   - `APP_BASE_URL`: Your app's base URL (for production)
   - `DEV_AUTO_LOGIN_EMAIL` & `DEV_AUTO_LOGIN_PASSWORD`: For development auto-login (development only)

4. **Run the application**
   ```bash
   # Development mode (Chrome)
   flutter run -d chrome --dart-define-from-file=.config/config.development.json

   # Production mode
   flutter run -d chrome --dart-define-from-file=.config/config.production.json
   ```

### API Keys Setup

**Supabase Setup:**
1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings → API
3. Set up your database schema as needed

**Giphy API Setup:**
1. Register at [developers.giphy.com](https://developers.giphy.com/)
2. Create a new app to get your API key
3. Add the key to your config files

### Development

The app uses Flutter web and can be run in Chrome for development. Configuration files contain environment-specific settings and should not be committed to version control.
