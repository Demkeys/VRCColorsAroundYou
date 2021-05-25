// Description: Unlit shader. Blends _Tex01 and _Tex02 using _BlendFacTex as a blend factor.
// _BlendFacTex should be greyscale.
// Supports GPU Instancing.
Shader "Custom/UnlitBlendTwoTexInst01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex01 ("Texture 01", 2D) = "white" {}
        _Tex02 ("Texture 02", 2D) = "white" {}
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
                float4 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Tex01_ST_Inst)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Tex02_ST_Inst)
                UNITY_DEFINE_INSTANCED_PROP(float4, _BlendFacTex_ST_Inst)
            UNITY_INSTANCING_BUFFER_END(Props)

            sampler2D _Tex01;
            float4 _Tex01_ST;
            sampler2D _Tex02;
            float4 _Tex02_ST;
            sampler2D _BlendFacTex;
            float4 _BlendFacTex_ST;

            v2f vert (appdata v)
            {
                _Tex01_ST = _Tex01_ST_Inst;
                _Tex02_ST = _Tex02_ST_Inst;
                _BlendFacTex_ST = _BlendFacTex_ST_Inst;

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _Tex01);
                o.uv.zw = TRANSFORM_TEX(v.uv, _Tex02);
                o.uv2 = TRANSFORM_TEX(v.uv, _BlendFacTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = 0;
                fixed4 tex01Col = tex2D(_Tex01, i.uv.xy);
                fixed4 tex02Col = tex2D(_Tex02, i.uv.zw);
                fixed4 blendFacTexCol = tex2D(_BlendFacTex, i.uv2);

                col.rgb = lerp(tex01Col.rgb, tex02Col.rgb, blendFacTexCol.r);
                
                return col;
            }
            ENDCG
        }
    }
}
