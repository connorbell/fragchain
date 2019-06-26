Shader "Hidden/UVWarp"
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
			#include "Noise.cginc"

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
			float _Amp;			float _T;

void pR(inout float2 p, float a) {
	p = cos(a)*p + sin(a)*float2(p.y, -p.x);
}


            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;
				float2 np = uv * 2. - 1.;
				pR(np, _T*2. + length(np)*4.);
				uv.x += fbm(np*0.25)*_Amp-_Amp*0.15;
				uv.y += fbm(np*0.25+10.5)*_Amp-_Amp*0.15;
                fixed4 col = tex2D(_MainTex, uv);
				return col;
            }
            ENDCG
        }
    }
}
