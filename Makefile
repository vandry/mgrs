APP_NAME=MGRS
CONTENTS=www/mgrs.js www/mgrs.html
CORDOVA_TARGETS=platforms

.PHONY: all android ios test clean

ALL=
ifeq ($(shell which xcodebuild),)
else
	ALL+=ios
endif

ifeq ($(shell which android),)
else
	ALL+=android
endif

all: $(ALL)

www/mgrs.html: mgrs.html .git/refs/heads
	set -e;version=$$(git describe --dirty);sed -e '/<div id="versionquery">/s%$$%<a href="javascript:showversion('\'$$version\'');">?</a>%' <mgrs.html >$@

android: platforms/android/build/outputs/apk/android-debug.apk

ios: platforms/ios/build/$(APP_NAME).app

platforms/android/build/outputs/apk/android-debug.apk: $(CONTENTS)
	mkdir -p $(CORDOVA_TARGETS)
	cordova platform add android
	cordova build android

platforms/ios/build/$(APP_NAME).app: $(CONTENTS)
	mkdir -p $(CORDOVA_TARGETS)
	cordova platform add ios
	cordova build ios

test: runtests www/mgrs.js
	./runtests

clean:
	rm -rf $(CORDOVA_TARGETS) www/mgrs.html res
