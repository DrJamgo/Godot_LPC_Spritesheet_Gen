@tool
## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

extends EditorPlugin

var inspector_plugin

func _enter_tree():
	var LPCSpiteInspector = preload("internal/lpc_sprite_inspector.gd")
	inspector_plugin = LPCSpiteInspector.new()
	#inspector_plugin.editor_interface = get_editor_interface()
	print_debug("editor entertree")
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	print_debug("editor exittree")
	remove_inspector_plugin(inspector_plugin)
