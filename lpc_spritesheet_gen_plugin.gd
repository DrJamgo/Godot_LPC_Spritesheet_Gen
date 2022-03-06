tool
extends EditorPlugin

var inspector_plugin

func _enter_tree():
    var LPCSpiteInspector = load("res://addons/lpc_spritesheet_gen/LPCSpriteInstector.gd")
    inspector_plugin = LPCSpiteInspector.new()

    add_inspector_plugin(inspector_plugin)

func _exit_tree():
    remove_inspector_plugin(inspector_plugin)
