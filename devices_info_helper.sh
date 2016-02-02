#!/bin/bash

debugMessage "hi! device helper imported";

## [ro.build.version.sdk]: [21]
function devices_info_helper_getVersionSdk() {
    adb shell getprop "ro.build.version.sdk";
}

## [ro.build.version.incremental]: [WW_Z00U-WW_userdebug_1.15.40.740_20151125-userdebug-20151125]
function devices_info_helper_getVersionIncremental() {
    adb shell getprop "ro.build.version.incremental";
}

## [ro.build.product]: [Z00T]
function devices_info_helper_getBuildProduct() {
    adb shell getprop "ro.build.product";
}

## [ro.build.fingerprint]: [asus/WW_Z00U/ASUS_Z00U_1:5.0.2/LRX22G/WW_debug_1.15.40.740_20151125:debug/test-keys]
function devices_info_helper_getBuildFingerPrint() {
    adb shell getprop "ro.build.fingerprint";
}

## [ro.build.csc.version]: [WW_ZD551KL_1.15.40.740-20151125]
function devices_info_helper_getBuildCscVersion() {
    adb shell getprop "ro.build.csc.version";
}

## [ro.build.characteristics]: [phone]
function devices_info_helper_getBuildCharacteristics() {
    adb shell getprop "ro.build.characteristics";
}

## [ro.build.asus.sku]: [WW]
function devices_info_helper_getBuildSku() {
    adb shell getprop "ro.build.asus.sku";
}

function devices_info_helper_getDeviceId() {
    adb devices | grep "device" | grep -v "devices" | head -1 | sed 's/device//g' | sed 's/\r//g;s/[ \t]*$//;s/\t/    /g'
}