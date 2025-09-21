# set up a firebase project first

# go to terminal

# go to root directory of the project

# make sure you have the firebase cli installed

npm install -g firebase-tools

# then login

firebase login

# build the project

flutter build web --dart-define-from-file=.config/config.production.json


# init it

firebase init

  - when prompted select Hosting

  - choose an existing firebase project you've already set upin the console

  - for the public directory, enter build/web

  - select y when asked if you want to configure as a single-page app (spa)

  - when it asks to overwrite your index file, say no

# deploy your app

firebase deploy --only hosting





# to stop production from hosting the site

firebase hosting:disable

# to start production again

firebase deploy --only hosting