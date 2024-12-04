class_name cComponentBase extends Node

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

## Whether this component is active. 
@export var Active: bool = true : set = SetActive, get = GetActive;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

#-------------------------------------------------------
# MAIN CALLBACKS
#-------------------------------------------------------

func _ready():
	set_process(Active);
	set_physics_process(Active);
	set_process_input(Active);
	set_process_internal(Active);
	set_process_shortcut_input(Active);
	set_process_unhandled_input(Active);
	set_process_unhandled_key_input(Active);
	

# ------------------------------------------------
# SAVE/LOAD
# ------------------------------------------------

func GetSaveData()-> Dictionary:
	var dData: Dictionary = {};
	dData["Active"] = GetActive();
	return dData;

#-------------------------------------------------------

func SetSaveData(adData: Dictionary)-> void:
	if (adData.has("Active")):
		SetActive(adData["Active"]);


# ------------------------------------------------
# HELPERS
# ------------------------------------------------.

# ------------------------------------------------
# INTERFACE
# ------------------------------------------------

func SetActive(abX:bool)->void:
	Active = abX;

func GetActive()->bool:
	return Active;

#-------------------------------------------------------
