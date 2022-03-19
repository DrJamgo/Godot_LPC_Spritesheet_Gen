shader_type canvas_item;
render_mode blend_mix;

uniform vec2 outLineSize  = vec2(0.00118,0.000744);
uniform vec4 outLineColor = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 mixColor     = vec4(1.0, 1.0, 1.0, 0.0);

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);
    bool doReplace = false;
    if (tcol.a < 1.0)
    {
        for(float y = 0.0; y <= outLineSize.y; y+=outLineSize.y) {
            for(float x = -outLineSize.x; x <= outLineSize.x; x+=outLineSize.x) {
                vec4 c = texture(TEXTURE, UV + vec2(x,y));
                if(c.a  == 1.0 && any(notEqual(c.rgb, vec3(0.0, 0.0, 0.0)))) {
                    doReplace = true;
                    break;
                }
            }
        }
        if(doReplace) {
            tcol = outLineColor;
        }
        else {
            discard;
        }
    }
    else {
        tcol = vec4(mix(tcol.rgb, mixColor.rgb, mixColor.a), tcol.a)
    }

    COLOR = tcol;
}
