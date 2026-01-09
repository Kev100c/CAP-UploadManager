extends Node


const MOD_DIR := "CAP-UploadManager"
const LOG_NAME := "CAP-UploadManager:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""

var windows_dir_path := ""
var icons_dir_path := ""


func _init() -> void:
    mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)
    #ModLoaderMod.get_unpacked_dir().path_join("CAP-UploadManager")
    var slot_script: Script = load(mod_dir_path.trim_prefix("res://").path_join("scripts/CAP_SlotClass.gd"))
    ModLoaderLog.info(str(slot_script),"FICKEN")
    
    # Add extensions
    install_script_extensions()
    install_script_hook_files()

    # Add translations
    add_translations()
    
    
    windows_dir_path = "../../"+mod_dir_path.trim_prefix("res://").path_join("scenes/windows")
    icons_dir_path = "../../"+mod_dir_path.trim_prefix("res://").path_join("textures/icons")


func install_script_extensions() -> void:
    extensions_dir_path = mod_dir_path.path_join("extensions")




func install_script_hook_files() -> void:
    extensions_dir_path = mod_dir_path.path_join("extensions")


func add_translations() -> void:
    translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
    if !has_node("/root/Data"):
        ModLoaderLog.error("No data singleton found!", LOG_NAME)
        return
    _add_to_data()  
    ModLoaderLog.info(windows_dir_path,LOG_NAME)
    


func _add_to_data() -> void:
    if !Data.windows.has("upload_manager"):
        Data.windows["upload_manager"] = {
            "name": "Upload Manager",
            "icon": icons_dir_path.path_join("double_save"),
            "description": "Expansion of the uploader.\nConfigurable prioritization and parallel uploading.",
            "scene": windows_dir_path.path_join("window_upload_manager"),
            "group": "",
            "category": "network",
            "sub_category": "upload",
            "level": 0,
            "requirement": "",
            "hidden": true,
            "attributes":{
                "limit": -1
            },
            "data": {},
            "guide": ""
        }
        ModLoaderLog.debug("Added window to the Data singleton", LOG_NAME)
    
    
    if !Attributes.window_attributes.has("upload_manager"):
        Attributes.window_attributes["upload_manager"] = {}
        for attr_name: String in Data.windows["upload_manager"].attributes:
            var attr_value = Data.windows["upload_manager"].attributes[attr_name]
            Attributes.window_attributes["upload_manager"][attr_name] = Attribute.new(attr_value)
        ModLoaderLog.debug("Initialized window attributes for upload_manager", LOG_NAME)
    ModLoaderLog.success("Added window to the game files", LOG_NAME)
