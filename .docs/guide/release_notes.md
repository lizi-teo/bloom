lizzieteo@Lizzies-MacBook-Pro bloom-app % firebase login
i  The Firebase CLI’s MCP server feature can optionally make use of Gemini in Firebase. Learn more about Gemini in Firebase and how it uses your data: https://firebase.google.com/docs/gemini-in-firebase#how-gemini-in-firebase-uses-your-data
✔ Enable Gemini in Firebase features? No

i  Firebase optionally collects CLI and Emulator Suite usage and error reporting information to help improve our products. Data is collected in accordance with Google's privacy policy (https://policies.google.com/privacy) and is not used to identify you.
✔ Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? No

Visit this URL on this device to log in:
https://accounts.google.com/o/oauth2/auth?client_id=563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com&scope=email%20openid%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloudplatformprojects.readonly%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffirebase%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform&response_type=code&state=65790074&redirect_uri=http%3A%2F%2Flocalhost%3A9005

Waiting for authentication...

✔  Success! Logged in as lizzie.tls@gmail.com
lizzieteo@Lizzies-MacBook-Pro bloom-app % firebase projects:list                            
✔ Preparing the list of your Firebase projects
┌──────────────────────┬─────────────┬────────────────┬──────────────────────┐
│ Project Display Name │ Project ID  │ Project Number │ Resource Location ID │
├──────────────────────┼─────────────┼────────────────┼──────────────────────┤
│ bloom                │ bloom-e0901 │ 285468716383   │ [Not specified]      │
└──────────────────────┴─────────────┴────────────────┴──────────────────────┘

1 project(s) total.
lizzieteo@Lizzies-MacBook-Pro bloom-app % flutter build web --dart-define-from-file=.config/config.production.json
Resolving dependencies... 
Downloading packages... 
  characters 1.4.0 (1.4.1 available)
  flutter_lints 5.0.0 (6.0.0 available)
  js 0.6.7 (0.7.2 available)
  lints 5.1.1 (6.0.0 available)
  material_color_utilities 0.11.1 (0.13.0 available)
  palette_generator 0.3.3+7 (discontinued)
Got dependencies!
1 package is discontinued.
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Wasm dry run succeeded. Consider building and testing your application with the `--wasm` flag. See docs for
more info: https://docs.flutter.dev/platform-integration/web/wasm
Use --no-wasm-dry-run to disable these warnings.
Font asset "CupertinoIcons.ttf" was tree-shaken, reducing it from 257628 to 1472 bytes (99.4% reduction).
Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 11576 bytes (99.3%
reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your
app.
Compiling lib/main.dart for the Web...                             14.1s
✓ Built build/web
lizzieteo@Lizzies-MacBook-Pro bloom-app % firebase init

     ######## #### ########  ######## ########     ###     ######  ########
     ##        ##  ##     ## ##       ##     ##  ##   ##  ##       ##
     ######    ##  ########  ######   ########  #########  ######  ######
     ##        ##  ##    ##  ##       ##     ## ##     ##       ## ##
     ##       #### ##     ## ######## ########  ##     ##  ######  ########

You're about to initialize a Firebase project in this directory:

  /Users/lizzieteo/Development/bloom-app

✔ Which Firebase features do you want to set up for this directory? Press Space to select features, then 
Enter to confirm your choices. Hosting: Configure files for Firebase Hosting and (optionally) set up GitHub
 Action deploys

=== Project Setup

First, let's associate this project directory with a Firebase project.
You can create multiple project aliases by running firebase use --add, 
but for now we'll just set up a default project.

✔ Please select an option: Use an existing project
✔ Select a default Firebase project for this directory: bloom-e0901 (bloom)
i  Using project bloom-e0901 (bloom)

=== Hosting Setup

Your public directory is the folder (relative to your project directory) that
will contain Hosting assets to be uploaded with firebase deploy. If you
have a build process for your assets, use your build's output directory.

✔ What do you want to use as your public directory? build/web
✔ Configure as a single-page app (rewrite all urls to /index.html)? Yes
✔ Set up automatic builds and deploys with GitHub? No
✔ File build/web/index.html already exists. Overwrite? No
i  Skipping write of build/web/index.html

✔  Wrote configuration info to firebase.json
✔  Wrote project information to .firebaserc

✔  Firebase initialization complete!
lizzieteo@Lizzies-MacBook-Pro bloom-app % firebase deploy --only hosting

=== Deploying to 'bloom-e0901'...

i  deploying hosting
i  hosting[bloom-e0901]: beginning deploy...
i  hosting[bloom-e0901]: found 33 files in build/web
✔  hosting[bloom-e0901]: file upload complete
i  hosting[bloom-e0901]: finalizing version...
✔  hosting[bloom-e0901]: version finalized
i  hosting[bloom-e0901]: releasing new version...
✔  hosting[bloom-e0901]: release complete

✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/bloom-e0901/overview
Hosting URL: https://bloom-e0901.web.app
lizzieteo@Lizzies-MacBook-Pro bloom-app % 
