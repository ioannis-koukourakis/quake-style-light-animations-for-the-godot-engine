@tool
class_name cFlickerComponent extends cComponentBase

#-------------------------------------------------------

enum AnimationTablePreset{
	Flicker1,
	SlowStrongPulse,
	Candle1,
	FastStrobe,
	GentlePulse1,
	Flicker2,
	Candle2,
	Candle3,
	SlowStrobe,
	FluorescentFlicker,
	SlowPulse,
	Custom
}

#-------------------------------------------------------
# SETTINGS
#-------------------------------------------------------

@export_category("General")
## If true the flicker animations play in the edit mode as well as when the game is running. 
@export var AnimateInTheEditor: bool = true;
## Animation speed
@export var AnimationSpeed: float = 1.0;
## Flicker animation table preset.
@export var Preset: AnimationTablePreset = AnimationTablePreset.FluorescentFlicker;
## Define the flicker animation by typing in a sequence made out of any characters from a to z. a = zero brightnness, m = normal brightness, z = double brightness. 
@export var CustomAnimationTable: String = "": set = SetCustomAnimationTable, get = GetCustomAnimationTable;
## Set the animation time offset between two lights running the same animation table. 
@export var AnimationTimeOffset: float = 0.0 : set = SetAnimationTimeOffset, get = GetAnimationTimeOffset;
## Whether fade is applied between teh flicker values.
@export var Fade: bool = false;
## The fade speed if Fade is true.
@export var FadeSpeed: float = 30.0 : set = SetFadeSpeed, get = GetFadeSpeed;

@export_category("Audio Effects")
## ## If true the sound plays in the edit mode as well as when the game is running.
@export var PlaySoundsInTheEditor: bool = true;
## The sound to play when 'Sound A Trigger Character' is matched.
@export var SoundA : AudioStreamPlayer3D = null;
## Trigger character for playing Sound A
@export var SoundATriggerCharacter: String = "";
## The sound to play when 'Sound B Trigger Character' is matched.
@export var SoundB : AudioStreamPlayer3D = null;
## Trigger character for playing Sound B
@export var SoundBTriggerCharacter: String = "";

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mfTimePassed: float = 0.0;
var mpSPB: StreamPeerBuffer = StreamPeerBuffer.new();
var mfPreviousValue: float = 1.0;
var msPrevSoundTriggerCharacter_A: String = "";
var msPrevSoundTriggerCharacter_B: String = "";

#-------------------------------------------------------
# MAIN CALLBACKS
#-------------------------------------------------------

#-------------------------------------------------------
# SAVE/LOAD
#-------------------------------------------------------

func GetSaveData()-> Dictionary:
	var dData: Dictionary = super.GetSaveData();
	
	dData["Preset"] = Preset;
	dData["TimePassed"] = mfTimePassed;
	dData["AnimationSpeed"] = GetAnimationSpeed();
	dData["CustomAnimationTable"] = GetCustomAnimationTable();
	dData["AnimationTimeOffset"] = GetAnimationTimeOffset();
	dData["Fade"] = GetFade();
	dData["FadeSpeed"] = GetFadeSpeed();
	return dData;

#-------------------------------------------------------

func SetSaveData(adData: Dictionary)-> void:
	super.SetSaveData(adData);
	
	if (adData.has("Preset")): Preset = adData["Preset"];
	if (adData.has("TimePassed")): mfTimePassed = adData["TimePassed"];
	if (adData.has("AnimationSpeed")): SetAnimationSpeed(adData["AnimationSpeed"]);
	if (adData.has("CustomAnimationTable")): SetCustomAnimationTable(adData["AnimationTable"]);
	if (adData.has("AnimationTimeOffset")): SetAnimationTimeOffset(adData["AnimationTimeOffset"]);
	if (adData.has("Fade")):SetFade(adData["Fade"]);
	if (adData.has("FadeSpeed")): SetFadeSpeed(adData["FadeSpeed"]);

#-------------------------------------------------------
# LOCAL
#-------------------------------------------------------

#-------------------------------------------------------
# PUBLIC
#-------------------------------------------------------

func GetFlickerValue(afTimeStep: float) -> float:
	#########################
	# Skip flicker if inactive
	if (Active==false): return 1.0;
	if (Engine.is_editor_hint() && AnimateInTheEditor==false): return 1.0;
	
	var sAnimType : String = "m";
	
	# 1 FLICKER (first variety)
	if (Preset==AnimationTablePreset.Flicker1):
		sAnimType = "mmnmmommommnonmmonqnmmo";
		#CustomAnimationTable = sAnimType;
	# 2 SLOW STRONG PULSE
	elif (Preset==AnimationTablePreset.SlowStrongPulse):
		sAnimType = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
		#CustomAnimationTable = sAnimType;
	# 3 CANDLE (first variety)
	elif (Preset==AnimationTablePreset.Candle1):
		sAnimType = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
		#CustomAnimationTable = sAnimType;
	# 4 FAST STROBE
	elif (Preset==AnimationTablePreset.FastStrobe):
		sAnimType = "mamamamamama";
		#CustomAnimationTable = sAnimType;
	# 5 GENTLE PULSE 1
	elif (Preset==AnimationTablePreset.GentlePulse1):
		sAnimType = "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
		#CustomAnimationTable = sAnimType;
	# 6 FLICKER (second variety)
	elif (Preset==AnimationTablePreset.Flicker2):
		sAnimType = "nmonqnmomnmomomno";
		#CustomAnimationTable = sAnimType;
	# 7 CANDLE (second variety)
	elif (Preset==AnimationTablePreset.Candle2):
		sAnimType = "mmmaaaabcdefgmmmmaaaammmaamm";
		#CustomAnimationTable = sAnimType;
	# 8 CANDLE (third variety)
	elif (Preset==AnimationTablePreset.Candle3):
		sAnimType = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
		#CustomAnimationTable = sAnimType;
	# 9 SLOW STROBE (fourth variety)
	elif (Preset==AnimationTablePreset.SlowStrobe):
		sAnimType = "aaaaaaaazzzzzzzz";
		#CustomAnimationTable = sAnimType;
	# 10 FLUORESCENT FLICKER
	elif (Preset==AnimationTablePreset.FluorescentFlicker):
		sAnimType = "mmamammmmammamamaaamammma";
		#CustomAnimationTable = sAnimType;
	# 11 SLOW PULSE NOT FADE TO BLACK
	elif (Preset==AnimationTablePreset.SlowPulse):
		sAnimType = "abcdefghijklmnopqrrqponmlkjihgfedcba";
		#CustomAnimationTable = sAnimType;
	# CUSTOM
	elif (Preset==AnimationTablePreset.Custom):
		sAnimType = CustomAnimationTable;
	
	if (sAnimType.is_empty()): return 1.0;
	
	################################
	# Get flicker brightness level
	mfTimePassed += afTimeStep;
	var fTimePassed: float = AnimationTimeOffset + mfTimePassed;
	var lFrame: int = int(fTimePassed * (AnimationSpeed * 10.0));
	var lChar: int = lFrame % sAnimType.length();
	
	################################
	# Play Sound
	if ((Engine.is_editor_hint() && PlaySoundsInTheEditor) || Engine.is_editor_hint()==false):
		if (SoundATriggerCharacter.is_empty()==false && is_instance_valid(SoundA)):
			if (sAnimType[lChar] == SoundATriggerCharacter && msPrevSoundTriggerCharacter_A != SoundATriggerCharacter):
				SoundA.play();
			msPrevSoundTriggerCharacter_A = sAnimType[lChar];
		
		if (SoundBTriggerCharacter.is_empty()==false && is_instance_valid(SoundB)):
			if (sAnimType[lChar] == SoundBTriggerCharacter && msPrevSoundTriggerCharacter_B != SoundBTriggerCharacter):
				SoundB.play();
			msPrevSoundTriggerCharacter_B = sAnimType[lChar];

	################################
	# Get value from string
	mpSPB.data_array = sAnimType[lChar].to_wchar_buffer();
	var lInt1: int = mpSPB.get_8();
	
	mpSPB.data_array = "a".to_wchar_buffer();
	var lInt2: int = mpSPB.get_8();
	
	################################
	# Scaling factor of 2/25 to map 0-25 range to 0-2
	var fScalingFactor: float = (2.0 / 25.0);
	var fTargetValue: float = float(lInt1 - lInt2) * fScalingFactor;
	
	################################
	# Apply fade if enabled
	var fResult: float = 1.0;
	if (Fade):
		fResult = lerpf(mfPreviousValue, fTargetValue, afTimeStep * FadeSpeed);
	else:
		fResult = fTargetValue;
	
	mfPreviousValue = fResult;
	
	return fResult

#-------------------------------------------------------

func SetAnimationTimeOffset(afX:float)->void:
	AnimationTimeOffset = afX;

#-------------------------------------------------------

func GetAnimationTimeOffset()->float:
	return AnimationTimeOffset;

#-------------------------------------------------------

func SetCustomAnimationTable(asX:String)->void:
	CustomAnimationTable = asX;

#-------------------------------------------------------

func GetCustomAnimationTable()->String:
	return CustomAnimationTable;

#-------------------------------------------------------

func SetFade(abX) -> void:
	Fade = abX;

#-------------------------------------------------------

func GetFade() -> bool:
	return Fade;

#-------------------------------------------------------

func SetFadeSpeed(afX: float) -> void:
	FadeSpeed = max(0.001, afX);

#-------------------------------------------------------

func GetFadeSpeed() -> float:
	return FadeSpeed;

#-------------------------------------------------------

func GetAnimateInTheEditor() -> bool:
	return AnimateInTheEditor;

#-------------------------------------------------------

func SetAnimationSpeed(afX: float) -> void:
	AnimationSpeed = afX;

#-------------------------------------------------------

func GetAnimationSpeed() -> float:
	return AnimationSpeed;

#-------------------------------------------------------
