function func_setenv()
{
    if [ "${rom_type}" == "cm" ]; then myrom="cm based rom"; MY_BUILD="$CM_BUILD";
    elif [ "${rom_type}" == "du" ]; then myrom="du based rom"; MY_BUILD="$DU_BUILD";
    elif [ "${rom_type}" == "omni" ]; then myrom="omni based rom"; MY_BUILD="$CUSTOM_BUILD"; 
    else echo -e "${CL_RED} * Error: rom_type not set [vendor/extra/config.sh]${CL_RST}\n"; fi
    unset rom_type
    if [ "${with_su}" == "1" ]; then myrom="$myrom+SU"; export WITH_SU="true"; else unset WITH_SU; fi
    unset with_su
    unset CCACHE_DIR
}

function patchcommontree()
{
    for f in `test -d vendor && find -L vendor/extra/patch/*/ -maxdepth 1 -name 'apply.sh' 2> /dev/null`
    do
        echo -e "${CL_YLW}\nPatching $f${CL_RST}"
        . $f
    done
    unset f
}

function patchdevicetree()
{
    for f in `test -d device && find -L device/*/$MY_BUILD/patch -maxdepth 4 -name 'apply.sh' 2> /dev/null | sort` \
             `test -d vendor && find -L vendor/extra/patch/device/$MY_BUILD -maxdepth 1 -name 'apply.sh' 2> /dev/null | sort`
    do
        echo -e "${CL_YLW}\nPatching $f${CL_RST}"
        . $f
    done
    unset f
}

function set_stuff_for_environment()
{
    settitle
    set_java_home
    setpaths
    set_sequence_number
    patchcommontree
    patchdevicetree

    # With this environment variable new GCC can apply colors to warnings/errors
    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    export ASAN_OPTIONS=detect_leaks=0
}

function func_ccache()
{
    rom_dir_full=`pwd`
    rom_dir=`basename $rom_dir_full`
    export CCACHE_DIR=$ccache_dir/$rom_dir
    c_dir=`ccache -s|grep directory|cut -d '/' -f1-10`
    c_size=`ccache -s|grep 'cache size'`
    c_current=`echo $c_size|cut -d ' ' -f3-4`
    c_max=`echo $c_size|cut -d ' ' -f8-9`
    ccache -M $ccache_size >/dev/null

    if [[ "${ccache_use}" == "" || "${ccache_use}" == "0" || "${ccache_use}" == "false" ]]; then echo -e "${CL_MAG} * Disabled ccache${CL_RST}"; export USE_CCACHE=0;
    elif [ "${ccache_dir}" == "" ]; then echo -e "${CL_RED} * Error: ccache_dir not set [vendor/extra/config.sh]${CL_RST}\n"; else export USE_CCACHE=1; echo -e "${CL_GRN} * Setup ccache : ${CL_LBL}$c_current${CL_RST} of ${CL_LBL}$c_max${CL_RST} used in ${CL_LBL}$CCACHE_DIR${CL_RST}"; fi
}

function func_java()
{
    MYPYT=`python --version 2&>/tmp/mypyt|cat /tmp/mypyt`
    export mypyt=`sed q /tmp/mypyt`
    MYJDK=`java -version 2&>/tmp/myjdk|cat /tmp/myjdk`
    export myjdk=`sed q /tmp/myjdk`
    export MY_ROM=$rom_dir
    export PATH="$jdk_dir:$PATH"

        echo -e "${CL_GRN} * Checking env : ${CL_LBL}$mypyt${CL_RST} | ${CL_LBL}$myjdk${CL_RST} | ${CL_LBL}$myrom${CL_RST}"
}

function func_colors()
{
    CL_RED="\033[31m"
    CL_GRN="\033[32m"
    CL_YLW="\033[33m"
    CL_BLU="\033[34m"
    CL_MAG="\033[35m"
    CL_CYN="\033[36m"
    CL_RST="\033[0m"
    CL_B="\e[1;38;5;33m"
    CL_LBL="\e[1;38;5;81m"
    CL_GY="\e[1;38;5;242m"
    CL_GRN="\e[1;38;5;82m"
    CL_P="\e[1;38;5;161m"
    CL_PP="\e[1;38;5;93m"
    CL_RED="\e[1;38;5;196m"
    CL_Y="\e[1;38;5;214m"
    CL_W="\e[0m"
}

function func_alias()
{	
	alias dn="echo $(sed "s/lineage_//" <<< "${TARGET_PRODUCT}")"
	#Update Tools
	#alias udt="repo sync -c -d --force-sync BAProductions/vendor_extra && . build/envsetup.sh && show_alias"
	#Repo Sync Command
	alias rs="repo sync -c -d --force-sync && . build/envsetup.sh && show_alias"
    alias arb="cd vendor/cm/ && git am --abort && cd ../.. && . build/envsetup.sh && show_alias"
    #Samsung Galaxy Tab 4 10.1 WiFi Old Tablet
    alias lmu="lunch lineage_matissewifi-user -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_alias"
    alias lmud="lunch lineage_matissewifi-userdebug -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_aliass"
    alias lmeng="lunch lineage_matissewifi-eng -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_alias"
    if [ $(sed 's/lineage_//' <<< "${TARGET_PRODUCT}") == "matissewifi" ]
		then 
		#Samsung Galaxy Tab 4 10.1 Extra Command
		alias mcl="mka camera.msm8226 -j$(expr $(nproc --all) \* 10) && adb remount && adb push out/target/product/matissewifi/system/lib/hw/camera.msm8226.so system/lib/hw/ && adb shell chmod 0644 system/lib/hw/camera.msm8226.so && adb reboot && adb wait-for-device logcat | grep --color=auto -E 'camera|preview|sr|selinux|not found|sepolicy|avc|policy|rev'";
		alias mcs="mka libmmcamera_sr130pc20_shim -j$(expr $(nproc --all) \* 10) && adb remount && adb push out/target/product/matissewifi/system/lib/libmmcamera_sr130pc20_shim.so system/lib/ && adb shell chmod 0644 system/lib/libmmcamera_sr130pc20_shim.so && adb reboot && adb wait-for-device logcat | grep --color=auto -E 'camera|preview|sr|selinux|not found|sepolicy|avc|policy|rev'";
	fi
	#Build
    alias mb="mka bacon -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    alias msi="mka systemimage -j$(expr $(nproc --all) \* 10) && mop adb wait-for-device reboot recovery"
    alias mbi="mka bootimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery shell rm -f sdcard/boot.img && adb wait-for-recovery push out/target/product/$(sed 's/lineage_//' <<< "${TARGET_PRODUCT}")/boot.img sdcard"
    alias mbic="mka bootimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery push out/target/product/$(sed 's/lineage_//' <<< "${TARGET_PRODUCT}")/boot.img sdcard && adb wait-for-device shell reboot -p"
    alias mk="mka kernel -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    alias mri="mka recoveryimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery push out/target/product/$(sed 's/lineage_//' <<< "${TARGET_PRODUCT}")/boot.img sdcard"
    alias mop="mka otapackage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    alias mop2="repo sync -c -d --force-sync && mka systemimage -j$(expr $(nproc --all) \* 10) && mka otapackage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    #Logcat Command
    alias tlc="adb wait-for-device logcat"
    alias tlcf=". build/envsetup.sh && show_alias && adb reboot && adb wait-for-device logcat|tee >> $home_dir/logcat-$(date +"%m-%d-%Y\ %T").log"
    alias tlcfe=". build/envsetup.sh && show_alias && adb reboot && adb wait-for-device logcat *:E|tee >> ~/$rom_dir/logcat-e-$(date +"%m-%d-%Y\ %T").log"
	#Kmesg Command
    alias rkm="adb wait-for-device shell cat /proc/kmsg"
    alias rkmf=". build/envsetup.sh && show_alias && adb wait-for-device shell cat /proc/kmsg | tee >> $home_dir/kmesg-$(date +"%m-%d-%Y\ %T").log"
    alias rfkmf=". build/envsetup.sh && show_alias && adb reboot && adb wait-for-device shell cat /proc/kmsg |tee >> $home_dir/kmesg-$(date +"%m-%d-%Y\ %T").log"
	#Dmesg Command
    alias rdm="adb wait-for-device shell dmesg"
    alias rdmf=". build/envsetup.sh && show_alias && adb wait-for-device shell dmsg | tee >> $home_dir/dmsg-$(date +"%m-%d-%Y\ %T").log"
    alias dw="adb shell 'su -c \"svc wifi disable\"'"
    alias ew="adb shell 'su -c \"svc wifi enable\"'"
    alias tss=". build/envsetup.sh && show_alias && adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png && mv $home_dir/screen.png $home_dir/screen-$(date +"%m-%d-%Y\ %T").png &&  adb shell rm -f /sdcard/.screen.png"
	#sepolicy Fix Command
    alias fsep="adb pull /sys/fs/selinux/policy $home_dir/ && adb logcat -b all -d | audit2allow -p policy"
}

function show_alias()
{
	#echo -e "\nUpdate Tools"
	#echo -e "${CL_LBL}\nudt${CL_RST}\trepo sync -c -d --force-sync BAProductions/vendor_extra && . build/envsetup.sh && show_alias"
	echo -e "\nRepo Sync Commend"
	echo -e "${CL_LBL}\nrs${CL_RST}\trepo sync -c -d --force-sync && . build/envsetup.sh && show_alias"
    echo -e "${CL_LBL}\narb${CL_RST}\tcd vendor/cm/ && git am --abort && cd ../.. && . build/envsetup.sh && show_alias"
    echo -e "\nSamsung Galaxy Tab 4 10.1 WiFi"
	echo -e "${CL_LBL}\nlmu${CL_RST}\tlunch lineage_matissewifi-user -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_alias"
    echo -e "${CL_LBL}\nlmud${CL_RST}\tlunch lineage_matissewifi-userdebug -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_alias"
    echo -e "${CL_LBL}\nlmeng${CL_RST}\tlunch lineage_matissewifi-eng -j$(expr $(nproc --all) \* 10) && . build/envsetup.sh && show_alias"
	if [ $(sed 's/lineage_//' <<< "${TARGET_PRODUCT}") == "matissewifi" ]
		then
		echo -e "\nSamsung Galaxy Tab 4 10.1 Extra Command"
		echo -e "${CL_LBL}\nmcl${CL_RST}\tmka camera.msm8226 -j$(expr $(nproc --all) \* 10) && adb remount && adb push out/target/product/matissewifi/system/lib/hw/camera.msm8226.so system/lib/hw/ && adb shell chmod 0644 system/lib/hw/camera.msm8226.so && adb reboot && adb wait-for-device logcat | grep --color=auto -E 'camera|preview|sr|selinux|not found|sepolicy|avc|policy|rev'";
		echo -e "${CL_LBL}\nmcs${CL_RST}\tmka libmmcamera_sr130pc20_shim -j$(expr $(nproc --all) \* 10) && adb remount && adb push out/target/product/matissewifi/system/lib/libmmcamera_sr130pc20_shim.so system/lib/ && adb shell chmod 0644 system/lib/libmmcamera_sr130pc20_shim.so && adb reboot && adb wait-for-device logcat | grep --color=auto -E 'camera|preview|sr|selinux|not found|sepolicy|avc|policy|rev'";
	fi
	echo -e "\nBuild Command"
    echo -e "${CL_LBL}\nmb${CL_RST}\tmka bacon -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    echo -e "${CL_LBL}\nmsi${CL_RST}\tmka systemimage -j$(expr $(nproc --all) \* 10) && mop && adb wait-for-device reboot recovery"
    echo -e "${CL_LBL}\nmbi${CL_RST}\tmka bootimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery shell rm -f sdcard/boot.img && adb wait-for-recovery push out/target/product/boot.img sdcard"
    echo -e "${CL_LBL}\nmbic${CL_RST}\tmka bootimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery push out/target/product//boot.img sdcard && adb wait-for-device shell reboot -p"
    echo -e "${CL_LBL}\nmk${CL_RST}\tmka kernel -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery"
    echo -e "${CL_LBL}\nmri${CL_RST}\tmka recoveryimage -j$(expr $(nproc --all) \* 10) && adb wait-for-device reboot recovery && adb wait-for-recovery push out/target/product//recovery.img sdcard"
    echo -e "${CL_LBL}\nmop${CL_RST}\tmka otapackage -j$(expr $(nproc --all) \* 10) && mop && adb wait-for-device reboot recovery"
    echo -e "\nLogcat Command"
    echo -e "${CL_LBL}\ntlc${CL_RST}\tadb wait-for-device logcat"
    echo -e "${CL_LBL}\ntlcf${CL_RST}\t. build/envsetup.sh && show_alias && adb reboot && adb wait-for-device logcat | tee >> $home_dir/logcat-$(date +"%m-%d-%Y\ %T").log"
    echo -e "${CL_LBL}\ntlcfe${CL_RST}\t. build/envsetup.sh && show_alias && adb reboot && adb wait-for-device logcat *:E | tee >> $home_dir/logcat-e-$(date +"%m-%d-%Y\ %T").log"
    echo -e "\nKmsg Command"
    echo -e "${CL_LBL}\nrkm${CL_RST}\tadb wait-for-device shell cat /proc/kmsg"
    echo -e "${CL_LBL}\nrkmf${CL_RST}\t. build/envsetup.sh && show_alias && adb wait-for-device shell cat /proc/kmsg | tee >> $home_dir/kmesg-$(date +"%m-%d-%Y\ %T").log"
    echo -e "${CL_LBL}\nrfkmf${CL_RST}\t. build/envsetup.sh && show_alias && adb reboot && adb wait-for-device shell cat /proc/kmsg |tee >> ~/$rom_dir/kmesg-$(date +"%m-%d-%Y\ %T").log"
    echo -e "\nDmesg Command"
    echo -e "${CL_LBL}\nrdm${CL_RST}\tadb wait-for-device shell dmesg"
    echo -e "${CL_LBL}\nrdmf${CL_RST}\t. build/envsetup.sh && show_alias && adb wait-for-device shell dmesg | tee >> $home_dir/dmesg-$(date +"%m-%d-%Y\ %T").log"
    echo -e "\nWiFi Command"
    echo -e "${CL_LBL}\ndw${CL_RST}\tadb shell 'su -c "\"svc wifi disable"\"'"
    echo -e "${CL_LBL}\new${CL_RST}\tadb shell 'su -c "\"svc wifi enable"\"'"
	echo -e "\nOther Command"
    echo -e "${CL_LBL}\ntss${CL_RST}\t. build/envsetup.sh && show_alias && adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png && mv $home_dir/screen.png $home_dir/screen-$(date +"%m-%d-%Y\ %T").png &&  adb shell rm -f /sdcard/.screen.png"
    echo -e "${CL_LBL}\nfsep${CL_RST}\tadb pull /sys/fs/selinux/policy && adb logcat -b all -d | audit2allow -p policy"
    echo -e "${CL_LBL}\n${CL_RST}"
}
