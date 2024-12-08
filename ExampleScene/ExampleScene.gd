class_name cExampleScene extends Node3D

#-------------------------------------------------------

var mInfoLabel: RichTextLabel = null;

#-------------------------------------------------------

func _ready():
	#########################
	# Create a new Label to show the controls.
	mInfoLabel = RichTextLabel.new();
	mInfoLabel.bbcode_enabled = true;
	mInfoLabel.anchor_right = 1.0;
	mInfoLabel.anchor_bottom = 0.5;
	mInfoLabel.text = "[color=green]Controls[/color]
		Toggle lamp On/Off: Press [color=light_green]Space Bar[/color]";
	mInfoLabel.position = Vector2(10, 10);
	mInfoLabel.add_theme_color_override("font_color", Color(1, 1, 1));
	add_child(mInfoLabel);

#-------------------------------------------------------

func _input(aEvent):
	if (aEvent.is_action_pressed("ToggleLight")):
		var pLamp: cLampComponent = $Props/Lamps/Lantern/LampComponent;
		pLamp.ToggleLit();

#-------------------------------------------------------
