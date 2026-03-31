# Lummotm's Dotfiles
Mis dotfiles personales. Este es el repositorio en el que gestiono todo mi setup de Linux.

En general, los dotfiles se centran en 2 configuraciones principales: la de mi PC de escritorio, en el que busco tener autologin, y la de mi laptop, en la que necesito ajustes específicos como desactivar la gráfica dedicada y optimizar batería. 

Me suelo decantar siempre por trabajar con menús de Rofi para todo lo que se pueda: selector de fondos, gestor de apagado, gestor de audio, gestor de bluetooth, gestor de internet... 

## Instalación Rápida
Clona el repositorio y lanza el asistente interactivo en un solo paso:
```bash
git clone https://github.com/Lummotm/dotfiles.git ~/dotfiles && cd ~/dotfiles/install && ./install.sh
```

El script te guiará preguntando qué módulos y configuraciones específicas quieres aplicar en tu máquina actual.

## Estructura del Repositorio
La filosofía del repositorio, se basa en ser estrictamente modular, para poder trabajar con GNU stow de manera cómoda.
La estructura es la siguiente:

* `common/`: El núcleo. Configuraciones generales, iconos, y scripts compartidos en todos mis equipos.
* `desktop/` y `laptop/`: Configuraciones específicas según la máquina (variables de entorno, monitores, gestión de energía).
* `themes/`: Diferentes perfiles visuales (barras verticales, minimalistas, con o sin bordes).
* `install/`: Scripts de despliegue (`install.sh` y `apply.sh`).
* `extra/`: Archivos del sistema que requieren permisos de root (configuraciones de `greetd`, remapeo de teclas con `keyd`, reglas de `sudoers`). Estos **no** se enlazan con stow por seguridad, se copian directamente.
* `archive/`: Temas y configuraciones antiguas (Rofi/Waybar) que conservo como referencia.

### NOTAS 
Estos dotfiles son totalmente personales, tienen muchos scripts en la sección de common/bin que son objetivamente demasiado específicos para ser útiles salvo para mi.

Si te gusta la base pero quieres cambiar cosas, la estructura modular te lo pone fácil. Simplemente haz un fork del repositorio, elimina los módulos que no necesites dentro de `common/`, y modifica los archivos a tu gusto antes de lanzar el instalador.

