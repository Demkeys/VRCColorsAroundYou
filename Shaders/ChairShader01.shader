Shader "Custom/ChairShader01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color01 ("Color01", Color) = (1,1,1,1)
        _Color02 ("Color02", Color) = (1,1,1,1)
        _BlendFacTex01 ("Blend Factor 01", 2D) = "white" {}
        _BlendFacTex02 ("Blend Factor 02", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color01; fixed4 _Color02; 
            sampler2D _BlendFacTex01; sampler2D _BlendFacTex02; 

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color01_Inst)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color02_Inst)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 Remap(float val, float low1, float high1, float low2, float high2)
            {
                return low2 + (val - low1) * (high2 - low2) / (high1 - low1);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                fixed4 _Color01Inst = UNITY_ACCESS_INSTANCED_PROP(Props, _Color01_Inst);
                fixed4 _Color02Inst = UNITY_ACCESS_INSTANCED_PROP(Props, _Color02_Inst);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed blendFac01 = tex2D(_BlendFacTex01, i.uv).r;
                fixed blendFac02 = tex2D(_BlendFacTex02, i.uv).r;
                fixed mul01 = Remap(sin(radians(_Time.x*500)),-1,1,0.5,2.5);
                fixed mul02 = Remap(sin(radians(_Time.x*500)),-1,1,2.5,0.5);
                _Color01 = _Color01Inst;
                _Color02 = _Color02Inst;
                _Color01.rgb *= mul01;
                _Color02.rgb *= mul02;
                col.rgb = lerp(col.rgb, _Color01.rgb, blendFac01);
                col.rgb = lerp(col.rgb, _Color02.rgb, blendFac02);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
