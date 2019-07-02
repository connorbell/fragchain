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
		
			float _Aspect;

			sampler2D _MainTex;
			float3 _CamForward;
			float3 _CamRight;
			float3 _CamUp;
			float3 _CamPos;
			float _FocalLength;	
			float _MaxDist;
			float4x4 _CamToWorld;

			#include "DistanceFields.cginc"
			//#include "Mandelbox.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float4 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				float2 uv = v.uv;
				uv = uv * 2.0 - 1.0;
				uv.x *= _Aspect;
				
				o.ray.xyz = normalize(_CamRight * uv.x + _CamUp * uv.y + _CamForward * _FocalLength);
                o.uv = v.uv;
                return o;
            }

			float march(in float3 pos, in float3 rd)
			{
				const int steps = 70;
				const float minDist = 0.001;
				float depth = 0.;

				for (int i = 0; i < steps; i++)
				{
					float dist = map(pos + rd * depth);
					depth += dist;

					if (depth > _MaxDist || dist < minDist)
						break;
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

			// Ambient Occlusion by Inigo Quilez https://www.shadertoy.com/view/Xds3zN
			float calcAO( in float3 pos, in float3 nor )
			{
				float occ = 0.0;
				float sca = 1.0;
				for( int i=0; i<4; i++ )
				{
					float hr = 0.01 + 0.02*float(i)/4.0;
					float3 aopos =  nor * hr + pos;
					float dd = map( aopos );
					occ += -(dd-hr)*sca;
					sca *= .95;
				}
				return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
			}

			// Softshadow by Inigo Quilez https://www.iquilezles.org/www/articles/rmshadows/rmshadows.htm
			float softShadow( in float3 ro, in float3 rd, in float mint, in float tmax )
			{
				float res = 1.0;
				float t = mint;
				for( int i=0; i<20; i++ )
				{
					float h = map( ro + rd*t ).x;
					res = min( res, 8.0*h/t );
					t += clamp( h, 0., 0.1 );
					if(t>tmax ) break;
				}
				return clamp( res, 0.0, 1.0 );

			}

			float4 surface(in float3 ray)
			{
				 float dist = march( _CamPos, ray.xyz );
				 float3 sPos = _CamPos + ray.xyz * dist;
				 float3 nor = calcNormal(sPos);
				 float ao = calcAO(sPos, nor);
				 float3 ref = reflect( ray, nor );
				 float shadow = softShadow(sPos, ref, .1, .1);
				 nor.r = 0.;
				 float3 col = nor * 0.5 + 0.5;
				 
				 col *= (_Midi4+dot(ray,nor)) * ao * shadow;
				 col = lerp(col, 0., saturate(dist/_MaxDist) );

				 return float4(col, dist);
			}

            float4 frag (v2f i) : SV_Target
            {
                float4 col = surface(i.ray);
                return col;
            }
            ENDCG
        }
    }
}
