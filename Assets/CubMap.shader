Shader "Custom/CubMap" {
	Properties
	{
		_EnvMap("Env Map",Cube) = "white"{}
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
			
			#include "UnityCG.cginc"

			struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal  : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
            };

			samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
			
			v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {     
				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                half3 normal_dir = normalize(i.normal_dir);
            	half3 reflect_dir = reflect(-view_dir, normal_dir);
            	half4 color_cubemap = texCUBElod(_EnvMap, float4(reflect_dir, 0.0));
                half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR);
				return half4(env_color,0);
			}
			ENDCG
		}
	}
}