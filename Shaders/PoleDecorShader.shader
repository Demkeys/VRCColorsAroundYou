Shader "Custom/PoleDecorShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _LightCol ("Light Color", Color) = (1,1,1,1)
        _LightCol02 ("Light 02 Color", Color) = (1,1,1,1)
        _LightCol03 ("Light 03 Color", Color) = (1,1,1,1)
        _LightCol04 ("Light 04 Color", Color) = (1,1,1,1)
        _WireCol ("Wireframe Color", Color) = (1,1,1,1)
        _BlendFacTex ("Blend Facor Tex", 2D) = "white" {}
        _LightPos ("Light Pos", Vector) = (1,1,1,1)
        _LightPos02 ("Light Pos 02", Vector) = (1,1,1,1)
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
            // #pragma geometry geom
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 uv2 : TEXCOORD1;
                float3 normal : NORMAL;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BlendFacTex;
            fixed4 _WireCol;
            fixed4 _Color;
            float4 _LightPos; float4 _LightPos02;
            fixed4 _LightCol; fixed4 _LightCol02; fixed4 _LightCol03; fixed4 _LightCol04;
            float4 ObjectPos;

            // UNITY_INSTANCING_BUFFER_START(Props)
            //     UNITY_DEFINE_INSTANCED_PROP(float4, ObjectPos_Inst)
            // UNITY_INSTANCING_BUFFER_END(Props)


            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = 0;
                // ObjectPos = UNITY_ACCESS_INSTANCED_PROP(Props, ObjectPos_Inst);
                float posMul = 5;
                float yPos = 0;
                float timeMul = 15;
                float3 LightPos = float3(
                    sin(radians(_Time.z*timeMul)) * posMul, yPos,
                    cos(radians(_Time.z*timeMul)) * posMul);
                float3 LightPos02 = float3(
                    sin(radians((_Time.z*timeMul)+90)) * posMul, yPos,
                    cos(radians((_Time.z*timeMul)+90)) * posMul);
                float3 LightPos03 = float3(
                    sin(radians((_Time.z*timeMul)+180)) * posMul, yPos,
                    cos(radians((_Time.z*timeMul)+180)) * posMul);
                float3 LightPos04 = float3(
                    sin(radians((_Time.z*timeMul)+270)) * posMul, yPos,
                    cos(radians((_Time.z*timeMul)+270)) * posMul);
                
                // v.vertex.xyz = v.vertex.xyz - ObjectPos.xyz;
                float3 dir = normalize(LightPos.xyz - v.vertex.xyz);
                float3 dir02 = normalize(LightPos02.xyz - v.vertex.xyz);
                float3 dir03 = normalize(LightPos03.xyz - v.vertex.xyz);
                float3 dir04 = normalize(LightPos04.xyz - v.vertex.xyz);
                
                // o.uv2 = v.vertex;
                o.uv2.x = max((dot(o.normal, dir)) * 1,0);
                o.uv2.y = max((dot(o.normal, dir02)) * 1,0);
                o.uv2.z = max((dot(o.normal, dir03)) * 1,0);
                o.uv2.w = max((dot(o.normal, dir04)) * 1,0);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // _LightPos.x = sin(radians(_Time.z*50));
                // _LightPos.z = cos(radians(_Time.z*50));
                // i.uv2 = mul(unity_WorldToObject, i.uv2);
                float3 dir = normalize(_LightPos.xyz - i.uv2.xyz);
                // i.uv2.x = max(dot(i.normal,dir),0);
                // sample  the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col = fixed4(0,0,0,0);
                fixed blendFac = tex2D(_BlendFacTex, i.uv).r;
                // col.rgb = lerp(col.rgb,_WireCol.rgb,blendFac);
                // col.rgb *= blendFac;
                fixed3 diffuse = i.uv2.x * _LightCol.rgb;
                fixed3 diffuse02 = i.uv2.y * _LightCol02.rgb;
                fixed3 diffuse03 = i.uv2.z * _LightCol03.rgb;
                fixed3 diffuse04 = i.uv2.w * _LightCol04.rgb;
                
                col.rgb += diffuse;
                col.rgb += diffuse02;
                col.rgb += diffuse03;
                col.rgb += diffuse04;

                col.rgb = lerp(col.rgb, _WireCol.rgb, blendFac);
                // col += i.uv2.x;
                // col.rgb = lerp(col.rgb, 
                // col.rgb *= fixed3(0,0.75,0.75);
                // col = 0;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}



            // [maxvertexcount(3)]
            // void geom (triangle v2f inputs[3], inout TriangleStream<v2f> output)
            // {
            //     v2f o = (v2f)0;
            //     for(int i = 0; i < 3; i++)
            //     {
            //         o.vertex = UnityObjectToClipPos(inputs[i].vertex);
            //         o.normal = inputs[i].normal;
            //         o.uv = inputs[i].uv;
            //         // o.uv2 = inputs[i].vertex;
            //         // o.uv2 = 0;
            //         fixed mult = 1;
            //         fixed val1 = (1-dot(o.normal, normalize(ObjSpaceViewDir(inputs[i].vertex)))) * mult;
            //         fixed val2 = dot(o.normal, normalize(ObjSpaceViewDir(inputs[i].vertex))) * mult;
            //         fixed lerpFac = abs(_SinTime.x);
            //         // o.uv2.x = (dot(o.normal, normalize(ObjSpaceViewDir(inputs[i].vertex)))) * mult;
            //         // o.uv2.x = val1;
            //         // o.uv2.x *= val2;
            //         // o.uv2.x = lerp(val1,val2, lerpFac);
            //         o.uv2 = inputs[i].uv2;
            //         // o.uv2.x = dot(o.normal, ObjSpaceViewDir(inputs[i].vertex)) * 0.5;
            //         output.Append(o);
            //     }
            //     output.RestartStrip();
            // }