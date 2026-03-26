## Mis dotfiles personales

No se porque estas aquí pero bueno si quieres mis dotfiles aquí están. 

### No se que son unos dotfiles, solo quiero la config.
Para instalarlos de una usa
~~~bash
git clone https://github.com/Lummotm/dotfiles.git ~/dotfiles && cd ~/dotfiles/install && ./setup-install.sh
~~~
Hay una instalación y te va preguntando que quieres instalar, la interfaz fue hecha por Gemini AI, el setup general es mio. 

### Si no quieres cosas de mi setup
Siempre puedes hacer un fork en github hacer, git clone a ese repo e ir borrando las cosas que no quieras. 



#### No sigas leyendo, mucho texto incoming.

La filosofía es ser un setup modular, hay 7 carpetas.
1. archive, solo tiene barras que use antes y temas en general usados antes de los que me da pena desprenderme
2. desktop / laptop son efectivamente configuraciones especificas de pc de escritorio o portatil, aunque la moyoria de cosas sean compartidas temas como variables de entorno, la existencia de wifi, bluetooth y demas no lo son. 
3. common son configuraciones, scripts temas que son generales de cualquiera de mis 2 ordenadores.
4. install, pues efectivamente donde vive todo el tema de setup, los scripts importantes son:
     - stow-config.sh, es un script que tiene todas las bases de como linkeamos las distintas configuraciones, se basas en gnu-stow, un gestor symlinks, ademas como lo uso como un pseudo-orquestador entonces tiene muchas mas funciones utiles: tema de fuentes lo maneja,tema de defaults de git como evitar que gestione configuraciones de color y demas entre otros. 
     - setup-install, es el script principal de instalación, pues eso que instala las cosas. 
5. extra, cosas que han de ser gestionadas por dotfiles para que tenerlas guardadas pero que no son archivos de configuracion. 
    - keyd. Daemon que se encarga de cambiar la Caps key por Meta si mantienes y Esc si haces tap, es super comodo. 
    - bin, sudoers, greetd, wayland-sessions. Son carpetas en las que hay configuraciones en las que no confio que un script de bash guarde bien asi que las copio a sus respectivos sitios de configuracion en general con 03-config.sh.
