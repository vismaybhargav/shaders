float gray(vec4 fragColor) {
    return (fragColor.x + fragColor.y + fragColor.z) / 3.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    vec2 pixel_size = 1.0 / iResolution.xy;

    // Gettin all the Pixels! 
    float tL = gray(texture(iChannel0, uv + vec2(-pixel_size.x, pixel_size.y)));
    float tR = gray(texture(iChannel0, uv + vec2( pixel_size.x, pixel_size.y)));
    float t  = gray(texture(iChannel0, uv + vec2( 0           , pixel_size.y)));

    float l = gray(texture(iChannel0, uv + vec2(-pixel_size.x, 0)));
    float r = gray(texture(iChannel0, uv + vec2( pixel_size.x, 0)));
    // Shouldn't need this
    //float c  = intensity(texture(iChannel0, uv + vec2( 0           , 0)));

    float bL = gray(texture(iChannel0, uv + vec2(-pixel_size.x, -pixel_size.y)));
    float bR = gray(texture(iChannel0, uv + vec2( pixel_size.x, -pixel_size.y)));
    float b  = gray(texture(iChannel0, uv + vec2(0            , -pixel_size.y)));

    // Sobel Kernel
    float gX = -tL - 2.0l - bL + tR + 2.0r + bR;
    float gY = tL + 2.0t + tR - bL - 2.0b - bR;

    // Gradient Magnitude
    float mag = sqrt(pow(gX, 2.0) + pow(gY, 2.0));

    fragColor = vec4(mag, mag, mag, 1.0);
}
