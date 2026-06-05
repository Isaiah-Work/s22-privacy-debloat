#!/usr/bin/env bash

# Configuración de colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

clear
echo -e "${CYAN}====================================================================${NC}"
echo -e "${WHITE}    📱 SCRIPT UNIFICADO: TIENDAS FOSS & DEBLOAT - SAMSUNG S22 📱  ${NC}"
echo -e "${CYAN}====================================================================${NC}"
echo -e "Este script instalará F-Droid y Aurora Store,"
echo -e "aplicará restricciones a Knox, y limpiará el bloatware basándose"
echo -e "en tu lista unificada (unified_debloat_list.txt)."
echo -e "${CYAN}====================================================================${NC}"
echo

# ==========================================
# PASO 1: VERIFICAR CONEXIÓN ADB
# ==========================================
echo -e "${BLUE}[PASO 1] Verificando conexión ADB...${NC}"
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: ADB no está instalado en este sistema.${NC}"
    exit 1
fi

while true; do
    devices=($(adb devices | grep -v "List" | grep "device$" | cut -f1))
    if [ ${#devices[@]} -eq 0 ]; then
        echo -e "${YELLOW}No se detectó ningún dispositivo conectado por ADB.${NC}"
        read -p "Conecta tu móvil y presiona [Enter] para reintentar..."
    else
        selected_device=${devices[0]}
        echo -e "${GREEN}Dispositivo detectado con éxito: $selected_device${NC}"
        break
    fi
done
echo

# ==========================================
# PASO 2: INSTALAR F-DROID Y AURORA STORE
# ==========================================
echo -e "${BLUE}[PASO 2] Instalando tiendas FOSS (F-Droid y Aurora Store)...${NC}"
read -p "¿Deseas descargar e instalar F-Droid y Aurora Store? (s/n): " inst_stores
if [[ "$inst_stores" =~ ^[Ss]$ ]]; then
    
    # 1. Instalar F-Droid
    echo -e "${WHITE}Descargando F-Droid...${NC}"
    curl -sL -o /tmp/FDroid.apk "https://f-droid.org/F-Droid.apk"
    echo -e "Instalando F-Droid en tu S22..."
    adb install -r /tmp/FDroid.apk 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[ÉXITO] F-Droid instalado correctamente.${NC}"
    else
        echo -e "${RED}[FALLÓ] No se pudo instalar F-Droid.${NC}"
    fi

    # 2. Instalar Aurora Store
    echo -e "${WHITE}Obteniendo enlace de la última versión de Aurora Store...${NC}"
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
        echo -e "Descargando Aurora Store desde F-Droid..."
        curl -sL -o /tmp/AuroraStore.apk "$aurora_url"
        echo -e "Instalando Aurora Store..."
        adb install -r /tmp/AuroraStore.apk 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[ÉXITO] Aurora Store instalada correctamente.${NC}"
        else
            echo -e "${RED}[FALLÓ] Error al instalar Aurora Store.${NC}"
        fi
    else
        echo -e "${RED}Error al obtener la URL de descarga de Aurora Store.${NC}"
    fi

else
    echo -e "${YELLOW}Paso omitido por el usuario.${NC}"
fi
echo

# ==========================================
# PASO 3: INSTALADOR DE APPS FOSS (OPCIONAL)
# ==========================================
echo -e "${BLUE}[PASO 3] Menú de Instalación de Aplicaciones FOSS${NC}"
echo "Elige qué aplicaciones libres y sin rastreo deseas instalar."
echo "Escribe los números separados por espacio (ej: 1 3 5), o escribe 't' para instalar TODAS."
echo "  1) Fossify Gallery"
echo "  2) Fossify Messages"
echo "  3) Fossify Calendar"
echo "  4) Fossify Clock"
echo "  5) Fossify Contacts"
echo "  6) Fossify Phone"
echo "  7) Lawnchair (Launcher Moderno Privado)"
echo "  8) FUTO Keyboard (Teclado sin telemetría offline)"
echo "  s) Saltar este paso"

read -p "Tu elección: " app_choices

if [[ "$app_choices" != "s" ]]; then
    declare -A app_repos=(
        [1]="FossifyOrg/Gallery"
        [2]="FossifyOrg/Messages"
        [3]="FossifyOrg/Calendar"
        [4]="FossifyOrg/Clock"
        [5]="FossifyOrg/Contacts"
        [6]="FossifyOrg/Phone"
    )
    
    install_list=()
    if [[ "$app_choices" == "t" || "$app_choices" == "T" ]]; then
        install_list=(1 2 3 4 5 6 7 8)
    else
        for choice in $app_choices; do
            install_list+=($choice)
        done
    fi
    
    for opt in "${install_list[@]}"; do
        if [[ "$opt" -ge 1 && "$opt" -le 6 ]]; then
            repo="${app_repos[$opt]}"
            echo -e "Descargando ${WHITE}$repo${NC}..."
            url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -E "browser_download_url.*\.apk" | head -n 1 | cut -d '"' -f 4)
            curl -sL -o /tmp/foss.apk "$url"
            echo -e "Instalando..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Instalado${NC}"
        elif [[ "$opt" == "7" ]]; then
            echo -e "Descargando ${WHITE}Lawnchair${NC}..."
            url=$(curl -s "https://api.github.com/repos/LawnchairLauncher/lawnchair/releases" | grep -E "browser_download_url.*\.apk" | head -n 1 | cut -d '"' -f 4)
            curl -sL -o /tmp/foss.apk "$url"
            echo -e "Instalando..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Instalado${NC}"
        elif [[ "$opt" == "8" ]]; then
            echo -e "Descargando ${WHITE}FUTO Keyboard${NC}..."
            curl -sL -o /tmp/foss.apk "https://keyboard.futo.org/nightly.apk"
            echo -e "Instalando..."
            adb install -r /tmp/foss.apk 2>/dev/null
            echo -e "${GREEN}  ✓ Instalado${NC}"
        fi
    done
else
    echo -e "${YELLOW}Instalación de FOSS omitida.${NC}"
fi
echo

# ==========================================
# PASO 4: RESTRICCIONES DE SEGUNDO PLANO
# ==========================================
echo -e "${BLUE}[PASO 4] Restricciones (Knox / Operadora)...${NC}"
read -p "¿Deseas aplicar las restricciones de segundo plano? (s/n): " run_appops
if [[ "$run_appops" =~ ^[Ss]$ ]]; then
    restringidos=(
        "co.sitic.pp"
        "com.sec.enterprise.knox.cloudmdm.smdms"
        "com.knox.vpn.proxyhandler"
        "com.telcel.contenedor"
        "com.dti.amx"
        "com.telcel.mms"
        "com.aura.oobe.telcel"
    )
    for pkg in "${restringidos[@]}"; do
        echo -e "Aplicando bloqueo RUN_IN_BACKGROUND a: ${YELLOW}$pkg${NC}..."
        adb shell cmd appops set "$pkg" RUN_IN_BACKGROUND ignore &>/dev/null
        adb shell pm suspend "$pkg" &>/dev/null
        echo -e "${GREEN}[HECHO]${NC}"
    done
else
    echo -e "${YELLOW}Omitido.${NC}"
fi
echo

# ==========================================
# PASO 5: DEBLOAT CON LISTA UNIFICADA
# ==========================================
echo -e "${BLUE}[PASO 5] Desinstalación de Bloatware (Lista unificada)${NC}"
unified_list="unified_debloat_list.txt"

if [ ! -f "$unified_list" ]; then
    echo -e "${RED}Error: El archivo $unified_list no se encuentra en el directorio actual.${NC}"
    exit 1
fi

total_apps=$(wc -l < "$unified_list")
echo -e "Se detectaron ${GREEN}$total_apps${NC} aplicaciones listas para ser removidas."
read -p "¿Iniciar desinstalación masiva? (s/n): " confirm_uninst
if [[ "$confirm_uninst" =~ ^[Ss]$ ]]; then
    success_count=0
    fail_count=0
    
    mapfile -t packages < "$unified_list"
    for pkg in "${packages[@]}"; do
        [ -z "$pkg" ] && continue
        echo -e "Eliminando: ${WHITE}$pkg${NC}..."
        output=$(adb shell pm uninstall -k --user 0 "$pkg" </dev/null 2>&1)
        if echo "$output" | grep -q "Success"; then
            echo -e "${GREEN}  ✓ Éxito${NC}"
            ((success_count++))
        else
            echo -e "${RED}  ✗ Omitido/Falló${NC}"
            ((fail_count++))
        fi
    done
    
    echo -e "${CYAN}====================================================================${NC}"
    echo -e "${GREEN}Resumen de debloat:${NC}"
    echo -e "  Removidos: ${GREEN}$success_count${NC} | Fallidos/No existentes: ${RED}$fail_count${NC}"
    echo -e "${CYAN}====================================================================${NC}"
else
    echo -e "${YELLOW}Omitido.${NC}"
fi
echo

# ==========================================
# PASO 6: CONFIGURAR DNS PRIVADO (MULLVAD)
# ==========================================
echo -e "${BLUE}[PASO 6] Configuración de DNS Privado (Escudo contra Rastreadores)${NC}"
read -p "¿Deseas activar Mullvad DNS (muy compatible y privado) a nivel de red? (s/n): " run_dns
if [[ "$run_dns" =~ ^[Ss]$ ]]; then
    adb shell settings put global private_dns_mode hostname
    adb shell settings put global private_dns_specifier adblock.doh.mullvad.net
    echo -e "${GREEN}  ✓ DNS Privado activado (adblock.doh.mullvad.net)${NC}"
else
    echo -e "${YELLOW}Omitido.${NC}"
fi
echo

# ==========================================
# PASO 7: OPTIMIZACIÓN DEL SISTEMA Y PRIVACIDAD PROFUNDA
# ==========================================
echo -e "${BLUE}[PASO 7] Acelerar el teléfono y apagar telemetría oculta${NC}"
echo "1. Desactivará el escaneo oculto de WiFi/Bluetooth."
echo "2. Bloqueará la telemetría de fallos de Google."
echo "3. Acelerará las animaciones al doble (0.5x)."
read -p "¿Aplicar estas mejoras de rendimiento y privacidad? (s/n): " run_opt
if [[ "$run_opt" =~ ^[Ss]$ ]]; then
    # Privacidad: Apagar escaneo constante
    adb shell settings put global wifi_scan_always_enabled 0
    adb shell settings put global ble_scan_always_enabled 0
    # Privacidad: Apagar reporte de errores
    adb shell settings put secure upload_apk_enable 0
    adb shell settings put global send_action_app_error 0
    # Rendimiento: Acelerar animaciones a 0.5x
    adb shell settings put global window_animation_scale 0.5
    adb shell settings put global transition_animation_scale 0.5
    adb shell settings put global animator_duration_scale 0.5
    echo -e "${GREEN}  ✓ Telemetría oculta apagada y animaciones aceleradas.${NC}"
else
    echo -e "${YELLOW}Omitido.${NC}"
fi
echo

# ==========================================
# PASO 8: RESTABLECER PERMISOS (PRIVACIDAD)
# ==========================================
echo -e "${BLUE}[PASO 8] Auditoría de Privacidad (Restablecer permisos de Apps)${NC}"
echo "Esto hará que todas tus aplicaciones instaladas (incluyendo Meta/Facebook)"
echo "pierdan sus permisos actuales y te vuelvan a preguntar al abrirlas."
read -p "¿Deseas restablecer todos los permisos de las aplicaciones? (s/n): " run_perms
if [[ "$run_perms" =~ ^[Ss]$ ]]; then
    echo -e "Restableciendo permisos globales... (Esto puede tomar unos segundos)"
    adb shell pm reset-permissions
    echo -e "${GREEN}  ✓ Permisos restablecidos a su estado por defecto.${NC}"
else
    echo -e "${YELLOW}Omitido.${NC}"
fi
echo

# ==========================================
# REINICIO
# ==========================================
echo -e "${BLUE}[PASO FINAL] Reiniciar dispositivo${NC}"
read -p "¿Deseas reiniciar tu S22 ahora? (s/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Ss]$ ]]; then
    adb reboot
    echo -e "${GREEN}Reiniciando...${NC}"
else
    echo -e "${YELLOW}Recuerda reiniciar manualmente más tarde.${NC}"
fi
echo -e "${CYAN}¡Proceso finalizado con éxito!${NC}"
