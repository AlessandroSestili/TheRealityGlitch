shader_type canvas_item;

/// Glitch Shader — aberrazione cromatica + distorsione UV basata su instabilità.
/// Parametro `instability` va da 0.0 (nessun effetto) a 1.0 (massimo caos).

uniform float instability : hint_range(0.0, 1.0) = 0.0;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

// Pseudo-random noise
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    float t = TIME + time_offset;
    float glitch_strength = instability * 0.04;

    // Aberrazione cromatica
    float aberration = instability * 0.006;
    vec4 r = texture(TEXTURE, UV + vec2(aberration, 0.0));
    vec4 g = texture(TEXTURE, UV);
    vec4 b = texture(TEXTURE, UV - vec2(aberration, 0.0));

    // Distorsione scan-line orizzontale
    float scan_noise = rand(vec2(UV.y * 50.0, floor(t * 8.0))) * glitch_strength;
    vec2 distorted_uv = UV + vec2(scan_noise, 0.0);

    vec4 base = texture(TEXTURE, distorted_uv);

    // Mischia aberrazione con base proporzionalmente all'instabilità
    COLOR = mix(base, vec4(r.r, g.g, b.b, base.a), instability * 0.6);

    // Flash di rumore digitale alle soglie alte
    if (instability > 0.75) {
        float noise = rand(UV + vec2(t * 0.1));
        if (noise > 0.97) {
            COLOR = vec4(1.0, 1.0, 1.0, 1.0);  // Pixel bianco casuale
        }
    }
}
