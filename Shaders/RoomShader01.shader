// float3(0.2,0,0.12) is a dark magenta kinda color for the rose curves

Shader "Custom/RoomShader01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AOTex ("AO Texture", 2D) = "white" {}
        _AOStr ("AO Strength", Range(0,2)) = 1
        _RoomDesignTex ("Room Design Tex", 2D) = "white" {}
        _RoomDesignLerpFacTex ("Room Design Lerp Factor Tex", 2D) = "white" {}
        _WallRocksCol01 ("Wall Rocks Color 01", Color) = (1,1,1,1)
        _WallRocksCol02 ("Wall Rocks Color 02", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float4 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _AOTex;
            float4 _AOTex_ST;
            half _AOStr;
            sampler2D _RoomDesignTex;
            float4 _RoomDesignTex_ST;
            sampler2D _RoomDesignLerpFacTex;
            fixed4 _WallRocksCol01;
            fixed4 _WallRocksCol02;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _AOTex);
                o.uv2.xy = TRANSFORM_TEX(v.uv, _RoomDesignTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                float ao = lerp(1, tex2D(_AOTex, i.uv.zw).r,_AOStr);
                fixed designFac = tex2D(_RoomDesignTex, i.uv2.xy).r;
                fixed designColLerpFac = tex2D(_RoomDesignLerpFacTex, i.uv2.xy).r;
                fixed3 designCol01 = fixed3(0.2,0,0.12);
                // fixed3 designCol02 = fixed3(
                // abs(sin(radians(_Time.x*150)))*0.2,
                // abs(sin(radians(_Time.x*150)))*0.4,
                // 0.5);
                // fixed3 designCol02 = fixed3(0.3,0.2,0.6);
                fixed3 designCol02 = lerp(_WallRocksCol01.rgb,_WallRocksCol02.rgb,
                abs(sin(radians(_Time.x*100))));
                fixed3 designFinalCol = lerp(designCol01, designCol02, designColLerpFac);
                col.rgb = lerp(designFinalCol ,col.rgb, designFac);
                col.rgb *= ao;
                return col;
            }
            ENDCG
        }
    }
}
