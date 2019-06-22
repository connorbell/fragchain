float hash( float n )
{
    return frac(sin(n)*43758.5453123);
}

float noise( in float2 x )
{
    float2 p = floor(x);
    float2 f = frac(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*157.0;

    return lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
               lerp( hash(n+157.0), hash(n+158.0),f.x),f.y);
}


float fbm(in float2 x)
{
 	const int passes = 3;
    float res = 0.;
    float scale = 1.0;
    
    for (int i = 0; i < passes; i++)
    {
        res += noise(x) * scale;
        x *= 2.0;
    	scale *= 0.666;    
    }
    return res;
}
