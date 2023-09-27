#!/bin/bash

if [ "$1" == "ios" ]; then
  flutter build ipa --release --export-method ad-hoc
else
  flutter build apk --release
fi


