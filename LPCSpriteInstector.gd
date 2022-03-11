tool
extends EditorInspectorPlugin

var DockScene = preload("dock.tscn")
var json_files = null

var editor_interface : EditorInterface

func _init():
    json_files = DockScene.instance().read_json_files()

func can_handle(object : Object):
    if(object as LPCSprite):
        return true
    else:
        return false

func parse_property(object : Object, type : int, path : String, hint : int, hint_text : String, usage : int):
    #print("parse_property " + String(type) + ", " + path + ", " + String(usage) + ", ")
    if type == TYPE_OBJECT and path == 'frames' and (object.frames as LPCSpriteBlueprint):
        var dockinstance = DockScene.instance()
        dockinstance.editor_interface = editor_interface
        dockinstance.set_json_files(json_files)
        dockinstance.set_blueprint(object.frames)
        add_custom_control(dockinstance)    
    return false

