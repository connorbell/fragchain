Shader "Hidden/DepthOfField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

			float normpdf(in float x, in float sigma)
			{
				return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
			}


            sampler2D _MainTex;
			float2 _Texel;

            float4 frag (v2f i) : SV_Target
            {
   				float2 uv = i.uv;
				float3 base = 0.;
    
				// Gaussian blur by mrharicot https://www.shadertoy.com/view/XdfGDH
    
				//declare stuff
				const int mSize = 15;
				const int kSize = (mSize-1)/2;
				float kernel[mSize];
				float3 final_colour = 0.0;
				float depth = tex2D(_MainTex, uv).a;
    
				//create the 1-D kernel
				float sigma = lerp(0.01, 8., max(0., -1. + depth*1.2));
				float Z = .0;
				for (int j = 0; j <= kSize; ++j)
				{
					kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
				}

				//get the normalization factor (as the gaussian has been clamped)
				for (int j = 0; j < mSize; ++j)
				{
					Z += kernel[j];
				}

				//read out the texels
				for (int i=-kSize; i <= kSize; ++i)
				{
					for (int j=-kSize; j <= kSize; ++j)
					{
						base += kernel[kSize+j]*kernel[kSize+i]*tex2D(_MainTex, (uv+_Texel*float2(float(i),float(j)))).rgb;
					}
				}
   				float4 b = float4(base/(Z*Z), 1.0);

                return b;
            }
            ENDCG
        }
    }
}
