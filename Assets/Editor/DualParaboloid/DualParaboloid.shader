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
                float3 normalDir : TEXCOORD1;
                float3 posWorld : TEXCOORD2;
            };

			sampler2D _DualParaboloidTex;
			
			v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
			half4 texDualParaboloidlod(half3 reflectDir)
			{
			    half2 frontUV = reflectDir.xy / (reflectDir.z + 1.0) * 0.5 + 0.5;
			    half2 backUV  = reflectDir.xy / (1.0 - reflectDir.z) * 0.5 + 0.5;
			    half flagZ = step(0.0, reflectDir.z);
			    half2 xy = ((frontUV.xy  + half2(1.0,0.0)) * flagZ + backUV.xy * (1-flagZ)) * 0.25;
			    
			    return tex2D(_DualParaboloidTex, xy);
			}
			// 4*4 均等分
			half4 texDualParaboloidlod(half4 reflectDir)
			{
				half2 frontUV = reflectDir.xy / (reflectDir.z + 1.0) * 0.5 + 0.5;
				half2 backUV  = reflectDir.xy / (1.0 - reflectDir.z) * 0.5 + 0.5;
				half flagZ = step(0.0, reflectDir.z);
				half2 xy = ((frontUV.xy  + half2(1.0,0.0)) * flagZ + backUV.xy * (1-flagZ)) * 0.25;
				
				half lod1 = floor(reflectDir.w);
				half lod2 = ceil(reflectDir.w);
				half2 offsetLod1 = half2(floor(fmod(lod1 , 2.0)) * 0.5, floor(lod1 * 0.5) * 0.25);
				half2 offsetLod2 = half2(floor(fmod(lod2 , 2.0)) * 0.5, floor(lod2 * 0.5) * 0.25);
				half4 col1 = tex2D(_DualParaboloidTex, offsetLod1 + xy);
				half4 col2 = tex2D(_DualParaboloidTex, offsetLod2 + xy);
				return lerp(col1,col2,reflectDir.w - lod1);
			}
			// half4 texDualParaboloidlod(half2 frontUV,half2 backUV,half flagZ, half lod)
			// {
			// 	lod = floor(lod);
			// 	half g4 = floor(lod * 0.25); // 大于4
			// 	half g1 = ceil(lod * 0.125); // 大于1
			// 	half size = 0.5 - g4 * 0.125 - g1 * 0.25;
			// 	half2 xy = ((frontUV.xy + half2(1.0,0.0)) * flagZ  + backUV.xy * (1-flagZ)) * size;
			// 	
			// 	half index = floor(fmod(lod, 4.0)) - 1.0;
			// 	half index2 = lod - 4.0;
			// 	half2 offsetLod = float2(0.0,0.5) * g1 + float2(0.5,0.25) * g4 +
			// 		(1-g4) * g1 * half2(fmod(index,2.0) * 0.5, floor(index * 0.5) * 0.25)
			// 		+ g4 * half2(floor(fmod(index2 , 2.0)) * 0.25, floor(index2 * 0.5) * 0.125);
			// 	
			// 	half4 col = tex2D(_DualParaboloidTex, offsetLod + xy);
			// 	return col;
			// }
			// half4 texDualParaboloidlod(half4 reflectDir)
			// {
			// 	half2 frontUV = reflectDir.xy / (reflectDir.z + 1.0) * 0.5 + 0.5;
			// 	half2 backUV  = reflectDir.xy / (1.0 - reflectDir.z) * 0.5 + 0.5;
			// 	half flagZ = step(0.0, reflectDir.z);
			// 	half lod1 = floor(reflectDir.w);
			// 	half lod2 = ceil(reflectDir.w);
			// 	half4 col1 = texDualParaboloidlod(frontUV,backUV,flagZ,lod1);
			// 	half4 col2 = texDualParaboloidlod(frontUV,backUV,flagZ,lod2);
			// 	return lerp(col1,col2,reflectDir.w - lod1);
			// }
			half4 frag (v2f i) : SV_Target
			{     
				half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWorld);
				half3 normalDir = normalize(i.normalDir);
				half3 reflectDir = reflect(-viewDir, normalDir);

				half4 col = texDualParaboloidlod(reflectDir);
				return col;
			}
			ENDCG
		}
	}
}