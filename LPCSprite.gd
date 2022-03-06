extends AnimatedSprite

class_name LPCSprite, "lpc_icon.png"

var dir = 'down'
var anim = 'idle' setget set_anim
var angle = 0

var outline
var highlight
var baked 

signal animation_trigger(anim)

func _init():
    pass

func _add_layer(name : String, texture : Texture) -> Sprite:
    var new_sprite = Sprite.new()
    var new_atlas := AtlasTexture.new()
    new_atlas.atlas = texture
    new_sprite.set_texture(new_atlas)
    new_sprite.offset = self.offset
    new_sprite.centered = false
    new_sprite.set_name(name)
    add_child(new_sprite)
    return new_sprite

# Called when the node enters the scene tree for the first time.
func _enter_tree():
    var blueprint : LPCSpriteBlueprint = frames
    var texture = blueprint.get_textures()[0]
    blueprint._set_atlas(null)
    baked = _add_layer('baked', blueprint.get_baked())
    baked.material = ShaderMaterial.new()
    baked.material.shader = preload("res://res/outline.shader")
    baked.material.set_shader_param("outLineSize", Vector2(1,1) / Vector2(texture.get_size()))
    baked.material.set_shader_param("outLineColor", Color(0,0,0,0))
    baked.use_parent_material = false
    set_outline()
    set_highlight()
    
    for layer in blueprint.layers:
        _add_layer(layer.type_name, layer.texture)

func set_outline(color = Color(0,0,0,0)):
    baked.material.set_shader_param("outLineColor", color)

func set_highlight(color = Color(0,0,0,0)):
    highlight = color
    baked.material.set_shader_param("mixColor", color)

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

func set_dir(direction : Vector2):
    dir = _angle_to_dir(direction.angle())

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var anim_name = anim + "_" + dir
    if animation != anim_name:
        if anim == 'hurt':
            dir = 'down'
            _play('hurt_down')
        else:
            _play(anim_name)
    pass

func _on_LPCSprite_frame_changed():
    var blueprint : LPCSpriteBlueprint = (frames as LPCSpriteBlueprint)
    var tex = blueprint.get_frame(self.animation, self.frame)
    for sprite in get_children():
        (sprite.texture as AtlasTexture).region = tex.region
        (sprite.texture as AtlasTexture).margin = tex.margin

