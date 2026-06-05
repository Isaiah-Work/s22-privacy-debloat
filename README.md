# 📱 Samsung Galaxy S22 Ultimate Privacy & Debloat Script

Un script interactivo en Bash diseñado para limpiar agresivamente el bloatware, mitigar la telemetría, aplicar restricciones profundas de red (Knox/Operadoras) y automatizar la instalación de tiendas de código abierto (F-Droid y Aurora Store) en dispositivos Samsung con One UI.

Este proyecto nació con el objetivo de acercar la experiencia de un dispositivo Samsung moderno a un estándar de privacidad estricto (similar a filosofías como GrapheneOS), entendiendo las limitaciones de hardware y *bootloaders* bloqueados.

## ✨ Características Principales

1. **Instalación de Tiendas FOSS Automatizada**: Hace *web scraping* y descarga dinámicamente la última versión de **F-Droid** y **Aurora Store** directamente a tu dispositivo vía ADB.
2. **Debloat a Prueba de Fallos**: Usa un sistema de arrays (`mapfile`) para leer la lista de desinstalación (`unified_debloat_list.txt`), evitando el clásico bug donde ADB consume el *stdin* en los bucles `while`.
3. **AppOps Extremo (Mitigación Knox y Telcel/Operadoras)**: Algunos paquetes de operadoras y de Samsung Knox no pueden ser desinstalados ni suspendidos por motivos de seguridad del sistema. El script aplica la regla `RUN_IN_BACKGROUND ignore` a estos paquetes, dejándolos completamente congelados y mudos en segundo plano.
4. **Escudo de Privacidad de Red**: Configura globalmente **Mullvad DNS** (`adblock.doh.mullvad.net`) para bloquear rastreadores nativamente sin depender de una VPN encendida.
5. **Apagado de Telemetría Fantasma**: Desactiva el escaneo constante y oculto de WiFi/Bluetooth (`wifi_scan_always_enabled 0`), y apaga el envío automático de errores a Google/Samsung.
6. **Mejora de Rendimiento**: Acelera las animaciones de One UI a `0.5x` globalmente.
7. **Botón de Pánico de Permisos (`pm reset-permissions`)**: Restablece todos los permisos de tiempo de ejecución en todas las aplicaciones, forzando una auditoría de privacidad manual la próxima vez que abras cualquier app (como Meta o WhatsApp).

## 🚀 Instalación y Uso

### Prerrequisitos
- Una computadora con Linux, macOS o WSL.
- Tener **ADB (Android Debug Bridge)** instalado (`sudo apt install android-tools` o equivalente).
- Tener activada la **Depuración por USB** en tu Samsung (Opciones de desarrollador).

### Ejecución
1. Clona este repositorio:
   ```bash
   git clone https://github.com/TU_USUARIO/s22-privacy-debloat.git
   cd s22-privacy-debloat
   ```
2. Revisa y edita la lista `unified_debloat_list.txt`. Si quieres conservar alguna aplicación (por ejemplo, el reloj o el calendario de Samsung), simplemente ponle un `#` al inicio de la línea.
3. Dale permisos de ejecución al script y córrelo:
   ```bash
   chmod +x s22_debloat_y_tiendas.sh
   ./s22_debloat_y_tiendas.sh
   ```
4. Sigue las instrucciones interactivas en pantalla.

---

## 🛡️ La Filosofía "Shelter" (Aislamiento)

Para alcanzar el máximo nivel de privacidad sin perder funcionalidades del día a día, recomiendo encarecidamente usar **Shelter** (o Insular) desde F-Droid para crear un **Perfil de Trabajo**.

* **Apps Esenciales en el perfil principal**: Usa apps FOSS (Fossify, Organic Maps, ProtonMail, Mull, etc.) y tus utilidades bancarias.
* **Apps Invasivas en Shelter**: Clona al perfil de trabajo todo el ecosistema invasivo (WhatsApp, Instagram, Facebook, TikTok, Amazon) y aplicaciones de rastreo como Life360. 
Al hacer esto, las corporaciones no tendrán acceso a tu lista de contactos personales, ni a tu galería de fotos. Además, puedes **congelar** todo el perfil de trabajo con un solo toque cuando desees total desconexión.

## 🙏 Créditos y Agradecimientos

Este proyecto fue construido tomando inspiración, base de listas y lógicas de automatización de dos herramientas fantásticas en la comunidad de Android:

* **[Universal Android Debloater Next Generation (UAD-NG)](https://github.com/0x192/universal-android-debloater)**: Por la excelente base de datos de paquetes seguros para eliminar y el listado exportado de paquetes basura de One UI.
* **[@fadelhbr](https://github.com/fadelhbr)**: Por la base estructural del script bash interactivo para la desinstalación limpia vía terminal.

---
*Disclaimer: Úsalo bajo tu propio riesgo. Desinstalar ciertos paquetes vitales puede causar bootloops. Lee siempre la lista de debloat antes de ejecutar.*
