#!/usr/bin/env bash

# Color Configuration
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${CYAN}====================================================================${NC}"
echo -e "${WHITE}    📱 UNIFIED SCRIPT: FOSS STORES & DEBLOAT - SAMSUNG S22 📱  ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo -e "This script will install F-Droid and Aurora Store,"
echo -e "apply restrictions to Knox, and clean bloatware based"
echo -e "on your unified list (unified_debloat_list.txt)."
echo -e "${CYAN}====================================================================${NC}"
echo

# ==========================================
# STEP 1: VERIFY ADB CONNECTION
# ==========================================
echo -e "${BLUE}[STEP 1] Verifying ADB connection...${NC}"
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB is not installed on this system.${NC}"
    exit 1
fi

while true; do
    devices=($(adb devices | grep -v "List" | grep "device$" | cut -f1))
    if [ ${#devices[@]} -eq 0 ]; then
        echo -e "${YELLOW}No device detected via ADB.${NC}"
        read -p "Connect your phone and press [Enter] to retry..."
    else
        selected_device=${devices[0]}
        echo -e "${GREEN}Device detected successfully: $selected_device${NC}"
        break
    fi
done
echo

# ==========================================
# STEP 2: INSTALL F-DROID AND AURORA STORE
# ==========================================
echo -e "${BLUE}[STEP 2] Installing FOSS Stores (F-Droid and Aurora Store)...${NC}"
read -p "Do you want to download and install F-Droid and Aurora Store? (y/n): " inst_stores
if [[ "$inst_stores" =~ ^[Yy]$ ]]; then
    
    # 1. Install F-Droid
    echo -e "${WHITE}Downloading F-Droid...${NC}"
    curl -sL -o /tmp/FDroid.apk "https://f-droid.org/F-Droid.apk"
    echo -e "Installing F-Droid on your S22..."
    adb install -r /tmp/FDroid.apk 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] F-Droid installed successfully.${NC}"
    else
        echo -e "${RED}[FAILED] Could not install F-Droid.${NC}"
    fi

    # 2. Install Aurora Store
    echo -e "${WHITE}Fetching the latest release link for Aurora Store...${NC}"
    aurora_url=$(python3 -c "
import urllib.request, re
try:
    url = 'https://f-droid.org/en/packages/com.aurora.store/'
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req).read().decode('utf-8')
    match = re.search(r'href=\"(https://f-droid.org/repo/com\.aurora\.store_[^\"]+\.apk)\"', html)
    if match: print(match.group(1))
except Exception:
    pass
")
    
    if [ -n "$aurora_url" ]; then
        echo -e "Downloading Aurora Store from F-Droid..."
        curl -sL -o /tmp/AuroraStore.apk "$aurora_url"
        echo -e "Installing Aurora Store..."
        adb install -r /tmp/AuroraStore.apk 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[SUCCESS] Aurora Store installed successfully.${NC}"
        else
            echo -e "${RED}[FAILED] Error installing Aurora Store.${NC}"
        fi
    else
        echo -e "${RED}Error fetching the Aurora Store download URL.${NC}"
    fi

else
    echo -e "${YELLOW}Step skipped by user.${NC}"
fi
echo

# ==========================================
# STEP 3: FOSS APPS INSTALLER (OPTIONAL)
# ==========================================
echo -e "${BLUE}[STEP 3] FOSS Applications Installation Menu${NC}"
echo "Choose which free, non-tracking applications you want to install."
echo "Type the numbers separated by space (e.g., 1 3 5), or type 'a' to install ALL."
echo "  1) Fossify Gallery"
echo "  2) Fossify Messages"
echo "  3) Fossify Calendar"
echo "  4) Fossify Clock"
echo "  5) Fossify Contacts"
echo "  6) Fossify Phone"
echo "  7) Lawnchair (Modern Private Launcher)"
echo "  8) FUTO Keyboard (Offline Keyboard without telemetry)"
echo "  s) Skip this step"

read -p "Your choice: " app_choices

if [[ "$app_choices" != "s" && "$app_choices" != "S" ]]; then
    declare -A app_repos=(
        [1]="FossifyOrg/Gallery"
        [2]="FossifyOrg/Messages"
        [3]="FossifyOrg/Calendar"
        [4]="FossifyOrg/Clock"
        [5]="FossifyOrg/Contacts"
        [6]="FossifyOrg/Phone"
    )
    
    install_list=()
    if [[ "$app_choices" == "a" || "$app_choices" == "A" ]]; then
        install_list=(1 2 3 4 5 6 7 8)
    else
        for choice in $app_choices; do
            install_list+=($choice)
        done
    fi
    
    for opt in "${install_list[@]}"; do
        if [[ "$opt" -ge 1 && "$opt" -le 6 ]]; then
            repo="${app_repos[$opt]}"
            echo -e "Downloading ${WHITE}$repo${NC}..."
            url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -E "browser_download_url.*\.apk" | head -n 1 | cut -d '"' -f 4)
            curl -sL -o /tmp/foss.apk "$url"
            echo -e "Installing..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Installed${NC}"
        elif [[ "$opt" == "7" ]]; then
            echo -e "Downloading ${WHITE}Lawnchair${NC}..."
            url=$(curl -s "https://api.github.com/repos/LawnchairLauncher/lawnchair/releases" | grep -E "browser_download_url.*\.apk" | head -n 1 | cut -d '"' -f 4)
            curl -sL -o /tmp/foss.apk "$url"
            echo -e "Installing..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Installed${NC}"
        elif [[ "$opt" == "8" ]]; then
            echo -e "Downloading ${WHITE}FUTO Keyboard${NC}..."
            curl -sL -o /tmp/foss.apk "https://keyboard.futo.org/nightly.apk"
            echo -e "Installing..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Installed${NC}"
        fi
    done
else
    echo -e "${YELLOW}FOSS installation skipped.${NC}"
fi
echo

# ==========================================
# STEP 4: BACKGROUND RESTRICTIONS
# ==========================================
echo -e "${BLUE}[STEP 4] Restrictions (Knox / System)...${NC}"
read -p "Do you want to apply background restrictions? (y/n): " run_appops
if [[ "$run_appops" =~ ^[Yy]$ ]]; then
    restringidos=(
        "co.sitic.pp"
        "com.sec.enterprise.knox.cloudmdm.smdms"
        "com.knox.vpn.proxyhandler"
    )
    for pkg in "${restringidos[@]}"; do
        echo -e "Applying RUN_IN_BACKGROUND block to: ${YELLOW}$pkg${NC}..."
        adb shell cmd appops set "$pkg" RUN_IN_BACKGROUND ignore &>/dev/null
        adb shell pm suspend "$pkg" &>/dev/null
        echo -e "${GREEN}[DONE]${NC}"
    done
else
    echo -e "${YELLOW}Skipped.${NC}"
fi
echo

# ==========================================
# STEP 5: DEBLOAT WITH UNIFIED LIST
# ==========================================
echo -e "${BLUE}[STEP 5] Bloatware Uninstallation (Unified List)${NC}"
unified_list="unified_debloat_list.txt"

if [ ! -f "$unified_list" ]; then
    echo -e "${RED}Error: The file $unified_list is not in the current directory.${NC}"
    exit 1
fi

total_apps=$(wc -l < "$unified_list")
echo -e "Detected ${GREEN}$total_apps${NC} applications ready to be removed."
read -p "Start massive uninstallation? (y/n): " confirm_uninst
if [[ "$confirm_uninst" =~ ^[Yy]$ ]]; then
    success_count=0
    fail_count=0
    
    mapfile -t packages < "$unified_list"
    for pkg in "${packages[@]}"; do
        [ -z "$pkg" ] && continue
        echo -e "Removing: ${WHITE}$pkg${NC}..."
        output=$(adb shell pm uninstall -k --user 0 "$pkg" </dev/null 2>&1)
        if echo "$output" | grep -q "Success"; then
            echo -e "${GREEN}  ✓ Success${NC}"
            ((success_count++))
        else
            echo -e "${RED}  ✗ Skipped/Failed${NC}"
            ((fail_count++))
        fi
    done
    
    echo -e "${CYAN}====================================================================${NC}"
    echo -e "${GREEN}Debloat Summary:${NC}"
    echo -e "  Removed: ${GREEN}$success_count${NC} | Failed/Non-existent: ${RED}$fail_count${NC}"
    echo -e "${CYAN}====================================================================${NC}"
else
    echo -e "${YELLOW}Skipped.${NC}"
fi
echo

# ==========================================
# STEP 6: CONFIGURE PRIVATE DNS (MULLVAD)
# ==========================================
echo -e "${BLUE}[STEP 6] Private DNS Configuration (Anti-Tracker Shield)${NC}"
read -p "Do you want to enable Mullvad DNS (highly compatible and private) network-wide? (y/n): " run_dns
if [[ "$run_dns" =~ ^[Yy]$ ]]; then
    adb shell settings put global private_dns_mode hostname
    adb shell settings put global private_dns_specifier adblock.doh.mullvad.net
    echo -e "${GREEN}  ✓ Private DNS enabled (adblock.doh.mullvad.net)${NC}"
else
    echo -e "${YELLOW}Skipped.${NC}"
fi
echo

# ==========================================
# STEP 7: SYSTEM OPTIMIZATION AND DEEP PRIVACY
# ==========================================
echo -e "${BLUE}[STEP 7] Speed up phone and disable hidden telemetry${NC}"
echo "1. Disables hidden WiFi/Bluetooth scanning."
echo "2. Blocks Google crash/usage telemetry."
echo "3. Speeds up animations to 2x (0.5x scale)."
read -p "Apply these performance and privacy improvements? (y/n): " run_opt
if [[ "$run_opt" =~ ^[Yy]$ ]]; then
    # Privacy: Disable constant scanning
    adb shell settings put global wifi_scan_always_enabled 0
    adb shell settings put global ble_scan_always_enabled 0
    # Privacy: Disable error reporting
    adb shell settings put secure upload_apk_enable 0
    adb shell settings put global send_action_app_error 0
    # Performance: Speed up animations to 0.5x
    adb shell settings put global window_animation_scale 0.5
    adb shell settings put global transition_animation_scale 0.5
    adb shell settings put global animator_duration_scale 0.5
    echo -e "${GREEN}  ✓ Hidden telemetry disabled and animations sped up.${NC}"
else
    echo -e "${YELLOW}Skipped.${NC}"
fi
echo

# ==========================================
# STEP 8: RESET PERMISSIONS (PRIVACY)
# ==========================================
echo -e "${BLUE}[STEP 8] Privacy Audit (Reset App Permissions)${NC}"
echo "This will cause all installed apps (including Meta/Facebook)"
echo "to lose their current permissions and ask you again when opened."
read -p "Do you want to reset all app permissions? (y/n): " run_perms
if [[ "$run_perms" =~ ^[Yy]$ ]]; then
    echo -e "Resetting global permissions... (This may take a few seconds)"
    adb shell pm reset-permissions
    echo -e "${GREEN}  ✓ Permissions reset to their default state.${NC}"
else
    echo -e "${YELLOW}Skipped.${NC}"
fi
echo

# ==========================================
# FINAL STEP: REBOOT
# ==========================================
echo -e "${BLUE}[FINAL STEP] Reboot Device${NC}"
read -p "Do you want to reboot your S22 now? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    adb reboot
    echo -e "${GREEN}Rebooting...${NC}"
else
    echo -e "${YELLOW}Remember to manually reboot later.${NC}"
fi
echo -e "${CYAN}Process completed successfully!${NC}"
