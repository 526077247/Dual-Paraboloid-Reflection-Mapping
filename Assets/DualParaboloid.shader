Shader "Unlit/DualParaboloid"
{
	Properties
	{
		_DualParaboloidTex ("Texture", 2D) = "white" {}
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

			sampler2D _DualParaboloidTex;
			
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
            	float2 frontUV = reflect_dir.xy / (reflect_dir.z + 1.0) * 0.5 + 0.5;
            	float2 backUV  = reflect_dir.xy / (1.0 - reflect_dir.z) * 0.5 + 0.5;
            	half flagZ = step(0.0, reflect_dir.z);
    			float2 xy = (frontUV.xy * flagZ + backUV.xy * (flagZ - 1.0)) * 0.5 + 0.5;
				half4 col = tex2D(_DualParaboloidTex,xy);
				return col;
			}
			ENDCG
		}
	}
}