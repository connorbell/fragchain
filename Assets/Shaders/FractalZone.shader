Shader "Hidden/FractalZone"
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

			float _Midi1;
			float _Midi2;
			float _Midi3;
			float _Midi4;
			float _Midi5;
			float _Midi6;
			float _Midi7;
			float _Midi8;
			
			#include "DistanceFields.cginc"

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

            sampler2D _MainTex;
			float3 _CamForward;
			float3 _CamRight;
			float3 _CamUp;
			float3 _CamPos;
			float _FocalLength;

			float march(in float3 pos, in float3 rd)
			{
				const int steps = 30;
				float depth = 0.;

				for (int i = 0; i < steps; i++)
				{
					float dist = map(pos + rd * depth);
					depth += dist;
				}
				return depth;
			}

			float3 calcNormal( in float3 pos )
			{
				float3 eps = float3( 0.001, 0.0, 0.0 );
				float3 nor = float3(map(pos+eps.xyy) - map(pos-eps.xyy),
        							map(pos+eps.yxy) - map(pos-eps.yxy),
        							map(pos+eps.yyx) - map(pos-eps.yyx) );
				return normalize(nor);
			}

			float4 surface(in float4 projPos)
			{
				 projPos.xy /= projPos.w;
				 projPos.xy = projPos * 2.0 - 1.0;

				 float3 rayDirection = normalize(_CamRight * projPos.x +
				 								 _CamUp * projPos.y +
												 _CamForward * _FocalLength);

				 float3 pos = _CamPos + float3(projPos.xy, 0.);
				 float dist = march( pos, rayDirection );
				 float3 sPos = pos + rayDirection * dist;
				 float3 nor = calcNormal(sPos);

				 float3 col = nor * 0.5 + 0.5;
				 col *= (.9+dot(rayDirection,nor));

				 col = lerp(col, 0., saturate(dist/10.) );

				 return float4(col, dist);
			}

            float4 frag (v2f i) : SV_Target
            {
                float4 col = surface(float4(i.uv, 0., i.vertex.w));
                return col;
            }
            ENDCG
        }
    }
}
