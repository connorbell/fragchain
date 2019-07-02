float _T;

float map(float3 pos) 
{
	const int iterations = 10;
	float3 offset = pos;
	float scale = _Midi3;
	float3 p = pos;
	float dr = 0.;
	float minRadius = _Midi5;
	float fixedRadius = _Midi6;
	float ratio = fixedRadius/minRadius;

	for (int i = 0; i < iterations; i++)
	{
		p = clamp(p, -_Midi4, _Midi4) * 2. - p;

		float r = dot(p,p);
		float t = 1.;

		if (r < minRadius)
		{
			t = ratio;
		}
		else if (r < fixedRadius)
		{
			t = fixedRadius / r;
		}

		p *= t;
		dr *= t;

		p = scale * p + offset;
		dr = dr * scale + 1.;
	}

	float r = length(p);
	return r / abs(dr);
}