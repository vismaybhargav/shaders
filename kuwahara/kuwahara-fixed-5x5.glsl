void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Output to screen
    fragColor = vec4(texture(iChannel0, uv).rgb,1.0);
}

// Gets the mean of a region.
float meanRegion(float regionValues[9]) {
    float sum = 0;
    for(int i = 0; i < 9; i++) {
        sum += regionValues[i];
    }
    return sum / 9.0;
}

// Gets the standard deviation of the values in a region.
float stdDevRegion(float regionValues[9]) {
    float mean = meanRegion(regionValues);
    float stdDev = 0;
    for(int i = 0; i < 9; i++) {
        stdDev += pow((regionValues[i] - mean), 2.0);
    }
    return stdDev / 9.0;
}


// Converts a rgb value to a hsv value
// https://www.geeksforgeeks.org/utilities/hsv-to-rgb-converter/
vec3 rgb2hsv(vec3 rgb) {
    float rPrime = rgb.r / 255.0;
    float gPrime = rgb.g / 255.0;
    float bPrime = rgb.b / 255.0;

    float cMax = max(rPrime, max(gPrime, bPrime));
    float cMin = min(rPrime, min(gPrime, bPrime));
    float delta = cMax - cMin;

    // TODO: Figure out how to fix the branching here.
    float h;
    if(delta == 0.) {
        h = 0.;
    } else if(cMax == rPrime) {
        h = mod(60 * ((gPrime - bPrime) / delta) + 360.0, 360.0);
    } else if(cMax == gPrime) {
        h = mod(60 * ((bPrime - rPrime) / delta) + 120.0, 360.0);
	} else if(cMax == bPrime) {
        h = mod(60 * ((rPrime - gPrime) / delta) + 240.0, 360.0);
	}
	
	float s;
	if(cMax == 0.) {
		s = 0.;
	} else {
		s = (delta/cMax)*100.0
	}

	float v = cMax * 100.0;

	return vec3(h, s, v);
}

// Converts a hsv value to a rgb value
vec3 hsv2rgb(vec3 hsv) {
	// TODO: Implement
}
