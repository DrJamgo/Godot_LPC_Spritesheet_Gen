tool
extends AnimatedSprite
class_name LPCSprite, "lpc_icon.png"

export(String, 'down','left','up','right') var dir = 'down' setget set_dir
export(String, 'idle', 'walk', 'cast', 'slash', 'thrust', 'hurt') var anim = 'idle' setget set_anim

var outline
var highlight

signal animation_trigger(anim)

func add_blueprint(blueprint : LPCSpriteBlueprint) -> Array:
    return add_layers(blueprint.layers)

func add_layers(layers : Array) -> Array:
    var sprite_array := Array()
    for layer in layers:
        sprite_array.append(_add_layer(layer))
    _on_LPCSprite_frame_changed()
    return sprite_array

func _load_layers():
    print(name + "_load_layers")
    for c in get_children():
        if (c as Sprite):
            remove_child(c)
    var blueprint : LPCSpriteBlueprint = frames
    blueprint._set_atlas(null)
    for layer in blueprint.layers:
        var sprite = _add_layer(layer)
    _on_LPCSprite_frame_changed()

func _add_layer(layer : LPCSpriteLayer) -> Sprite:
    var new_sprite = preload("res://addons/lpc_spritesheet_gen/LPCSpriteLayer.tscn").instance()
    new_sprite.set_atlas(layer.texture)
    new_sprite.set_name(layer.type_name)
    new_sprite.offset = self.offset
    add_child(new_sprite)
    return new_sprite

func _enter_tree():
    frames.connect("changed", self, "_load_layers")
    _load_layers()
    set_outline()
    set_highlight()
    
func _exit_tree():
    frames.disconnect("changed", self, "_load_layers")
    pass

func set_outline(color = Color(0,0,0,0)):
    if has_node("body"):
        get_node("body").material.set_shader_param("outLineColor", color)

func set_highlight(color = Color(0,0,0,0)):
    if has_node("body"):
        get_node("body").material.set_shader_param("mixColor", color)

func move(direction : Vector2):
    var speed = direction.length()
    set_dir(direction)
    speed_scale = speed / 32
    if speed > 48:
        #anim = 'hustle'
        anim = 'walk'
    elif speed > 32:
        anim = 'walk'
    elif speed > 0:
        #anim = 'stroll'
        anim = 'walk'
    else:
        anim = 'idle'

func set_dir(direction):
    if typeof(direction) == TYPE_VECTOR2:
        direction = _angle_to_dir(direction.angle())
    dir = direction

func set_anim(_anim):
    if anim != _anim:
        anim = _anim
        speed_scale = 1.0

func _angle_to_dir(_angle):
    var seg1 = PI*2/8
    var seg2 = PI*6/8
    
    if _angle <= seg1 and _angle >= -seg1:
        return 'right'
    elif _angle > seg1 and _angle < seg2:
        return 'down'
    elif _angle <= -seg1 and _angle >= -seg2:
        return 'up'
    else:
        return 'left'

func _play(_anim):
    play(_anim)
    _on_LPCSprite_frame_changed()

var last_frames = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if last_frames and last_frames != frames:
        frames.connect("changed", self, "_load_layers")
        _load_layers()
    last_frames = frames
    var anim_name = anim + "_" + dir
    if animation != anim_name:
        if anim == 'hurt':
            dir = 'down'
            _play('hurt_down')
        else:
            _play(anim_name)

func _on_LPCSprite_frame_changed():
    var blueprint : LPCSpriteBlueprint = (frames as LPCSpriteBlueprint)
    var tex = blueprint.get_frame(self.animation, self.frame)
    for sprite in get_children():
        sprite.copy_atlas_rects(tex)

