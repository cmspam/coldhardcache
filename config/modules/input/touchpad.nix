{
  config,
  pkgs,
  lib,
  ...
}:

let
  # KWin script metadata
  metadata = builtins.toJSON {
    KPackageStructure = "KWin/Script";
    KPlugin = {
      Name = "Per-App Scroll Speed";
      Description = "Configure touchpad scroll sensitivity per application";
      Icon = "input-touchpad";
      Authors = [ { Name = "User"; } ];
      Id = "per-app-scroll-speed";
      Version = "2.0";
      License = "MIT";
    };
    X-Plasma-API = "javascript";
    X-Plasma-MainScript = "code/main.js";
    X-KDE-ConfigModule = "kwin/effects/configs/kcm_kwin4_genericscripted";
  };

  # Configuration schema XML
  configXml = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <kcfg xmlns="http://www.kde.org/standards/kcfg/1.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.kde.org/standards/kcfg/1.0
                              http://www.kde.org/standards/kcfg/1.0/kcfg.xsd">
      <kcfgfile name="kwinrc"/>
      <group name="">
        <entry name="applicationMappings" type="String">
          <default>brave:0.15</default>
          <label>Application to scroll factor mappings (format: app1:factor1,app2:factor2)</label>
        </entry>
        <entry name="defaultScrollFactor" type="Double">
          <default>0.75</default>
          <label>Default scroll factor for unlisted applications</label>
        </entry>
        <entry name="enableDebug" type="Bool">
          <default>false</default>
          <label>Enable debug logging</label>
        </entry>
      </group>
    </kcfg>
  '';

  # Configuration UI - must start with <?xml without any leading whitespace
  configUi = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <ui version="4.0">
     <class>KWinAppScrollControlConfig</class>
     <widget class="QWidget" name="KWinAppScrollControlConfig">
      <property name="geometry">
       <rect>
        <x>0</x>
        <y>0</y>
        <width>400</width>
        <height>300</height>
       </rect>
      </property>
      <layout class="QVBoxLayout" name="verticalLayout">
       <item>
        <widget class="QLabel" name="label">
         <property name="text">
          <string>Application Scroll Speed Mappings

    Enter application:factor pairs, one per line.
    Example:
    brave:0.15
    firefox:0.3
    code:0.5

    Lower values = slower scrolling (0.1-0.9 recommended)</string>
         </property>
         <property name="wordWrap">
          <bool>true</bool>
         </property>
        </widget>
       </item>
       <item>
        <widget class="QPlainTextEdit" name="kcfg_applicationMappings">
         <property name="plainText">
          <string>brave:0.15</string>
         </property>
        </widget>
       </item>
       <item>
        <layout class="QHBoxLayout" name="horizontalLayout">
         <item>
          <widget class="QLabel" name="label_2">
           <property name="text">
            <string>Default scroll factor:</string>
           </property>
          </widget>
         </item>
         <item>
          <widget class="QDoubleSpinBox" name="kcfg_defaultScrollFactor">
           <property name="minimum">
            <double>0.100000000000000</double>
           </property>
           <property name="maximum">
            <double>2.000000000000000</double>
           </property>
           <property name="singleStep">
            <double>0.050000000000000</double>
           </property>
           <property name="value">
            <double>0.750000000000000</double>
           </property>
          </widget>
         </item>
         <item>
          <spacer name="horizontalSpacer">
           <property name="orientation">
            <enum>Qt::Horizontal</enum>
           </property>
           <property name="sizeHint" stdset="0">
            <size>
             <width>40</width>
             <height>20</height>
            </size>
           </property>
          </spacer>
         </item>
        </layout>
       </item>
       <item>
        <widget class="QCheckBox" name="kcfg_enableDebug">
         <property name="text">
          <string>Enable debug logging</string>
         </property>
        </widget>
       </item>
       <item>
        <widget class="QLabel" name="label_3">
         <property name="text">
          <string>Tip: Enable debug logging and check journalctl to see window classes</string>
         </property>
         <property name="styleSheet">
          <string notr="true">color: gray; font-size: 9pt;</string>
         </property>
         <property name="wordWrap">
          <bool>true</bool>
         </property>
        </widget>
       </item>
       <item>
        <spacer name="verticalSpacer">
         <property name="orientation">
          <enum>Qt::Vertical</enum>
         </property>
         <property name="sizeHint" stdset="0">
          <size>
           <width>20</width>
           <height>40</height>
          </size>
         </property>
        </spacer>
       </item>
      </layout>
     </widget>
     <resources/>
     <connections/>
    </ui>'';

  # Main KWin script
  mainJs = ''
    // Per-App Scroll Speed KWin Script

    let currentMode = null;
    let appMap = {};
    let defaultFactor = 0.75;
    let debugEnabled = false;

    function log(message) {
        if (debugEnabled) {
            console.log("[PerAppScrollSpeed] " + message);
        }
    }

    function loadConfig() {
        // Read configuration from kwinrc
        const mappingsStr = readConfig("applicationMappings", "brave:0.15");
        defaultFactor = readConfig("defaultScrollFactor", 0.75);
        debugEnabled = readConfig("enableDebug", false);
        
        // Parse application mappings (supports both comma and newline separation)
        appMap = {};
        const mappings = mappingsStr.split(/[,\n]+/);
        for (let i = 0; i < mappings.length; i++) {
            const mapping = mappings[i].trim();
            if (mapping.length === 0) continue;
            
            const parts = mapping.split(':');
            if (parts.length === 2) {
                const app = parts[0].trim().toLowerCase();
                const factor = parseFloat(parts[1].trim());
                if (app.length > 0 && !isNaN(factor)) {
                    appMap[app] = factor;
                    log("Loaded mapping: " + app + " -> " + factor);
                }
            }
        }
        
        log("Configuration loaded. Default factor: " + defaultFactor);
        log("Application mappings: " + Object.keys(appMap).length + " entries");
    }

    function getScrollFactorForApp(resourceClass) {
        const className = resourceClass.toLowerCase();
        
        // Check for exact or partial matches
        for (const app in appMap) {
            if (className.includes(app)) {
                log("Matched '" + resourceClass + "' to '" + app + "' with factor " + appMap[app]);
                return appMap[app];
            }
        }
        
        log("No match for '" + resourceClass + "', using default factor " + defaultFactor);
        return defaultFactor;
    }

    function notifySystem(factor) {
        log("Sending factor to daemon: " + factor);
        callDBus(
            "org.cmspam.ScrollFix",
            "/ScrollFix",
            "org.cmspam.ScrollFix",
            "setFactor",
            factor.toString()
        );
    }

    function checkWindow(client) {
        if (!client) {
            log("No client provided");
            return;
        }
        
        const resourceClass = (client.resourceClass || "").toString();
        
        if (resourceClass.length === 0) {
            log("Window has no resource class");
            return;
        }
        
        const factor = getScrollFactorForApp(resourceClass);
        const modeKey = resourceClass + ":" + factor;
        
        if (currentMode !== modeKey) {
            currentMode = modeKey;
            notifySystem(factor);
            log("Active window: " + resourceClass + " -> factor " + factor);
        }
    }

    // Initialize
    log("Script initializing...");
    loadConfig();

    // Connect to window activation signal
    workspace.windowActivated.connect(checkWindow);

    // Check current window on startup
    if (workspace.activeWindow) {
        checkWindow(workspace.activeWindow);
    }

    log("Script initialized successfully");
  '';

in
{
  config = lib.mkIf config.services.desktopManager.plasma6.enable {

    # Install the KWin script with configuration UI
    systemd.user.tmpfiles.rules = [
      # Clean up old scripts
      "r %h/.local/share/kwin/scripts/brave-scroll-dampen"
      "r %h/.local/share/kwin/scripts/app-scroll-control"

      # Create directory structure first
      "d %h/.local/share/kwin/scripts/per-app-scroll-speed 0755"
      "d %h/.local/share/kwin/scripts/per-app-scroll-speed/contents 0755"
      "d %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/code 0755"
      "d %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/config 0755"
      "d %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/ui 0755"

      # Metadata
      "L+ %h/.local/share/kwin/scripts/per-app-scroll-speed/metadata.json - - - - ${pkgs.writeText "metadata.json" metadata}"

      # Main script
      "L+ %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/code/main.js - - - - ${pkgs.writeText "main.js" mainJs}"

      # Configuration schema
      "L+ %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/config/main.xml - - - - ${pkgs.writeText "main.xml" configXml}"

      # Configuration UI
      "L+ %h/.local/share/kwin/scripts/per-app-scroll-speed/contents/ui/config.ui - - - - ${pkgs.writeText "config.ui" configUi}"
    ];

    # Bash daemon - listens for DBus signals and applies scroll factor
    systemd.user.services.scroll-factor-listener = {
      description = "Touchpad Scroll Factor Daemon";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];

      script = ''
        set +e  # Disable exit on error - needed for the while loop to continue

        # Find any touchpad device
        DEVICE_PATH=""

        echo "Searching for touchpad device..."
        for i in {0..30}; do
            PATH_C="/org/kde/KWin/InputDevice/event$i"
            NAME=$(${pkgs.dbus}/bin/dbus-send --session --print-reply \
                --dest=org.kde.touchpad "$PATH_C" \
                org.freedesktop.DBus.Properties.Get \
                string:"org.kde.KWin.InputDevice" string:"name" 2>/dev/null \
                | ${pkgs.gnugrep}/bin/grep -oP '(?<=string ").*(?=")' || true)
            
            # Match any device with "Touchpad" in the name
            if [[ "$NAME" =~ "Touchpad" ]]; then
                DEVICE_PATH="$PATH_C"
                echo "Found touchpad: $NAME at $DEVICE_PATH"
                break
            fi
        done

        if [ -z "$DEVICE_PATH" ]; then
            echo "ERROR: Could not find touchpad device"
            exit 1
        fi

        echo "Listening for scroll factor changes..."

        # Listen for method calls on the ScrollFix interface
        ${pkgs.dbus}/bin/dbus-monitor --session "interface='org.cmspam.ScrollFix',member='setFactor'" | \
        while read -r line; do
            # Look for lines with string values like: string "0.75"
            if echo "$line" | ${pkgs.gnugrep}/bin/grep -q 'string "'; then
                # Extract the factor value between quotes
                FACTOR=$(echo "$line" | ${pkgs.gnugrep}/bin/grep -oP 'string "\K[0-9.]+(?=")')
                
                if [ -n "$FACTOR" ]; then
                   #  echo "Applying scroll factor: $FACTOR"
                    ${pkgs.dbus}/bin/dbus-send --session \
                        --dest=org.kde.touchpad \
                        --type=method_call \
                        "$DEVICE_PATH" \
                        org.freedesktop.DBus.Properties.Set \
                        string:"org.kde.KWin.InputDevice" \
                        string:"scrollFactor" \
                        variant:double:$FACTOR
                fi
            fi
        done
      '';

      serviceConfig = {
        Restart = "always";
        RestartSec = "5";
      };
    };

    # Enable the script in KWin config and clean up old versions
    system.activationScripts.enablePerAppScrollSpeed = {
      text = ''
        # Enable the script for all users and disable old versions
        for user_home in /home/*; do
          if [ -d "$user_home" ]; then
            username=$(basename "$user_home")

            # Skip leftover home dirs whose user was removed from /etc/passwd
            if ! ${pkgs.coreutils}/bin/id -u "$username" >/dev/null 2>&1; then
              continue
            fi

            # Disable old script versions
            ${pkgs.sudo}/bin/sudo -u "$username" \
              ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
              --file kwinrc \
              --group Plugins \
              --key brave-scroll-dampenEnabled false 2>/dev/null || true
            
            ${pkgs.sudo}/bin/sudo -u "$username" \
              ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
              --file kwinrc \
              --group Plugins \
              --key app-scroll-controlEnabled false 2>/dev/null || true
            
            # Enable new script
            ${pkgs.sudo}/bin/sudo -u "$username" \
              ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
              --file kwinrc \
              --group Plugins \
              --key per-app-scroll-speedEnabled true
          fi
        done
      '';
      deps = [ ];
    };
  };
}
