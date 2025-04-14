@tool
class_name cLampComponent extends cComponentBase

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

@export_category("General")
## If true the lamp is lit. 
@export var Lit: bool = true : set = SetLit, get = GetLit;
## Controls the overall lamp energy levels (lights and materials).
@export var LampEnergy: float = 1.0 : set = SetLampEnergy, get = GetLampEnergy;
## Whether the light fades when toggled on and off.
@export var Fade: bool = false;
## The time it takes to fade if Fade is true.
@export var FadeSpeed: float = 30.0;
## Optional Flicker component.
@export var FlickerComponent: cFlickerComponent : get = GetFlickerComponent;

@export_category("Light Instancees")
## A list of light node instances to sync with the lamp state. 
@export var LightInstances: Array[Light3D] = [];
## Controls the lights energy levels only.
@export var LightEnergyMultiplier: float = 1.0 : set = SetLightEnergyMultiplier, get = GetLightEnergyMultiplier;

@export_category("Mesh Instances")
## A list of mesh node instances who's materials emission sync with the lamp state. 
@export var MeshInstances: Array[MeshInstance3D] = [];
## Controls the materials emission energy levels only.
@export var MaterialEnergyMultiplier: float = 1.0 : set = SetMaterialEnergyMultiplier, get = GetMaterialEnergyMultiplier;

@export_category("Particle Effects")
## Particle effects to draw while the lamp is Lit.
@export var Particles: Array[GPUParticles3D] = [];
## If true the particle effects emission levels are affected by the lamp's overall energy.
@export var EnergyAffectsParticleEmission : bool = true;
## The energy threshold below which particle effects will disappear. If the value is set to zero, particle effects will remain visible indefinitely.
@export var ParticleEnergyVisibilityThreshold : float = 0.1;

@export_category("Audio Effects")
## Audio effect played when the lamp is turned on.
@export var LampOnSound : AudioStreamPlayer3D = null;
## Audio effect played when the lamp is turned off.
@export var LampOffSound : AudioStreamPlayer3D = null;
## Audio effect playing in a loop for as long as the lamp is Lit.
@export var LampLoopSound : AudioStreamPlayer3D = null;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mbOldLit: bool = false;
var mbFlickering: bool = false;
var mfFlickerMultiplier: float = 1.0;
var mfCurrentLightEnergy: float = 1.0;
var mfDesiredLightEnergy: float = 1.0;
var mbIsInEditorMode: bool = false;

#-------------------------------------------------------
# MAIN CALLBACKS
#-------------------------------------------------------

func _ready() -> void:
	UpdateLampProperties();
	mbIsInEditorMode = Engine.is_editor_hint();

#-------------------------------------------------------

func _physics_process(afTimeStep: float) -> void:
	var bUpdateLampProperties: bool = false;
	
	#####################################
	# Handle Fading
	if (Fade && is_equal_approx(mfCurrentLightEnergy, mfDesiredLightEnergy)==false):
		mfCurrentLightEnergy = lerp(mfCurrentLightEnergy, mfDesiredLightEnergy, clamp(afTimeStep * FadeSpeed, 0.0, 1.0));
		bUpdateLampProperties = true;
	
	#####################################
	# Handle Flickering
	if (GetShouldFlicker()):
		if (Lit):
			mfFlickerMultiplier = FlickerComponent.GetFlickerValue(afTimeStep);
			bUpdateLampProperties = true;
			mbFlickering = true;
	elif (mbFlickering):
		mfFlickerMultiplier = 1.0;
		bUpdateLampProperties = true;
		mbFlickering = false;
	
	#####################################
	# Lamp properties update needed
	if (bUpdateLampProperties):
		UpdateLampProperties();

#-------------------------------------------------------
# SAVE/LOAD
#-------------------------------------------------------

func GetSaveData()-> Dictionary:
	var dData: Dictionary = super.GetSaveData();
	dData["Lit"] = GetLit();
	dData["LampEnergy"] = GetLampEnergy();
	dData["Fade"] = Fade;
	dData["FadeSpeed"] = FadeSpeed;
	dData["LightEnergyMultiplier"] = GetLightEnergyMultiplier();
	dData["MaterialEnergyMultiplier"] = GetMaterialEnergyMultiplier();
	dData["EnergyAffectsParticleEmission"] = EnergyAffectsParticleEmission;
	dData["ParticleEnergyVisibilityThreshold"] = ParticleEnergyVisibilityThreshold;
	dData["OldLit"] = mbOldLit;
	dData["Flickering"] = mbFlickering;
	dData["FlickerMultiplier"] = mfFlickerMultiplier;
	
	return dData;

#-------------------------------------------------------

func SetSaveData(adData: Dictionary)-> void:
	super.SetSaveData(adData);
	
	if (adData.has("Lit")): SetLit(adData["Lit"]);
	if (adData.has("LampEnergy")): SetLampEnergy(adData["LampEnergy"]);
	if (adData.has("Fade")): Fade = adData["Fade"];
	if (adData.has("FadeSpeed")): FadeSpeed = adData["FadeSpeed"];
	if (adData.has("LightEnergyMultiplier")): SetLightEnergyMultiplier(adData["LightEnergyMultiplier"]);
	if (adData.has("MaterialEnergyMultiplier")): SetMaterialEnergyMultiplier(adData["MaterialEnergyMultiplier"]);
	if (adData.has("EnergyAffectsParticleEmission")): EnergyAffectsParticleEmission = adData["EnergyAffectsParticleEmission"];
	if (adData.has("ParticleEnergyVisibilityThreshold")): ParticleEnergyVisibilityThreshold = adData["ParticleEnergyVisibilityThreshold"];
	if (adData.has("OldLit")): mbOldLit = adData["OldLit"];
	if (adData.has("Flickering")): mbFlickering = adData["Flickering"];
	if (adData.has("FlickerMultiplier")): mfFlickerMultiplier = adData["FlickerMultiplier"];
	

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
	if (GetFlickerComponentActive()==false): return false;
	
	if (mbIsInEditorMode && 
		FlickerComponent.has_method("GetAnimateInTheEditor") && # Sanity check. We get an error when in the editor about non-existing method otherwise sometimes. 
		FlickerComponent.GetAnimateInTheEditor()==false):
		return false;
	
	return true;

#-------------------------------------------------------

func UpdateLampProperties()->void:
	var fCurrentLightEnergy: float = GetCurrentLightEnergy();
	
	################################
	# Light Properties
	for pLight in LightInstances:
		if (is_instance_valid(pLight)==false): continue;
		pLight.light_energy = fCurrentLightEnergy * LightEnergyMultiplier;
		pLight.light_indirect_energy = fCurrentLightEnergy * LightEnergyMultiplier;
	
	################################
	# Material Properties
	for pMeshInst in MeshInstances:
		if (is_instance_valid(pMeshInst)==false): continue;
		for j in range(pMeshInst.get_surface_override_material_count()):
			var pMat: BaseMaterial3D = pMeshInst.get_surface_override_material(j);
			if (is_instance_valid(pMat)==false): continue;
			pMat.set_emission_energy_multiplier(fCurrentLightEnergy * MaterialEnergyMultiplier);
	
	################################
	# Particle Fx Properties
	for pParticleFx in Particles:
		if (is_instance_valid(pParticleFx)==false): continue;
		pParticleFx.emitting = true if (Lit) else false;
		
		if (EnergyAffectsParticleEmission):
			pParticleFx.visible = fCurrentLightEnergy > ParticleEnergyVisibilityThreshold;
			var pMat: BaseMaterial3D = pParticleFx.material_override;
			if (is_instance_valid(pMat)==false): continue;
			pMat.set_emission_energy_multiplier(fCurrentLightEnergy);

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
	#################################
	# Update the lamp's properties
	Lit = abX;
	mfDesiredLightEnergy = GetDesiredLightEnergy();
	
	#################################
	# Skip fading if disabled
	if (Fade==false):
		mfCurrentLightEnergy = mfDesiredLightEnergy;
	
	UpdateLampProperties();
	
	########################
	# Play sound
	if (abX):
		if (is_instance_valid(LampOnSound)): LampOnSound.play();
		if (is_instance_valid(LampLoopSound)): LampLoopSound.play();
	else:
		if (is_instance_valid(LampOffSound)): LampOffSound.play();
		if (is_instance_valid(LampLoopSound)): LampLoopSound.stop();

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
	mfCurrentLightEnergy = mfDesiredLightEnergy;
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

func SetMaterialEnergyMultiplier(afX:float)->void:
	MaterialEnergyMultiplier = afX;
	UpdateLampProperties();
	
#-------------------------------------------------------

func GetMaterialEnergyMultiplier()->float:
	return MaterialEnergyMultiplier;

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
