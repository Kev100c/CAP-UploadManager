extends WindowIndexed

var mod_root = get_script().resource_path.get_base_dir().path_join("../..").simplify_path()
var _slot_script = load(mod_root.path_join("scripts/CAP_SlotClass.gd")) as Script

@onready var upload: = $PanelContainer / MainContainer / Upload
@onready var result: = $PanelContainer / MainContainer / Result
@onready var infections: = $PanelContainer / MainContainer / Infections
@onready var audio_player: = $AudioStreamPlayer2D
@onready var slot: Array = [
        _slot_script.new(
            $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer / File,
            $PanelContainer/MainContainer/ResourceContainer/RatioButton,
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress2 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress2 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer2 / File,
            $PanelContainer/MainContainer/ResourceContainer2/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress3 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress3 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer3 / File,
            $PanelContainer/MainContainer/ResourceContainer3/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress4 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress4 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer4 / File,
            $PanelContainer/MainContainer/ResourceContainer4/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress5 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress5 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer5 / File,
            $PanelContainer/MainContainer/ResourceContainer5/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress6 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress6 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer6 / File,
            $PanelContainer/MainContainer/ResourceContainer6/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress7 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress7 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer7 / File,
            $PanelContainer/MainContainer/ResourceContainer7/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress8 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress8 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer8 / File,
            $PanelContainer/MainContainer/ResourceContainer8/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress9 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress9 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer9 / File,
            $PanelContainer/MainContainer/ResourceContainer9/RatioButton
            ),
        _slot_script.new(
            $PanelContainer / MainContainer / Progress10 / ProgressContainer / ProgressLabel,
            $PanelContainer / MainContainer / Progress10 / ProgressBar,
            $PanelContainer / MainContainer / ResourceContainer10 / File,
            $PanelContainer/MainContainer/ResourceContainer10/RatioButton
            ),
    ]



var prioLists: Array[Array]
var prioListInSet = false
var progressListForSave: Array

func _ready() -> void :
    if prioLists.size() != 0:
        prioListInSet = true
        for i in range(prioLists.size()):
            for n in range(prioLists[i].size()):
                slot[prioLists[i][n]].ratioButton.value = i
        prioListInSet = false
    if progressListForSave.size() != 0:
        for i in range(progressListForSave.size()-1):
            slot[i].progress = progressListForSave[i]
    progressListForSave.resize(0)
    super ()
    update_type()
    _on_ratio_change(0)
    update_visible_inputs()

func _process(delta: float) -> void :
    super (delta)
    for i in range(slot.size()):
        slot[i].progress_bar.value = lerpf(slot[i].progress_bar.value,slot[i].progress / slot[i].goal,1.0 - exp(-50.0 * delta))
        slot[i].progress_label.text = Utils.print_metric(slot[i].progress,false)+ "b"


func process(delta: float) -> void :
        
    if slot.size() != 0:
        for index in slot.size():
            if slot[index-1].file.count < 1:
                slot[index-1].progress = 0
                
    pps()
    process_upload(delta)


func update_type() -> void :
    if infections.count > 0:
        infections.visible = true
    else:
        infections.visible = false
    for i in range(slot.size()):
        slot[i].multipliers.clear()
        if Data.files.has(slot[i].file.resource):
            slot[i].goal = Utils.get_file_size(slot[i].file.resource, slot[i].file.variation) * Attributes.get_attribute("upload_size_multiplier")
            slot[i].base_value = Utils.get_file_value(slot[i].file.resource, slot[i].file.variation)
            if slot[i].file.variation & Utils.file_variations.HACKED:
                slot[i].base_infection = Data.files[slot[i].file.resource].research * Utils.get_variation_value_multiplier(slot[i].file.variation)
            else:
                slot[i].base_infection = 0

            if result.resource == "money":
                if slot[i].file.variation & Utils.file_variations.AI:
                    slot[i].multipliers.append(Data.files[slot[i].file.resource].ai_attribute)
                else:
                    slot[i].multipliers.append(Data.files[slot[i].file.resource].attribute)
        else:
            slot[i].goal = 1
            slot[i].base_value = 0

        if slot[i].file.variation & Utils.file_variations.HACKED:
            infections.visible = true
        ### $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(slot[i].goal, false) + "b"
        slot[i].progress_label.get_parent().get_node("SizeLabel").text = Utils.print_metric(slot[i].goal, false) + "b"

func _on_file_resource_set_index(index: int) -> void:
    slot[index].progress = 0
    if !slot[index].file.resource.is_empty():
        result.set_resource(Data.files[slot[index].file.resource].upload)

    update_type()
    
func _on_upload_size_changed() -> void :
    update_type()
    
func _on_ratio_change(value:float) -> void:
    if prioListInSet:
        return
    prioLists.resize(0)
    prioLists.resize(11)
    for i in range( slot.size()):
        prioLists[slot[i].ratioButton.value].append(i)
        
func update_visible_inputs() -> void :
    for index in range(slot.size()-1):
        if !slot[index].file.get_node("InputConnector").has_connection() && !slot[index+1].file.get_node("InputConnector").has_connection() && slot[index+1].file.count == 0 && slot[index].file.count == 0:
            slot[index+1].file.set_resource("")
            slot[index+1].set_Visible(false)
        else:
            slot[index+1].set_Visible(true)

func save() -> Dictionary:
    progressListForSave.resize(0)
    for index in range(slot.size()-1):
        progressListForSave.append(slot[index].progress)
    var su = super()
    su["filename"] = "../../".path_join(ModLoaderMod.get_mod_data("CAP-UploadManager").dir_path.trim_prefix("res://")).path_join("scenes/windows/window_upload_manager.tscn")
    
    
    
    return su.merged({
        "prioLists":prioLists,
        "progressListForSave":progressListForSave,
    })

func _on_file_connection_in_set() -> void:
    update_visible_inputs()

    
#sets the production per second
func pps() -> void:
    var demand: Array
    var supply = upload.count
    var remainingSupply = supply
    var infection = 0
    var production = 0
    var percent:float
    
    if (supply == 0 || supply == null) && upload.get_child(0).get_child(1).text != "0.00bps":
        return
    
    demand.resize(prioLists.size())
    for prio in range(prioLists.size() -1,-1,-1):   
        if prioLists[prio].size() == 0:
            continue
            
        for index in range(prioLists[prio].size()):
            if !slot[prioLists[prio][index]].isVisible():
                continue
            if demand[prio] == null:
                demand[prio] = 0
            slot[prioLists[prio][index]].update()
            demand[prio] = demand[prio] + slot[prioLists[prio][index]].demandWhenEmpty
            
        if demand[prio] <= remainingSupply:
            remainingSupply -= demand[prio]
            percent = 1
        else:
            percent = remainingSupply / demand[prio]
            remainingSupply = 0
        
        for index in range(prioLists[prio].size()):
            var slotIndex = prioLists[prio][index]
            production += slot[slotIndex].base_value * slot[slotIndex].file.production * percent  * slot[slotIndex].multiplier
            infection += slot[slotIndex].base_infection * slot[slotIndex].file.production * percent  * slot[slotIndex].multiplier
            
        if remainingSupply <= 0:
            break
    
    
    infections.production = infection
    result.production = production
    
func process_upload(delta) -> void:
    var demand: Array
    var supply = upload.count * delta
    var remainingSupply = supply
    for prio in range(prioLists.size()-1,-1,-1):
        var needy = 0
        demand.resize(prioLists[prio].size())
        for index in range(prioLists[prio].size()):
            var slotIndex = prioLists[prio][index]
            slot[slotIndex].update()
            if (slot[slotIndex].minCount >= slot[slotIndex].file.count):
                demand[index]=0
                continue
            demand[index] = slot[slotIndex].file.count * slot[slotIndex].goal
            needy += 1
            if demand[index] == null:
                demand[index] = 0
        
        if needy == 0 || needy == null:
            continue
        
        var demandSum = 0
        for n in range(demand.size()):
            demandSum += demand[n]
            
        var percent = 1
        if demandSum > remainingSupply:
            percent = remainingSupply / demandSum
            
        for index in range(prioLists[prio].size()):
            var slotIndex = prioLists[prio][index]
            var _slot = slot[slotIndex]
            if (_slot.minCount >= _slot.file.count):
                continue
                
            _slot.progress += demand[index] * percent
            if _slot.progress > _slot.goal:
                _slot.multiplier = 1.0
                for i: String in _slot.multipliers:
                    _slot.multiplier *= Attributes.get_attribute(i)
                var count: float = _slot.file.pop(floorf(_slot.progress / _slot.goal))
                var value: float = count * _slot.base_value * _slot.multiplier
                var infected: float = count * _slot.base_infection * Attributes.get_attribute("infection_multiplier")
                result.add(value)
                infections.add(infected)
                if result.resource == "money":
                    Globals.max_money += value
                    Globals.stats.max_money += value
                Globals.stats.uploads += count
                
                Signals.uploaded.emit(_slot.file, count)
                _slot.progress = fmod(_slot.progress, _slot.goal)
                audio_player.play()
                if is_processing():
                    result.animate_icon_in()
                    infections.animate_icon_in()
            
        remainingSupply -= demandSum
        if remainingSupply < 1:
            remainingSupply = 0
            break
    
#region OutDated
# Returns the contents of the priority list in the order Max -> Min.
func prioOrder() -> Array:
    if prioLists.size() == 0:
        return []
    var array: Array
    for prioIndex in range(prioLists.size()-1,-1,-1):
        if prioLists[prioIndex].size() == 0:
            continue
        for index in range(prioLists[prioIndex].size()-1):
            array.append(prioLists[prioIndex][index])
            
    return array
#endregion
    
    
    
    
    
    
    
    
    
    
