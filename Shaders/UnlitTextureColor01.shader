﻿Shader "Custom/UnlitTextureColor01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
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
            // #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                // UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // UNITY_INSTANCING_BUFFER_START(Props)
            //     UNITY_DEFINE_INSTANCED_PROP(sampler2D, _MainTex)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
            //     UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
            // UNITY_INSTANCING_BUFFER_END(Props)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

                // UNITY_SETUP_INSTANCE_ID(v);
                // UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // UNITY_SETUP_INSTANCE_ID(i);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
