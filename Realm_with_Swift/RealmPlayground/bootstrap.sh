#! /bin/bash

## Written by Shai Mishali (c) RayWenderlich.com Jan 3rd, 2018
##
## This script installs all needed dependencies and prebuilds the project
## so the playground loads as quickly as possible when the project is opened.

## Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

## Some helper methods
fatalError() {
    echo -e "${RED}(!!) $1${NC}"
    exit 1
}

info() {
    echo -e "${GREEN}▶ $1${NC}"
}

loader() {
    printf "${BLUE}"
    while kill -0 $1 2>/dev/null; do
        printf  "▓"
        sleep 1
    done
    printf "${NC}\n"
}

## Make sure we have everything needed
if ! gem spec cocoapods > /dev/null 2>&1; then
    fatalError "Cocoapods is not installed"
fi

if ! xcodebuild -usage > /dev/null 2>&1; then
    fatalError "Xcode is not installed"
fi

## Reset everything
pod deintegrate --silent
rm -rf RealmPlayground.xcworkspace
clear

# Print out RW logo
echo -e $GREEN
cat << "EOF"
▓▓▓▓▓▓▓▓▓▓▄▄                           
▓▓▓▓▓▓▓▓▓▓▓▓▓██▄▄                       
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌                      
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌                     ▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    ▄▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀                    ▄▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▀                     ▄▓▓▓▓
▓▓▓▓▓▓▓▓▓█▀                       ▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▌                      ▄▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▌         ▓          ▄▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▌      ▄▓▓▓▄       ▄▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▄    ▓▓▓▓▓▓▓     ▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▄  ▓▓▓▓▓▓▓▓▓  ▄▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄▓▓▓▓▓▓▓▓▓▓▓▄▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
EOF
echo -e $NC

info "🧠  Installing dependencies ..."
pod install --silent & PODSPID=$!

loader $PODSPID

info "🚧  Building ..."
xcodebuild build -scheme RealmPlayground -workspace RealmPlayground.xcworkspace -sdk iphonesimulator -destination "name=iPhone 8" > build.log & BUILDPID=$!

loader $BUILDPID

info "🎁  Wrapping up ..."

cat >RealmPlayground.xcworkspace/contents.xcworkspacedata <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:RealmPlayground/Playground.playground">
   </FileRef>
   <FileRef
      location = "group:Pods/Pods.xcodeproj">
   </FileRef>
</Workspace>
EOF

info "🎉  Let's get started!"
open RealmPlayground.xcworkspace

