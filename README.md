# zoom_android_issue

Zoom video SDK android crush

## Getting Started

run flutter pub get to install packages
in zoom_config.dart add ZOOM_SDK_KEY ZOOM_SDK_SECRET values
run project as usual

## Issue
To get a crush on Android go to UserGridItem widget and uncomment part which has TODO 

## Build an apk
There is a build script in the root project folder, so you can use it to build apk or ipa files

run ./build_script.sh android - to create APK

run ./build_script.sh ios - to create IPA

