MGRS
====

MGRS is a mobile application for converting MGRS (Military Grid
Reference System) to lat&lon geographic coordinates. It is based on
the Geotrans library available at http://earth-info.nga.mil/GandG/geotrans/

There are 2 versions of the application:

Legacy
------

This remains the recommended version (for now).

Apple iOS application. To use, open the "MGRS.xcodeproj" project
in X-Code.

Cordova
-------

NOTICE: For iOS, the legacy version remains recommended for now.
The Cordova version has not been extensively tested yet and the
auto-generated project may be missing some settings which are
important.

Uses Apache Cordova to automatically build a multi-platform mobile
application from pure HTML & JavaScript source.

To use for Android:

 1. Run "make android"
 2. Install "platforms/android/build/outputs/apk/android-debug.apk"

To use for iOS:

 1. Run "make ios"
 2. Open the "platforms/ios/MGRS.xcodeproj* project in X-Code

Other Makefile targets:

 * all (default target): autodetect which platform(s) to build and do it.
 * test
 * clean
