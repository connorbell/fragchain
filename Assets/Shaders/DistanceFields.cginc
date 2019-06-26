float _T;

float3 mod(float3 x, float3 y)
{
	return x - y * floor(x / y);
}

float sphere(in float3 p, in float r)
{
	return length(p) - r;
}

void pR(inout float2 p, float a) {
	p = cos(a)*p + sin(a)*float2(p.y, -p.x);
}

float smin( float a, float b, float k ){
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float sdBox( float3 p, float3 b )
{
	float3 d = abs(p) - b;
	return length(max(d,0.0))
			+ min(max(d.x,max(d.y,d.z)),0.0); // remove this line for an only partially signed sdf 
}

#define TAU (2*PI)
#define PHI (1.618033988749895)
#define GDFVector0 float3(1, 0, 0)
#define GDFVector1 float3(0, 1, 0)
#define GDFVector2 float3(0, 0, 1)

#define GDFVector3 normalize(float3(1, 1, 1 ))
#define GDFVector4 normalize(float3(-1, 1, 1))
#define GDFVector5 normalize(float3(1, -1, 1))
#define GDFVector6 normalize(float3(1, 1, -1))

#define GDFVector7 normalize(float3(0, 1, PHI+1.))
#define GDFVector8 normalize(float3(0, -1, PHI+1.))
#define GDFVector9 normalize(float3(PHI+1., 0, 1))
#define GDFVector10 normalize(float3(-PHI-1., 0, 1))
#define GDFVector11 normalize(float3(1, PHI+1., 0))
#define GDFVector12 normalize(float3(-1, PHI+1., 0))

#define GDFVector13 normalize(float3(0, PHI, 1))
#define GDFVector14 normalize(float3(0, -PHI, 1))
#define GDFVector15 normalize(float3(1, 0, PHI))
#define GDFVector16 normalize(float3(-1, 0, PHI))
#define GDFVector17 normalize(float3(PHI, 1, 0))
#define GDFVector18 normalize(float3(-PHI, 1, 0))

#define fGDFBegin float d = 0.;

// Version with variable exponent.
// This is slow and does not produce correct distances, but allows for bulging of objects.
#define fGDFExp(v) d += pow(abs(dot(p, v)), e);

// Version with without exponent, creates objects with sharp edges and flat faces
#define fGDF(v) d = max(d, abs(dot(p, v)));

#define fGDFExpEnd return pow(d, 1./e) - r;
#define fGDFEnd return d - r;


float fOctahedron(float3 p, float r) {
	fGDFBegin
		fGDF(GDFVector3) fGDF(GDFVector4) fGDF(GDFVector5) fGDF(GDFVector6)
		fGDFEnd
}

float fDodecahedron(float3 p, float r) {
	fGDFBegin
		fGDF(GDFVector13) fGDF(GDFVector14) fGDF(GDFVector15) fGDF(GDFVector16)
		fGDF(GDFVector17) fGDF(GDFVector18)
		fGDFEnd
}

float fIcosahedron(float3 p, float r) {
	fGDFBegin
		fGDF(GDFVector3) fGDF(GDFVector4) fGDF(GDFVector5) fGDF(GDFVector6)
		fGDF(GDFVector7) fGDF(GDFVector8) fGDF(GDFVector9) fGDF(GDFVector10)
		fGDF(GDFVector11) fGDF(GDFVector12)
		fGDFEnd
}

float opS(float distA, float distB)
{
	return max(distA, -distB);
}

float map(float3 pos) {

	float3 spacesize = float3(3., 3.5, 3.);

	float scale = spacesize*0.25;

	float distFromCam = length(pos) * _Midi6;
	float3 idx = floor(pos.xyz / spacesize);

	float3 octaPos = pos;
	float3 shapeOffset = float3(1.606299, 0.2834646, 0.496063);
	octaPos += shapeOffset;

	float3 shapeCellIndex = floor(octaPos / spacesize);

	// Divide the space into cells
	pos.xyz = mod(pos.xyz, spacesize) - spacesize * 0.5;
	octaPos.xyz = mod(octaPos.xyz, spacesize) - spacesize * 0.5;

	pR(octaPos.xz, sin(_T*2.)*0.1 );
	pR(octaPos.yx, cos(_T*2.)*0.1);

	float res = 1e20;

	float3 displacement = float3(-.5, -.25, -1.)*_Midi5;

	for (int i = 0; i < 8; i++) {
		pos.xyz = abs(pos.xyz);

		pos += displacement * scale;

		float phase = float(i)*0.5 + distFromCam + _T*2.;
		pR(pos.xz, -_Midi1 - distFromCam + float(i)*0.5 + sin(phase)*_Midi3);
		pR(pos.yz, _Midi2 + distFromCam + float(i)*0.5 + cos(phase)*_Midi3);

		scale *= .55;

		float octa = fIcosahedron(pos, scale);

		res = min(res, octa);
	}

	float octaScale = 0.3;
	float octaDist = fIcosahedron(octaPos, octaScale);
	float boxScale = octaScale*_Midi7;
	
	octaPos.x += sin(_Midi8+_T*2.)*0.05;

	for (int i = 0; i < 3; i++)
	{
		boxScale *= 0.5;
		float bs = boxScale * 6.;
		octaDist = opS(octaDist, sdBox(mod(octaPos, float3(0., bs ,bs) ), float3(10., boxScale, boxScale)) );
		octaDist = opS(octaDist, sdBox(mod(octaPos, float3(bs, 0. ,bs) ), float3(boxScale, 10., boxScale)) );
		octaDist = opS(octaDist, sdBox(mod(octaPos, float3(bs, bs ,0.) ), float3(boxScale, boxScale, 10.)) );
	}

	res = smin(res, octaDist, 0.2047244);

	return res;
}