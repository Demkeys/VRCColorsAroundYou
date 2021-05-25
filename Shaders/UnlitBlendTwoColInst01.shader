// Description: Unlit shader. Blends _Col01 and _Col02 using _BlendFacTex as a blend factor.
// _BlendFacTex should be greyscale. The blending is done using Lerp, so if _BlendFacTex is 
// black and white only, you can use it to set two different colors.
// Supports GPU Instancing.
Shader "Custom/UnlitBlendTwoColInst01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Col01 ("Color01", Color) = (1,1,1,1)
        _Col02 ("Color02", Color) = (1,1,1,1)
        _BlendFacTex ("Blend Factor Texture", 2D) = "white" {}
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Col01_Inst)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Col02_Inst)
            UNITY_INSTANCING_BUFFER_END(Props)

            fixed4 _Col01;
            fixed4 _Col02;
            sampler2D _BlendFacTex;
            float4 _BlendFacTex_ST;

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BlendFacTex);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                _Col01 = UNITY_ACCESS_INSTANCED_PROP(Props, _Col01_Inst);
                _Col02 = UNITY_ACCESS_INSTANCED_PROP(Props, _Col02_Inst);
                
                fixed4 col = 0;
                fixed4 blendFacTexCol = tex2D(_BlendFacTex, i.uv);

                col.rgb = lerp(_Col01.rgb, _Col02.rgb, blendFacTexCol.r);
                
                return col;
            }
            ENDCG
        }
    }
}
