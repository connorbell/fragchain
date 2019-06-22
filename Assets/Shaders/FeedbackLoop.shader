Shader "Hidden/FeedbackLoop"
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

            sampler2D _MainTex;
            sampler2D _LastTex;

			float _Scale;
			float _FeedbackFactor;

			float3 blendSoftLight(float3 base, float3 blend) {
				float3 s = step(0.5,blend);
				return s * (sqrt(base)*(2.0*blend-1.0)+2.0*base*(1.0-blend)) + (1.-s)*(2.*base*blend+base*base*(1.0-2.0*blend));
			}

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
				float2 uv_c = i.uv * 2.0 - 1.0;
				float l = length(uv_c) * _Scale;
				float a = atan2(uv_c.x, uv_c.y) + 3.14159*0.5;
				 
				uv_c = float2(cos(a), sin(a) ) * l + .5;
                uv_c.x = 1.- uv_c.x;
				float4 last = tex2D(_LastTex, uv_c);
				col.rgb = col + (blendSoftLight(col.rgb, last.rgb*_FeedbackFactor));
                return col;
            }
            ENDCG
        }
    }
}
