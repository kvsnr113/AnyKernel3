# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

properties() { '
kernel.string=E404 Kernel by Project 113
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=munch
device.name2=munchin
supported.versions=
'; }

is_apollo=0;
is_munch=1;
is_alioth=0;

block=/dev/block/bootdevice/by-name/boot;
ramdisk_compression=auto;

if [ $is_apollo == "1" ]; then
  is_slot_device=0;
elif [ $is_munch == "1" ]; then
  is_slot_device=1;
elif [ $is_alioth == "1" ]; then
  is_slot_device=1;
fi;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;

ui_print " ";

case "$ZIPFILE" in
  *miui*|*MIUI*)
    ui_print "MIUI/HyperOS DTBO variant detected. ";
    ui_print "Using MIUI/HyperOS DTBO... ";
    mv *miuidtbo.img $home/dtbo.img
    rm *aospdtbo.img
    ;;
  *aosp*|*AOSP*)
    ui_print "Normal DTBO variant detected.";
    ui_print "Using Normal DTBO... ";
    mv *aospdtbo.img $home/dtbo.img
    rm *miuidtbo.img
    ;;
  *)
    ui_print "Normal DTBO variant detected.";
    ui_print "Using Normal DTBO... ";
    mv *aospdtbo.img $home/dtbo.img
    rm *miuidtbo.img
    ;;
esac
ui_print " ";

case "$ZIPFILE" in
  *noksu*|*NOKSU*)
    ui_print "Non-KernelSU variant detected.";
    if [[ -d /data/adb/magisk ]]; then
      ui_print "Magisk Detected, Cleaning up KernelSU leftovers...";
      rm -rf /data/adb/ksu
      ui_print "Uninstalling KernelSU App (if exist)...";
      pm uninstall me.weishu.kernelsu
    fi
    ;;
  *ksu*|*KSU*)
    ui_print "KernelSU variant detected.";
    if [[ -d /data/adb/magisk ]]; then
      ui_print "Magisk Detected, please uninstall Magisk for KSU to work properly !";
    fi
    ;;
  *)
    ui_print "Non-KernelSU variant detected.";
    if [[ -d /data/adb/magisk ]]; then
      ui_print "Magisk Detected, Cleaning up KernelSU leftovers...";
      rm -rf /data/adb/ksu
      ui_print "Uninstalling KernelSU App (if exist)...";
      pm uninstall me.weishu.kernelsu
    fi
esac
ui_print " ";

case "$ZIPFILE" in
  *effcpu*|*EFFCPU*)
    ui_print "Efficient CPUFreq variant detected.";
    ui_print "Using Efficient CPUFreq DTB...";
    mv effcpu-dtb $home/dtb
    rm normal-dtb
    ;;
  *)
    ui_print "Normal CPUFreq variant detected.";
    ui_print "Using Normal CPUFreq DTB...";
    mv normal-dtb $home/dtb
    rm effcpu-dtb
    ;;
esac

## AnyKernel install
dump_boot;

# Begin Ramdisk Changes

# migrate from /overlay to /overlay.d to enable SAR Magisk
if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

write_boot;
## end install

if [ $is_apollo == "0" ]; then 
  ## vendor_boot shell variables
  block=/dev/block/bootdevice/by-name/vendor_boot;
  is_slot_device=1;
  ramdisk_compression=auto;
  patch_vbmeta_flag=auto;

  # reset for vendor_boot patching
  reset_ak;

  # vendor_boot install
  dump_boot;

  write_boot;
  ## end vendor_boot install
fi;