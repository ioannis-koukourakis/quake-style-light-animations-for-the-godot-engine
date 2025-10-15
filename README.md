# Quake-Style Light Animations for Godot  

A modular, component-based system for creating animated lights in the Godot engine, inspired by the dynamic light animations of classic Quake and Half-Life games.  

### Please note: This repository is no longer actively maintained or supported. Feel free to fork it and make your own changes or improvements!

![Animation Preview](https://github.com/ioannis-koukourakis/quake-style-light-animations-for-the-godot-engine/blob/main/godot_quake_lights.gif)  

Video Preview: https://youtu.be/3TF3_8YQb2U

---

## Version 2.1.1 changelog
- Added support for toggle and flicker sounds.
- Added support for particle effects that sync with flicker and lamp state. 
- Introducing a new handler to control and adjust the brightness of the linked mesh instances material emission.
- General optimizations.
- Fixed the .gitignore file to properly include .import data, preventing issues with looping sound in the example scene.
- Resolved missing audio reference warnings.

---

## Version 2.0 Highlights  
- **Godot 4 Compatible**: Redesigned for Godot 4 (no longer supports Godot 3).  
- **Component-Based Design**: Includes two modular components:  
  - **Lamp Component**  
  - **Flicker Component**  
- **Simplified Setup**: Drag and drop components into your scene for quick and easy light animation setup.  

---

## Features  
- **11 Animation Presets**: Includes predefined light animation tables from Quake.  
- **Custom Animations**: Supports user-defined animation strings.  
- **Editor Previews**: Preview animations directly in the Godot editor.  
- **Smooth Transitions**: Optional fade effect to reduce stepping.  
- **Material Integration**: Light animations affect the lamp material’s emission property.  

---

## Installation and Usage  
1. Copy the content of the addon folder into your Godot project's `addons/` directory. 
2. Drag and drop the provided components into your lamp scene.

An example project is included to demonstrate setup and usage, providing a quick way to understand how to configure and combine components.

---

## License  
This addon is released under the **MIT License**.  
