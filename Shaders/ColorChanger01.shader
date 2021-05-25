// NOTE: The calculations to bring the mesh in front of the camera ("screenspace effect") 
// currently heavily rely on the fact that the mesh gameobject is at (0,0,0). At some point later
// I'll figure out the calculations to make it so the effect doesn't rely on the mesh gameobject
// being at (0,0,0) and is instead position-independent.

Shader "Custom/ColorChanger01"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}

        [Toggle] _UseTempBuffer ("Calculate Channels Separately", Int) = 0

        [KeywordEnum(Keep,Switch,Add,Sub,Mul,Div)] _ROp ("Red Channel Operator", Int) = 0
        [KeywordEnum(R,G,B,A)] _RCh ("Red Channel Operand", Int) = 0

        [KeywordEnum(Keep,Switch,Add,Sub,Mul,Div)] _GOp ("Green Channel Operator", Int) = 0
        [KeywordEnum(R,G,B,A)] _GCh ("Green Channel Operand", Int) = 1

        [KeywordEnum(Keep,Switch,Add,Sub,Mul,Div)] _BOp ("Blue Channel Operator", Int) = 0
        [KeywordEnum(R,G,B,A)] _BCh ("Blue Channel Operand", Int) = 2

        [KeywordEnum(Keep,Switch,Add,Sub,Mul,Div)] _AOp ("Alpha Channel Operator", Int) = 0
        [KeywordEnum(R,G,B,A)] _ACh ("Alpha Channel Operand", Int) = 3

        [Header(FinalColor)]
        [KeywordEnum(Keep,Switch,Add,Sub,Mul,Div)] _EOp ("Extra Color Operator", Int) = 0
        _ECol ("Extra Color Operand", Vector) = (0.5,0.5,0.5,1)
    }
    SubShader
    {
        Tags { "RenderQueue"="Transparent" }
        LOD 100
        Cull Off
        ZWrite Off

        GrabPass { "_ScreenContents" }

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
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            sampler2D _ScreenContents;
            int _ROp; int _RCh; int _GOp; int _GCh; 
            int _BOp; int _BCh; int _AOp; int _ACh; 
            int _UseTempBuffer;
            int _EOp; fixed4 _ECol;

            v2f vert (appdata v)
            {
                v2f o;
                // v.vertex.xyz *= 1;
                // float3 camObjPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos,1)).xyz;
                // v.vertex.xyz += camObjPos;
                // o.vertex = v.vertex;
                // o.vertex = UnityObjectToClipPos(v.vertex);

                ////////////////////////////
                float4 pos = v.vertex;
                pos.xyz *= 10;
                pos = mul(UNITY_MATRIX_M, pos);
                // pos = mul(UNITY_MATRIX_V, pos);
                float3 translatedViewPos = pos.xyz - _WorldSpaceCameraPos.xyz;
                float translatedViewZPos = _ProjectionParams.y + 0.0001;
                float4x4 viewMat2 = {
                    1,0,0,0,
                    0,1,0,0,
                    0,0,-1,-translatedViewZPos,
                    0,0,0,1
                };
                pos = mul(viewMat2, pos);
                pos = mul(UNITY_MATRIX_P, pos);
                o.vertex = pos;
                ////////////////////////////

                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = ComputeGrabScreenPos(o.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            void EvaluateOperator (inout fixed colCh, fixed operand, int chOperator)
            {
                if (chOperator == 0) colCh = colCh; // Redundant
                else if (chOperator == 1) colCh = operand;
                else if (chOperator == 2) colCh += operand;
                else if (chOperator == 3) colCh -= operand;
                else if (chOperator == 4) colCh *= operand;
                else if (chOperator == 5) colCh /= operand;
            }

            void EvaluateOperand (fixed4 col, inout fixed colCh, int operand, int chOperator)
            {
                if(operand == 0) EvaluateOperator (colCh, col.r, chOperator);
                else if(operand == 1) EvaluateOperator (colCh, col.g, chOperator);
                else if(operand == 2) EvaluateOperator (colCh, col.b, chOperator);
                else if(operand == 3) EvaluateOperator (colCh, col.a, chOperator);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = tex2Dproj (_ScreenContents, i.uv);
                // col = fixed4(1,0,0,1);
                fixed4 tempBuffer = col;

                if(_UseTempBuffer == 0)
                {
                    EvaluateOperand (col, col.r, _RCh, _ROp);
                    EvaluateOperand (col, col.g, _GCh, _GOp);
                    EvaluateOperand (col, col.b, _BCh, _BOp);
                    EvaluateOperand (col, col.a, _ACh, _AOp);
                }
                else if(_UseTempBuffer == 1)
                {
                    EvaluateOperand (tempBuffer, col.r, _RCh, _ROp);
                    EvaluateOperand (tempBuffer, col.g, _GCh, _GOp);
                    EvaluateOperand (tempBuffer, col.b, _BCh, _BOp);
                    EvaluateOperand (tempBuffer, col.a, _ACh, _AOp);
                }

                if(_EOp == 0) col = col;            // Redundant
                else if(_EOp == 1) col = _ECol;     // Switch
                else if(_EOp == 2) col += _ECol;    // Add
                else if(_EOp == 3) col -= _ECol;    // Sub
                else if(_EOp == 4) col *= _ECol;    // Mul
                else if(_EOp == 5) col /= _ECol;    // Div

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
