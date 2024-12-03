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

## If true the flicker animations play in the edit mode as well as when the game is running. 
@export var AnimateInTheEditor: bool = true;
## Animation speed
@export var AnimationSpeed: float = 1.0;
## Flicker animation table preset.
@export var AnimationTable: AnimationTablePreset = AnimationTablePreset.FluorescentFlicker;
## Define the flicker animation by typing in a sequence made out of any characters from a to z. a = zero brightnness, m = normal brightness, z = double brightness. 
@export var CustomAnimationTable: String = "": set = SetCustomAnimationTable, get = GetCustomAnimationTable;
## Set the animation time offset between two lights running the same animation table. 
@export var AnimationTimeOffset: float = 0.0 : set = SetAnimationTimeOffset, get = GetAnimationTimeOffset;
## Whether fade is applied between teh flicker values.
@export var Fade: bool = false;
## The fade speed if Fade is true.
@export var FadeSpeed: float = 30.0 : set = SetFadeSpeed, get = GetFadeSpeed;

#-------------------------------------------------------
# PROPERTIES
#-------------------------------------------------------

var mfTimePassed: float = 0.0;
var mpSPB: StreamPeerBuffer = StreamPeerBuffer.new();
var mfPreviousValue: float = 1.0;

#-------------------------------------------------------
# MAIN CALLBACKS
#-------------------------------------------------------

#-------------------------------------------------------
# SAVE/LOAD
#-------------------------------------------------------

func GetSaveData()-> Dictionary:
	var dData: Dictionary = super.GetSaveData();
	
	dData["AnimationTable"] = GetCustomAnimationTable();
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
	
	if (adData.has("AnimationTable")): SetCustomAnimationTable(adData["AnimationTable"]);
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

func SetAnimationTimeOffset(afX:float)->void:
	AnimationTimeOffset = afX;
	
func GetAnimationTimeOffset()->float:
	return AnimationTimeOffset;

#-------------------------------------------------------

func SetCustomAnimationTable(asX:String)->void:
	CustomAnimationTable = asX;
	
func GetCustomAnimationTable()->String:
	return CustomAnimationTable;

#-------------------------------------------------------

func GetFlickerValue(afTimeStep: float) -> float:
	#########################
	# Skip flicker if inactive
	if (Active==false): return 1.0;
	if (Engine.is_editor_hint() && AnimateInTheEditor==false): return 1.0;
	
	var sAnimType : String = "m";
	
	# 1 FLICKER (first variety)
	if (AnimationTable==AnimationTablePreset.Flicker1):
		sAnimType = "mmnmmommommnonmmonqnmmo";
	# 2 SLOW STRONG PULSE
	elif (AnimationTable==AnimationTablePreset.SlowStrongPulse):
		sAnimType = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
	# 3 CANDLE (first variety)
	elif (AnimationTable==AnimationTablePreset.Candle1):
		sAnimType = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
	# 4 FAST STROBE
	elif (AnimationTable==AnimationTablePreset.FastStrobe):
		sAnimType = "mamamamamama";
	# 5 GENTLE PULSE 1
	elif (AnimationTable==AnimationTablePreset.GentlePulse1):
		sAnimType = "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
	# 6 FLICKER (second variety)
	elif (AnimationTable==AnimationTablePreset.Flicker2):
		sAnimType = "nmonqnmomnmomomno";
	# 7 CANDLE (second variety)
	elif (AnimationTable==AnimationTablePreset.Candle2):
		sAnimType = "mmmaaaabcdefgmmmmaaaammmaamm";
	# 8 CANDLE (third variety)
	elif (AnimationTable==AnimationTablePreset.Candle3):
		sAnimType = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
	# 9 SLOW STROBE (fourth variety)
	elif (AnimationTable==AnimationTablePreset.SlowStrobe):
		sAnimType = "aaaaaaaazzzzzzzz";
	# 10 FLUORESCENT FLICKER
	elif (AnimationTable==AnimationTablePreset.FluorescentFlicker):
		sAnimType = "mmamammmmammamamaaamammma";
	# 11 SLOW PULSE NOT FADE TO BLACK
	elif (AnimationTable==AnimationTablePreset.SlowPulse):
		sAnimType = "abcdefghijklmnopqrrqponmlkjihgfedcba";
	# CUSTOM
	elif (AnimationTable==AnimationTablePreset.Custom):
		sAnimType = CustomAnimationTable;
	
	if (sAnimType.is_empty()): return 1.0;
	
	################################
	# Get flicker brightness level
	mfTimePassed += afTimeStep;
	var fTimePassed: float = AnimationTimeOffset + mfTimePassed;
	var lFrame: int = int(fTimePassed * (AnimationSpeed * 10.0));
	var lChar: int = lFrame % sAnimType.length();
	
	################################
	# Get value from string
	mpSPB.data_array = sAnimType[lChar].to_wchar_buffer();
	var lInt1: int = mpSPB.get_8();
	
	mpSPB.data_array = "a".to_wchar_buffer();
	var lInt2: int = mpSPB.get_8();
	
	################################
	# Scaling factor of 2/25 to map 0-25 range to 0-2
	var fScalingFactor: float = (2.0 / 25.0)
	var fTargetValue: float = float(lInt1 - lInt2) * fScalingFactor
	
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
