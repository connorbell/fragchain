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

float map(float3 pos) {

	float scale = .7;

	float3 spacesize = 3.;
	float res = 1e20;

	float distFromCam = length(pos)*_Midi6;
	float3 idx = floor(pos.xyz / spacesize);

	// Divide the space into cells
	pos.xyz = mod(pos.xyz, spacesize) - spacesize * 0.5;

	float3 displacement = float3(-1., -.5, -2.)*_Midi5;

	for (int i = 0; i < 8; i++) {
		pos.xyz = abs(pos.xyz);

		pos += displacement * scale;

		float phase = float(i)*0.5 + distFromCam + _T*2.;
		pR(pos.xz, -_Midi1 - distFromCam + float(i)*0.5 + sin(phase)*_Midi4);
		pR(pos.yz, _Midi3 + distFromCam + float(i)*0.5 + cos(phase)*_Midi4);

		scale *= 0.666;

		float octa = fOctahedron(pos, scale);

		res = min(res, octa);
	}
    res = smin(res, res, sin(-0.5-distFromCam*20.+_T*2.) * _Midi7);

	return res;
}