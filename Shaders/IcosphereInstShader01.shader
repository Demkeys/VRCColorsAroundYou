// NOTE: If branching is necessary, try to branch based on instanced properties only.

Shader "Custom/IcosphereInstShader01"
{
    Properties
    {
        _WireTex ("Wireframe Texture", 2D) = "white" {}
        _WireStr ("Wireframe Strength", Range(0,5)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _MainTexCol ("Texture Color", Color) = (1,1,1,1)
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex_ST_Inst ("_MainTex_ST_Inst", Vector) = (0,0,0,0)
        _MainTex_ST_CalcFlags_Inst ("_MainTex_ST_CalcFlags_Inst", Vector) = (0,0,0,0)
        _WireCol_Inst ("_WireCol_Inst", Vector) = (0,0,0,0)
        _FinalColIntensity ("Final Color Intensity", Range(0,1)) = 1
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
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _WireTex;
            float4 _WireTex_ST;
            float _WireStr;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _MainTexCol;
            fixed _FinalColIntensity;
            
            UNITY_INSTANCING_BUFFER_START(Props)
                // xy = Tiling
                // zw = Offset (so far only Offset is being set from script)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST_Inst)

                // x = ?
                // y = Use WireColor or Texture for final color? (0=WireColor,1=Textures)
                // z = Use trig calculations on Offset X (0=False,1=True)
                // w = Use trig calculations on Offset Y (0=False,1=True)
                UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST_CalcFlags_Inst)

                // xyz = Color RGB
                // w = Animate wire color (0=False,1=True)
                UNITY_DEFINE_INSTANCED_PROP(float4, _WireCol_Inst)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _WireTex);
                float trigCalc = sin(radians(_Time.y*2));
                float2 offsetCalc = trigCalc;
                float4 MainTex_ST_Inst = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST_Inst);
                float2 MainTex_ST_CalcFlags_Inst = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST_CalcFlags_Inst).zw;
                offsetCalc *= MainTex_ST_CalcFlags_Inst; 
                // _MainTex_ST.zw = MainTex_ST_Inst.zw;
                _MainTex_ST = MainTex_ST_Inst;
                _MainTex_ST.zw += offsetCalc;
                o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float4 Remap(float val, float low1, float high1, float low2, float high2)
            {
                return low2 + (val - low1) * (high2 - low2) / (high1 - low1);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                
                float ColorOrTex = UNITY_ACCESS_INSTANCED_PROP(Props, _MainTex_ST_CalcFlags_Inst).y;
                fixed4 WireCol_Inst = UNITY_ACCESS_INSTANCED_PROP(Props,_WireCol_Inst);
                
                fixed4 wire = tex2D(_WireTex, i.uv.xy);
                wire *= _WireStr;
                fixed4 mainTex = tex2D(_MainTex, i.uv.zw);
                fixed4 wireCol = wire;
                fixed4 solidCol = WireCol_Inst.w == 1 ? fixed4(
                    (fixed)Remap(cos(radians(_Time.y*20)),-1,1,0.05,0.3), 0,
                    (fixed)Remap(sin(radians(_Time.y*5)),-1,1,0.15,0.35), 0) : WireCol_Inst; 
                fixed4 res = 0;

                mainTex *= _MainTexCol;
                
                // Wire Col
                wireCol.rgb *= solidCol.rgb;
                
                // Final col
                res.rgb = ColorOrTex == 1 ? lerp(mainTex.rgb, wireCol.rgb, wire) : solidCol.rgb;
                res.rgb *= _FinalColIntensity;
                return res;
            }
            ENDCG
        }
    }
}
