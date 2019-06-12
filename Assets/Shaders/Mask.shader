Shader "Hidden/Mask"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskColor("Mask Color", Color) = (0.0,0.0,0.0,0.0)
        _MaskTolerance("Mask Tolerance", float) = 1.0
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
            sampler2D _MaskTex;

            fixed4 _MaskColor;
            float _MaskTolerance;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 mask = tex2D(_MaskTex, i.uv);

                float similarity = abs(length(mask) - length(_MaskColor));
                float m = 1. - smoothstep(0.0, _MaskTolerance, similarity);

                fixed4 output = lerp(col, saturate(1.-col), saturate(step(0.1,length(mask))));
 
                return output;
            }
            ENDCG
        }
    }
}
