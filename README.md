# Quake-Style Light Animations for Godot  

A modular, component-based system for creating animated lights in the Godot engine, inspired by the dynamic light animations of classic Quake and Half-Life games.  

![Animation Preview](https://github.com/ioannis-koukourakis/quake-style-light-animations-for-the-godot-engine/blob/main/godot_quake_lights.gif)  

Video Preview: https://youtu.be/3TF3_8YQb2U

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
1. Copy the addon folder into your Godot project's `addons/` directory.  
2. Enable the addon in **Project Settings > Plugins**.  
3. Drag and drop the provided components into your lamp scene:  
   - Add the **Lamp Component** to your lamp node.  
   - Optionally, add the **Flicker Component** for advanced effects.  
4. Customize animations through the editor properties.  

---

## Example Project  
An example project is included to demonstrate setup and usage, providing a quick way to understand how to configure and combine components.  

---

## License  
This addon is released under the **MIT License**.  