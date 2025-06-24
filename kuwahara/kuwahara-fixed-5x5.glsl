// Gets the mean of a region.
vec3 meanRegion(vec3 hsvRegion[9]) {
    vec3 sum = vec3(0.);
    for (int i = 0; i < 9; i++) {
        sum += hsvRegion[i];
    }
    return sum / 9.0;
}

// Gets the standard deviation of the values in a region.
float stdDevRegion(vec3 regionValues[9]) {
    vec3 mean = meanRegion(regionValues);
    float stdDev = 0.0;
    for(int i = 0; i < 9; i++) {
        stdDev += pow((regionValues[i].z - mean.z), 2.0);
    }
    return stdDev / 9.0;
}


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
        h = mod(60.0 * ((gPrime - bPrime) / delta) + 360.0, 360.0);
    } else if(cMax == gPrime) {
        h = mod(60.0 * ((bPrime - rPrime) / delta) + 120.0, 360.0);
	} else if(cMax == bPrime) {
        h = mod(60.0 * ((rPrime - gPrime) / delta) + 240.0, 360.0);
	}
	
	float s;
	if(cMax == 0.) {
		s = 0.;
	} else {
		s = (delta/cMax)*100.0;
	}

	float v = cMax * 100.0;

	return vec3(h, s, v);
}

// Converts a hsv value to a rgb value
// https://www.diversifyindia.in/hsv-to-rgb-converter/
vec3 hsv2rgb(vec3 hsv) {
    float h = mod(hsv.x, 360.);
    float s = hsv.y;
    float v = hsv.z;
    
    
    float chroma = s * v;
    float x = chroma * (1. - abs(mod(h / 60., 2.0) - 1.));
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

    vec3 topLeft[9] = vec3[9](
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0)
    );
                              
    vec3 topRight[9] = vec3[9](
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0)
    );

    vec3 botLeft[9] = vec3[9](
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0)
    );

    vec3 botRight[9] = vec3[9](
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0),
        vec3(0.0), vec3(0.0), vec3(0.0)
    );

    int inc = 0;

    // top left
    inc = 0;
    for (int y = -2; y <= 0; y++) {
        for (int x = -2; x <= 0; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            topLeft[inc++] = rgb2hsv(texture(iChannel0, uv + offset).rgb);
        }
    }

    // top right
    inc = 0;
    for (int y = -2; y <= 0; y++) {
        for (int x = 0; x <= 2; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            topRight[inc++] = rgb2hsv(texture(iChannel0, uv + offset).rgb);
        }
    }

    // bottom left
    inc = 0;
    for (int y = 0; y <= 2; y++) {
        for (int x = -2; x <= 0; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            botLeft[inc++] = rgb2hsv(texture(iChannel0, uv + offset).rgb);
        }
    }

    // bottom right
    inc = 0;
    for (int y = 0; y <= 2; y++) {
        for (int x = 0; x <= 2; x++) {
            vec2 offset = vec2(float(x), float(y)) * pixel;
            botRight[inc++] = rgb2hsv(texture(iChannel0, uv + offset).rgb);
        }
    }

    float stdDevs[4] = float[4](
        stdDevRegion(topLeft),
        stdDevRegion(topRight),
        stdDevRegion(botLeft),
        stdDevRegion(botRight)
    );

    vec3 means[4] = vec3[4](
        meanRegion(topLeft),
        meanRegion(topRight),
        meanRegion(botLeft),
        meanRegion(botRight)
    );

    // Select region with lowest std deviation
    int bestIdx = 0;
    float minStdDev = stdDevs[0];
    for (int i = 1; i < 4; i++) {
        if (stdDevs[i] < minStdDev) {
            minStdDev = stdDevs[i];
            bestIdx = i;
        }
    }

    vec3 hsvNorm = means[bestIdx] / vec3(360.0, 100.0, 100.0);
    vec3 finalRGB = hsv2rgb(hsvNorm);

    //fragColor = vec4(finalRGB, 1.0);
    fragColor = texture(iChannel0, uv);
}
