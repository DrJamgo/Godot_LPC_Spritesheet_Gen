## Copyright (C) 2023 Denis Selensky - All Rights Reserved
## You may use, distribute and modify this code under the terms of the MIT license

tool
extends EditorInspectorPlugin

var DockScene = preload("inspector_plugin_dock.tscn")
var json_files = null

var editor_interface : EditorInterface

func can_handle(object : Object):
	if(object as LPCSpriteBlueprint):
		return true
	else:
		return false

func parse_begin(object):
	if (object as LPCSpriteBlueprint):
		var dockinstance = DockScene.instance()
		dockinstance.editor_interface = editor_interface
		dockinstance.set_blueprint(object)
		add_custom_control(dockinstance)

func parse_property(object, type, path, hint, hint_text, usage):
	#if path == "layers":
	#	return true
	return false
