tool
extends EditorPlugin

var inspector_plugin

func _enter_tree():
	var LPCSpiteInspector = load("internal/LPCSpriteInstector.gd")
	inspector_plugin = LPCSpiteInspector.new()
	inspector_plugin.editor_interface = get_editor_interface()

	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
