#!/bin/bash

# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Ruta donde se montará la carpeta compartida (cambiar a una ubicación donde el usuario actual tenga permisos de escritura)
mount_point="/home/$(logname)/PrivateSharingFolder"

# Ruta del directorio del escritorio
desktop_dir="/home/$(logname)/Escritorio"

# Get the current username
current_user=$(logname)

# Check if the "netusers" group already exists
if grep -q "^netusers:" /etc/group; then
  # Group exists, add the current user to it
  usermod -aG netusers "$current_user"
  echo "$current_user added to the 'netusers' group."
else
  # Group doesn't exist, create it and add the current user
  groupadd netusers
  usermod -aG netusers "$current_user"
  echo "Created 'netusers' group and added $current_user to it."
fi

read -p "Ingresa la IP servidor personal:" server_ip

# Solicitar al usuario que ingrese su nombre de usuario
read -p "Ingresa tu nombre de usuario: " username

# Solicitar al usuario que ingrese su contraseña de forma segura y silenciosa
read -s -p "Ingresa tu contraseña: " password
echo  # Agregar un salto de línea después de la entrada de la contraseña

share_name="PrivateSharingFolder"

# Comprobamos si la carpeta compartida ya está montada y la desmontamos si es necesario
if mount | grep -q "$mount_point"; then
  umount "$mount_point"
  echo "Carpeta compartida desmontada previamente."
fi

# Comprobamos si el enlace simbólico existe y lo borramos si es necesario
if [ -L "$desktop_dir/PrivateSharingFolder" ]; then
  rm -f "$desktop_dir/PrivateSharingFolder"
  echo "Enlace simbólico anterior borrado."
fi

# Comprobamos si la carpeta compartida ya está montada
if [ ! -d "$mount_point" ]; then
  # Si no existe el punto de montaje, lo creamos
  mkdir -p "$mount_point"
fi

# Montamos la carpeta compartida en el punto de montaje con permisos de escritura
mount -t cifs "//${server_ip}/${share_name}" "$mount_point" -o username="$username",password="$password",rw,uid=$(id -u "$current_user"),gid=$(id -g "$current_user")

# Cambiamos el grupo propietario del directorio al grupo "netusers" y establecemos permisos de escritura para el grupo
chown :netusers "$mount_point"
chmod g+w "$mount_point"

# Comprobamos si el montaje se realizó con éxito
if [ $? -eq 0 ]; then
  # Creamos un enlace simbólico en el escritorio
  ln -s "$mount_point" "$desktop_dir/PrivateSharingFolder"
  echo "Carpeta compartida montada y enlace simbólico creado en el escritorio."
else
  echo "Error al montar la carpeta compartida."
fi
