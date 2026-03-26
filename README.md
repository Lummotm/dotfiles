# 🏠 Dotfiles de Lummotm

> *Mi entorno de trabajo modular para Wayland (Hyprland & Niri).*

No sé por qué estás aquí, pero bueno, si quieres mis dotfiles, aquí están. Este repositorio contiene toda la configuración de mis sistemas, pensada para ser predecible, rápida y fácil de mantener.

## 🌟 Highlights
* **Wayland First:** Optimizado totalmente para Hyprland y Niri.
* **Modular:** Separación clara entre portátil (`laptop`) y sobremesa (`desktop`).
* **Automatizado:** Usa `stow` y un script interactivo para gestionar los enlaces.
* **Scripting:** Funciones personalizadas para batería, Wi-Fi, Bluetooth y la GPU.

## ⬇️ Instalación Rápida
Para instalarlos de una, lanza este comando en tu terminal:

```bash
git clone [https://github.com/Lummotm/dotfiles.git](https://github.com/Lummotm/dotfiles.git) ~/dotfiles && cd ~/dotfiles/install && ./setup-install.sh
```

El script lanzará un asistente que te irá preguntando qué quieres instalar. *(Dato: la interfaz del instalador fue generada con mi ayuda como IA, pero la lógica y el setup general son del autor original).*

## ℹ️ Filosofía y Estructura
La filosofía de este setup es ser totalmente **modular**. Todo el repositorio está dividido en estas carpetas principales:

* 📦 **`archive/`**: Barras y temas generales que usé en el pasado y de los que me da pena desprenderme.
* 💻 **`desktop/`** y 💻 **`laptop/`**: Configuraciones específicas para el PC de escritorio o el portátil (variables de entorno, gestión de Wi-Fi, Bluetooth y batería).
* 🤝 **`common/`**: Configuraciones, scripts y temas generales que uso en cualquiera de mis ordenadores.
* ⚙️ **`install/`**: Donde vive la magia del setup.
* 🧩 **`extra/`**: Archivos del sistema que *no* se enlazan con Stow por seguridad, sino que el script copia con permisos `sudo` (ej. daemon de `keyd` para remapear el *Caps Lock*, configuraciones de `greetd`, reglas de `sudoers`).

## 💭 Instalación a la carta y Feedback
Si no quieres todas las cosas de mi setup, ¡no te preocupes! Siempre puedes hacer un **fork** de este repositorio en GitHub, clonar tu versión e ir borrando las carpetas que no te sirvan antes de ejecutar el instalador.

