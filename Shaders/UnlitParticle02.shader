Shader "Custom/UnlitParticle02"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorMul ("Color Multiplier", Range(0,2)) = 1
        _AlphaMul ("Alpha Multiplier", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        LOD 100
        Cull Off
        ZWrite Off
        // ColorMask RGB
        // Blend SrcAlpha One
        Blend SrcAlpha OneMinusSrcAlpha
        // Blend SrcAlpha One, One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _ColorMul;
            fixed _AlphaMul; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 col = tex;
                // col.rgb *= i.color.rgb;
                col *= i.color;
                // if(i.color.r < 0.05 && i.color.g < 0.05 && i.color.b < 0.05) 
                // {
                //     col.a = (1-tex.r);
                //     col.rgb =
                // }
                col.rgb *= _ColorMul;
                col.a *= _AlphaMul;
                // col.a = (1-tex2D(_MainTex, i.uv).r);
                // col.a *= 0.5;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
