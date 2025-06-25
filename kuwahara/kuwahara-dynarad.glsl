const int RADIUS = 2;
const int QUADRANT_SIZE = (RADIUS + 1) * (RADIUS + 1);

// Converts a rgb value to a hsv value
// https://www.geeksforgeeks.org/utilities/hsv-to-rgb-converter/
vec3 rgb2hsv(vec3 rgb) {
    float rPrime = rgb.r;
    float gPrime = rgb.g;
    float bPrime = rgb.b;

    float cMax = max(rPrime, max(gPrime, bPrime));
    float cMin = min(rPrime, min(gPrime, bPrime));
    float delta = cMax - cMin;

    // TODO: Figure out how to fix the branching here.
    float h;
    if(delta == 0.) {
        h = 0.;
    } else if(cMax == rPrime) {
        h = mod(60. * ((gPrime - bPrime) / delta) + 360., 360.);
    } else if(cMax == gPrime) {
        h = mod(60. * ((bPrime - rPrime) / delta) + 120., 360.);
	} else if(cMax == bPrime) {
        h = mod(60. * ((rPrime - gPrime) / delta) + 240., 360.0);
	}
	
	float s;
	if(cMax == 0.) {
		s = 0.;
	} else {
		s = (delta / cMax) * 100.;
	}

	float v = cMax * 100.;

	return vec3(h, s, v);
}

// Converts a hsv value to a rgb value
// https://www.diversifyindia.in/hsv-to-rgb-converter/
vec3 hsv2rgb(vec3 hsv) {
    float h = mod(hsv.x, 360.);
    float s = hsv.y;
    float v = hsv.z;
    
    
    float chroma = s * v;
    float x = chroma * (1. - abs(mod(h / 60., 2.) - 1.));
    float match = v - chroma;
    
    float r;
    float g;
    float b;
    
    if(h >= 0. && h < 60.) {
        r = chroma;
        g = x;
        b = 0.;
    } else if(h >= 60. && h < 120.) {
        r = x;
        g = chroma;
        b = 0.;
    } else if(h >= 120. && h < 180.) {
        r = 0.;
        g = chroma;
        b = x;
    } else if(h >= 180. && h < 240.) {
        r = 0.;
        g = x;
        b = chroma;
    } else if(h >= 240. && h < 300.) {
        r = x;
        g = 0.;
        b = chroma;
    } else if(h >= 300. &&h < 360.) {
        r = chroma;
        g = 0.;
        b = x;
    }

    r += match;
    g += match;
    b += match;
    
    return vec3(r, g, b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;

    vec3 means[4] = vec3[4](
        vec3(0.),
        vec3(0.),
        vec3(0.),
        vec3(0.)
    );
    
    vec3 variance[4] = vec3[4](
        vec3(0.),
        vec3(0.),
        vec3(0.),
        vec3(0.)
    );

    int inc = 0;

    // top left
    for (int y = -RADIUS; y <= 0; y++) {
        for (int x = -RADIUS; x <= 0; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            vec3 pix = rgb2hsv(texture(iChannel0, uv + offset).rgb);
            means[0] += pix;
            variance[0] += pix * pix;
        }
    }

    // top right
    inc = 0;
    for (int y = -RADIUS; y <= 0; y++) {
        for (int x = 0; x <= RADIUS; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            vec3 pix = rgb2hsv(texture(iChannel0, uv + offset).rgb);
            means[1] += pix;
            variance[1] += pix * pix;
        }
    }

    // bottom left
    inc = 0;
    for (int y = 0; y <= RADIUS; y++) {
        for (int x = -RADIUS; x <= 0; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            vec3 pix = texture(iChannel0, uv + offset).rgb;
            means[2] += pix;
            variance[2] += pix * pix;
        }
    }

    // bottom right
    inc = 0;
    for (int y = 0; y <= RADIUS; y++) {
        for (int x = 0; x <= RADIUS; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            vec3 pix = texture(iChannel0, uv + offset).rgb;
            means[3] += pix;
            variance[3] += pix * pix;
        }
    }
    
    
    for(int i = 0; i < 4; i++) {
        means[i] /= float(RADIUS);
        variance[i] = sqrt(variance[i] / float(QUADRANT_SIZE) - pow(means[i].z, 2.)); // <--
    }
    
    // Select region with lowest std deviation
    int bestIdx = 0;
    float minVariance = 1e+4;
    for (int i = 0; i < 3; i++) {
        vec3 var = abs((variance[i].z/QUADRANT_SIZE) - (means[i]*means[i]));
        float v = var.r + var.g + var.b;
        if (v < minVariance) { // <--
            minVariance = v;
            bestIdx = i;
        }
    }

    vec3 hsvNorm = means[bestIdx] / vec3(360., 100., 100.); // <--
    vec3 finalRGB = means[bestIdx];

    fragColor = vec4(finalRGB, 1.0);
    //fragColor = texture(iChannel0, uv);
}
