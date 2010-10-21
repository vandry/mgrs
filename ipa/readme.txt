Step 1
------
Using XCode perform a Release build for iPhone 3.1.3 Base SDK of the MGRS application

Step 2
------
Copy MGRS.app to the Payload folder and update the permissions as follows:

cp -pR ../build/Release-iphoneos/MGRS.app ./workspace/Payload/
chmod 775 ./workspace/Payload

Step 3
------
From command prompt, execute the following line to convert the Info.plist file:
plutil -convert xml1 ./workspace/Payload/MGRS.app/Info.plist

Step 4
------
Modify ./workspace/Payload/MGRS.app/Info.plist and add the following keys:

<key>UIPrerenderedIcon</key>
<true/>
<key>SignerIdentity</key>
<string>Apple iPhone OS Application Signing</string>

Step 5
------
Compress the contents of the workspace folder using ZIP compression
Rename zip file to MGRS.ipa

Step 6
------
Double click on MGRS.ipa to add to iTunes
