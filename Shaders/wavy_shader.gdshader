shader_type canvas_item;
render_mode world_vertex_coords, blend_mix;

// adjustable parameters
uniform float sway_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float sway_strength : hint_range(0.0, 0.2, 0.001) = 0.02;
uniform float sway_falloff : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float sway_origin : hint_range(0.0, 1.0, 0.01) = 0.0; // adjust this to the bottom of ur plant
uniform float sway_frequency = 10.0;

vec4 sampleTextureSmooth(sampler2D textureSampler, vec2 uvCoords, vec2 texelSize)
{
    vec2 screenDerivX = dFdx(uvCoords);
    vec2 screenDerivY = dFdy(uvCoords);
    vec2 gradientLength = sqrt(screenDerivX * screenDerivX + screenDerivY * screenDerivY);

    vec2 uvInPixels = uvCoords / texelSize;
    vec2 pixelCenter = round(uvInPixels) - vec2(0.5);
    vec2 offsetFromCenter = uvInPixels - pixelCenter;

    offsetFromCenter = clamp((offsetFromCenter - vec2(0.5)) * texelSize / gradientLength + vec2(0.5), 0.0, 1.0);
    vec2 adjustedUV = pixelCenter * texelSize;

    return textureGrad(textureSampler, adjustedUV + offsetFromCenter * texelSize, screenDerivX, screenDerivY);
}

varying flat vec4 modulate;

void vertex() {
    modulate = COLOR;
}

void fragment() {
    float t = TIME * sway_speed;
    float wave = sin(UV.y * sway_frequency + t);

    float flipped_y = 1.0 - UV.y;

    float relative_y = clamp((flipped_y - sway_origin) / (1.0 - sway_origin), 0.0, 1.0);
    float falloff = exp(-relative_y * sway_falloff);
    float dx = wave * sway_strength * (1.0 - falloff);

    vec2 swayedUV = UV + vec2(dx, 0.0);
    vec4 sampledColor = sampleTextureSmooth(TEXTURE, swayedUV, TEXTURE_PIXEL_SIZE);

    COLOR = vec4(sampledColor.rgb * modulate.rgb, sampledColor.a * modulate.a);
}
