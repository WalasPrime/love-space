del love-space.love
7z a -tzip love-space.love *.lua
adb push love-space.love /mnt/sdcard/Download/love-space.love
adb shell am start -a android.intent.action.VIEW -t application/x-love-game -d file:////mnt/sdcard/Download/love-space.love