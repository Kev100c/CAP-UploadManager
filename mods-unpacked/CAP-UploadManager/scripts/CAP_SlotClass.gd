extends RefCounted

class_name Slot

var progress_label
var progress_bar
var file
var ratioButton
var progress: float
var goal: float = 5
var base_value: float
var base_infection: float
var multipliers: Array[String]
var multiplier: float
var _visible = true

func set_Visible(value:bool):
    _visible = value
    file.get_parent().visible = _visible
    progress_bar.get_parent().visible = _visible

func _init(_progress_label,_progress_bar,_file,_ratioButton) -> void :
    progress_label = _progress_label
    progress_bar = _progress_bar
    file = _file
    ratioButton = _ratioButton
    
func safe() -> void:
    return 
