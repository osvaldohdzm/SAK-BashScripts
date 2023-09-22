#!/bin/bash

# Verificar si se ejecuta como root o con sudo
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecute este script como root o con sudo."
  exit 1
fi

# Función para instalar Brave Browser
install_brave_browser() {
  if ! command -v brave-browser &>/dev/null; then
    # Instalar Brave Browser
    echo "Instalando Brave Browser..."
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    apt update
    apt install brave-browser -y
  else
    echo "Brave Browser ya está instalado."
  fi
}

# Función para instalar XFCE
install_xfce() {
  if ! dpkg -l | grep -q xfce4; then
    # Instalar XFCE
    echo "Instalando XFCE..."
    apt update
    apt install xfce4 -y

    # Opcional: Instalar extras y paquetes recomendados de XFCE
    apt install xfce4-goodies -y
  else
    echo "XFCE ya está instalado."
  fi
}

# Función para configurar el diseño del teclado
configure_keyboard_layout() {
  echo "Configurando el diseño del teclado en inglés (US) internacional..."
  setxkbmap us intl

  # Crear un archivo de configuración para hacer el cambio permanente
  echo "Creando un archivo de configuración para el diseño del teclado..."
  cat <<EOF > /etc/X11/xorg.conf.d/90-keyboard-layout.conf
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "yes"
    Option "XkbLayout" "us"
    Option "XkbVariant" "intl"
EndSection
EOF

  echo "Instalación y configuración del diseño del teclado completadas. Es posible que deba reiniciar su sesión X o el sistema para que los cambios surtan efecto."
}

# Función para establecer la resolución de pantalla
set_screen_resolution() {
  # Define el modo de resolución deseado
  resolution_mode="1023x658"

  # Define la ubicación del archivo de configuración de la resolución de pantalla
  config_file="/etc/X11/xorg.conf.d/10-monitor.conf"

  # Comprueba si el archivo existe y borra su contenido si es así
  if [ -f "$config_file" ]; then
    > "$config_file"
  fi

  # Escribe el nuevo contenido en el archivo
  cat <<EOF > "$config_file"
Section "Monitor"
  Identifier  "Monitor0"
  Modeline    "$resolution_mode" 83.50 1280 1352 1480 1680 800 803 809 831 -hsync +vsync
  Option      "PreferredMode" "$resolution_mode"
EndSection
EOF

  # Establece la resolución como predeterminada para la salida (cambia VGA-1 a tu salida real)
  # Comprueba si el modo ya existe; si no, créalo
  if ! xrandr | grep "$resolution_mode" >/dev/null; then
    xrandr --newmode "$resolution_mode" 83.50 1280 1352 1480 1680 800 803 809 831 -hsync +vsync
  fi

  # Agrega el modo a la salida adecuada (cambia VGA-1 a tu salida real)
if ! xrandr -q | grep "$resolution_mode" >/dev/null; then
  xrandr --addmode VGA-1 "$resolution_mode"
fi

}


xrandr --output VGA-1 --mode "$resolution_mode"


# Llamar a las funciones para ejecutar las tareas
install_brave_browser
install_xfce
configure_keyboard_layout
set_screen_resolution

# Disable automatic suspend
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/sleep-inactive-ac-timeout -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/sleep-inactive-battery-timeout -s 0

# Disable screen lock
xfconf-query -c xfce4-session -p /general/LockScreen -s false

# Set screen blanking to "never"
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-battery -s 0


xfconf-query -c xsettings -p /Net/IconThemeName -s Flat-Remix-Blue-Dark
xfconf-query -c xsettings -p /Net/ThemeName -s Kali-Dark
xfconf-query -c xfwm4 -p /general/theme -s Kali-Dark
gsettings set org.xfce.mousepad.preferences.view color-scheme Kali-Dark


#sudo apt -y install compton
#xfconf-query -c xfwm4 -p /general/use_compositing -s false

# Restore Kali’s default appearance
#rm -rf ~/.config/xfce4/ && sudo reboot


chown ozzy:ozzy /etc/X11/xorg.conf.d/10-monitor.conf
chmod 644 /etc/X11/xorg.conf.d/10-monitor.conf

# Función para verificar el número de monitores conectados y realizar la acción correspondiente
function gestionar_screensaver {
    # Usar xrandr para obtener información sobre los monitores conectados
    if xrandr | grep -q " connected"; then
        # Contar el número de líneas que contienen " connected" en la salida de xrandr
        num_monitores=$(xrandr | grep " connected" | wc -l)

        if [ "$num_monitores" -eq 2 ]; then
            # Si hay dos monitores conectados, desinstalar los paquetes
            echo "Se han detectado dos monitores. Desinstalando paquetes de screensaver."
            apt remove kali-screensaver hollywood-activate xscreensaver
        else
            # Si solo hay un monitor conectado, instalar los paquetes
            echo "Se ha detectado un monitor. Instalando paquetes de screensaver."
            apt install kali-screensaver hollywood-activate xscreensaver
        fi
    else
        # Si no se detecta ningún monitor, mostrar un mensaje de error
        echo "No se ha detectado ningún monitor."
    fi
}

# Llamar a la función para gestionar los screensavers
gestionar_screensaver
#xscreensaver-demo


#.zshrc could noitifyu reoslution  /etc/init.d/set_resolution

# Define el archivo de configuración
config_file="/etc/init.d/set_resolution"

# Comprueba si el archivo de configuración existe, y si no, lo crea
if [ ! -f "$config_file" ]; then
  echo "Creando archivo de configuración..."
  touch "$config_file"
  chmod +x "$config_file"

  # Escribe el contenido del archivo de configuración
  cat <<EOF > "$config_file"
#!/bin/bash

# Definiciones de modos de resolución
resolutions=("1920x1080_60.00" "1280x720_60.00" "1024x768_60.00" "1368x768_60.00")  # Agrega todas las resoluciones que desees configurar

# Define la resolución seleccionada
selected_resolution="1368x768_60.00"  # Cambia esta línea con la resolución que deseas aplicar

# Configura todos los modos de resolución
for resolution in "\${resolutions[@]}"; do
    # Define el modo de resolución
    resolution_mode="\$resolution"

    # Imprime un mensaje informativo
    echo "Modo de resolución: \$resolution_mode"

    # Verifica si el modo de resolución ya existe
    if ! xrandr | grep "\$resolution_mode" >/dev/null; then
        echo "Creando nuevo modo de resolución..."

        # Define los parámetros para cvt
        case "\$resolution_mode" in
            "1368x768_60.00")
                cvt_params="1368 768 60.00"
                ;;
            "1920x1080_60.00")
                cvt_params="1920 1080 60.00"
                ;;
            *)
                echo "Resolución no válida: \$resolution_mode"
                exit 1
                ;;
        esac

        # Utiliza cvt para generar la definición del modo de resolución
        mode_definition=\$(cvt \$cvt_params | grep "Modeline" | cut -d ' ' -f 2-)

        # Agrega el nuevo modo de resolución
        xrandr --newmode "\$resolution_mode" \$mode_definition
    fi
done

# Establece la resolución seleccionada como predeterminada para la salida VGA-1
xrandr --output VGA-1 --mode "\$selected_resolution"

# Reinicia el administrador de ventanas Compton
pkill compton

# Exporta la variable de entorno SESSION_MANAGER
export SESSION_MANAGER=\$(dbus-launch)

# Ejecuta xfwm4 con compositor activado en segundo plano
nohup xfwm4 --replace --compositor=on >/dev/null 2>&1 &
EOF
  echo "Archivo de configuración creado con el modo $selected_resolution"
fi


