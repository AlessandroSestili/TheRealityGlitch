shader_type canvas_item;

/// Screen Glitch — applicato al CanvasLayer globale.
/// Si attiva a soglie di instabilità specifiche (25%, 50%, 75%, 100%).

uniform float instability : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    float t = TIME;

    // Soglia 25%: leggero jitter verticale
    if (instability >= 0.25) {
        float jitter = (rand(vec2(floor(uv.y * 30.0), floor(t * 5.0))) - 0.5) * 0.005 * instability;
        uv.x += jitter;
    }

    // Soglia 50%: blocchi di distorsione orizzontale
    if (instability >= 0.5) {
        float block_y = floor(uv.y * 20.0);
        float block_t = floor(t * 3.0);
        if (rand(vec2(block_y, block_t)) > 0.92) {
            uv.x += (rand(vec2(block_y * 2.0, block_t)) - 0.5) * 0.08 * instability;
        }
    }

    vec4 color = texture(SCREEN_TEXTURE, uv);

    // Soglia 75%: aberrazione cromatica schermo intero
    if (instability >= 0.75) {
        float shift = 0.008 * instability;
        float r = texture(SCREEN_TEXTURE, uv + vec2(shift, 0.0)).r;
        float b = texture(SCREEN_TEXTURE, uv - vec2(shift, 0.0)).b;
        color = vec4(r, color.g, b, color.a);
    }

    // Soglia 100%: vignette rossa + inversione parziale
    if (instability >= 1.0) {
        float vignette = 1.0 - smoothstep(0.4, 0.9, length(uv - vec2(0.5)));
        color.r = mix(color.r, 1.0 - color.r, 0.3 * vignette);
    }

    COLOR = color;
}
