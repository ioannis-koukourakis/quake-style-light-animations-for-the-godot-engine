@tool
class_name cLampComponent extends cComponentBase

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

## If true the lamp is lit. 
@export var Lit: bool = true : set = SetLit, get = GetLit;
## Controls the overall lamp effects brightness levels.
@export var LampEnergy: float = 1.0 : set = SetLampEnergy, get = GetLampEnergy;
@export var LightEnergyMultiplier: float = 1.0 : set = SetLightEnergyMultiplier, get = GetLightEnergyMultiplier;
## Whether the light fades when toggled on and off.
@export var Fade: bool = false;
## The time it takes to fade if Fade is true.
@export var FadeSpeed: float = 30.0;
## A list of light node instances to sync with the lamp state. 
@export var LightInstances: Array[Light3D];
## A list of mesh node instances who's materials emission sync with the lamp state. 
@export var MeshInstances: Array[MeshInstance3D];
## Optional Flicker component.
@export var FlickerComponent: cFlickerComponent : get = GetFlickerComponent;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mbOldLit: bool = false;
var mbFlickering: bool = false;
var mfFlickerMultiplier: float = 1.0;
var mfCurrentLightEnergy: float = 1.0;
var mfDesiredLightEnergy: float = 1.0;

#-------------------------------------------------------
# MAIN CALLBACKS
#-------------------------------------------------------

func _ready() -> void:
	UpdateLampProperties();

#-------------------------------------------------------

func _physics_process(afTimeStep: float) -> void:
	#####################################
	# Handle Fading
	if (Fade && is_equal_approx(mfCurrentLightEnergy, mfDesiredLightEnergy)==false):
		mfCurrentLightEnergy = lerp(mfCurrentLightEnergy, mfDesiredLightEnergy, clamp(afTimeStep * FadeSpeed, 0.0, 1.0));
		UpdateLampProperties();
	
	#####################################
	# Handle Flickering
	if (GetShouldFlicker()):
		mfFlickerMultiplier = FlickerComponent.GetFlickerValue(afTimeStep);
		UpdateLampProperties();
		mbFlickering = true;
	elif (mbFlickering):
		mfFlickerMultiplier = 1.0;
		UpdateLampProperties();
		mbFlickering = false;

#-------------------------------------------------------
# SAVE/LOAD
#-------------------------------------------------------

func GetSaveData()-> Dictionary:
	var dData: Dictionary = super.GetSaveData();
	dData["Lit"] = GetLit();
	dData["LampEnergy"] = GetLampEnergy();
	dData["LightEnergyMultiplier"] = GetLightEnergyMultiplier();
	dData["OldLit"] = mbOldLit;
	dData["Flickering"] = mbFlickering;
	dData["FlickerMultiplier"] = mfFlickerMultiplier;
	dData["Fade"] = Fade;
	dData["FadeSpeed"] = FadeSpeed;
	return dData;

#-------------------------------------------------------

func SetSaveData(adData: Dictionary)-> void:
	super.SetSaveData(adData);
	
	if (adData.has("Lit")): SetLit(adData["Lit"]);
	if (adData.has("LampEnergy")): SetLampEnergy(adData["LampEnergy"]);
	if (adData.has("LightEnergyMultiplier")): SetLightEnergyMultiplier(adData["LightEnergyMultiplier"]);
	if (adData.has("OldLit")): mbOldLit = adData["OldLit"];
	if (adData.has("Flickering")): mbFlickering = adData["Flickering"];
	if (adData.has("FlickerMultiplier")): mfFlickerMultiplier = adData["FlickerMultiplier"];
	if (adData.has("Fade")): Fade = adData["Fade"];
	if (adData.has("FadeSpeed")): FadeSpeed = adData["FadeSpeed"];

#-------------------------------------------------------
# HELPERS
#-------------------------------------------------------

func GetDesiredLightEnergy() -> float:
	return LampEnergy if Lit else 0.0;

#-------------------------------------------------------

func GetCurrentLightEnergy() -> float:
	return mfCurrentLightEnergy * mfFlickerMultiplier;

#-------------------------------------------------------

func GetShouldFlicker() -> bool:
	if (is_instance_valid(FlickerComponent)==false): return false;
	if (Engine.is_editor_hint() && 
		FlickerComponent.has_method("GetAnimateInTheEditor") && # Sanity check. We get an error when in the editor about non-existing method otherwise sometimes. 
		FlickerComponent.GetAnimateInTheEditor()==false):
		return false;
	return GetFlickerComponentActive();

#-------------------------------------------------------

func UpdateLampProperties()->void:
	################################
	# Light Properties
	for i in range(LightInstances.size()):
		var pCurrLight: Light3D = LightInstances[i];
		if (is_instance_valid(pCurrLight)==false): continue;
		pCurrLight.light_energy = GetCurrentLightEnergy() * LightEnergyMultiplier;
		pCurrLight.light_indirect_energy = GetCurrentLightEnergy() * LightEnergyMultiplier;
	
	################################
	# Material Properties
	for i in range(MeshInstances.size()):
		var pCurrMeshInst: MeshInstance3D = MeshInstances[i];
		if (is_instance_valid(pCurrMeshInst)==false): continue;
		
		for j in range(pCurrMeshInst.get_surface_override_material_count()):
			var pMat: BaseMaterial3D = pCurrMeshInst.get_surface_override_material(j);
			if (is_instance_valid(pMat)==false): continue;
			pMat.set_emission_energy_multiplier(GetCurrentLightEnergy());

# ------------------------------------------------
# INTERFACE
# ------------------------------------------------

func SetActive(abX: bool):
	super.SetActive(abX);
	
	if (abX==false):
		mbOldLit = Lit;
		SetLit(false);
		return;
	
	SetLit(mbOldLit);

# ------------------------------------------------

func SetLit(abX:bool)->void:
	Lit = abX;
	
	mfDesiredLightEnergy = GetDesiredLightEnergy();
	
	if (Fade==false):
		mfCurrentLightEnergy = mfDesiredLightEnergy;
	
	UpdateLampProperties();

#-------------------------------------------------------

func ToggleLit():
	SetLit(!Lit);

#-------------------------------------------------------

func GetLit()->bool:
	return Lit;

#-------------------------------------------------------

func SetLampEnergy(afX:float)->void:
	LampEnergy = afX;
	mfDesiredLightEnergy = GetDesiredLightEnergy();
	mfCurrentLightEnergy = mfDesiredLightEnergy
	UpdateLampProperties();
	
#-------------------------------------------------------

func GetLampEnergy()->float:
	return LampEnergy;

#-------------------------------------------------------

func SetLightEnergyMultiplier(afX:float)->void:
	LightEnergyMultiplier = afX;
	UpdateLampProperties();
	
#-------------------------------------------------------

func GetLightEnergyMultiplier()->float:
	return LightEnergyMultiplier;

#-------------------------------------------------------

func GetLightInstances()->Array[Light3D]:
	return LightInstances;

#-------------------------------------------------------

func GetMeshInstances()->Array[MeshInstance3D]:
	return MeshInstances;

#-------------------------------------------------------

func GetFlickerComponent() -> cFlickerComponent:
	return FlickerComponent;

#-------------------------------------------------------

func SetFlickerComponentActive(abX) -> void:
	if (is_instance_valid(FlickerComponent)):
		FlickerComponent.SetActive(abX);

#-------------------------------------------------------

func GetFlickerComponentActive() -> bool:
	return is_instance_valid(FlickerComponent) && FlickerComponent.GetActive();

#-------------------------------------------------------
