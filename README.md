vendor_extra
----------------

Contains patches &amp; useful command for pulling logs dmesg & kmsg, Making a full build, making bootimage, systemimage, recoveryimage & kernel plus taking screenshot& fixing sepolicy error.
| Commend |  Discriptoon|
|--|--|
| rs | Trigger sync repo |
| lmu | Trigger lunch lineage_matissewifi-user and patches source |
| lmud | Trigger lunch lineage_matissewifi-userubug and patches source |
| lmeng | Trigger lunch lineage_matissewifi-eng and patches source |
| mcl | Makes camera wrapper and pushes it to the device with correct the  permisston |
| mb | Make flashable zip |
| msi | build new system image & flashable zip |
| mbi | build new bootimage|
| mri | build new recoveryimage|
| mk | build new kernel|
| mop | Make flashable OTA zip|
| tlc | Displays logcat|
| tlcf | Reboot the device & writes locgat output to a .log file with timestamp from boot |
| rkmsg | Displays kmsg|
| rkmsgf | Reboot the device & writes kmsg output to a .log file with timestamp from boot|
| rdmesg | Displays dmesg|
| rdmesgf | Reboot the device & writes dmesg output to a .log file with timestamp from boot |
| dw | Disable WiFi(run if device reboot after connecting to Wifi network)|
| ew | Enable WiFi |
| rdmesgf | Reboot the device & writes dmesg output to a .log file with timestamp from boot |
| tss | Allow you to take screenshots fo the os with timestamp |
| fsep | Useful fo fixing sepolicy denials |
 
Most of the file have been taking form [sub77](https://github.com/sub77/)  & rewitten for are needs
