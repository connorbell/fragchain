float _T;

float map(float3 pos) 
{
	const int iterations = 20;
	float3 offset = pos;
	float scale = _Midi3;
	float c = _Midi1;
	float3 p = pos;
	float orb = 0.;

	for (int i = 0; i < iterations; i++)
	{
		p = clamp(p, -1., 1.) * 2. - p;

		float l = length(p);

		if (l < 0.5)
		{
			p = p / _Midi1;
		}
		else if (l < 1.)
		{
			p = 1. / p;
		}
		p = scale * p + pos;
	}

	float res = length(p) - _Midi2;
	return res;
}