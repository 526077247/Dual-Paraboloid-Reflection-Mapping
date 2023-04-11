Shader "Unlit/DualParaboloidGenerate"
{
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
			#pragma vertex vert_img
            #pragma fragment frag
			
			#include "UnityCG.cginc"
			

			samplerCUBE _EnvMap;
            float4 _EnvMap_HDR;
			// 4*4 均等分
			float4 getPos(float2 uv)
			{
				float xx = floor(uv.x * 4.0);
				float yy = floor(uv.y * 4.0);
				float2 xy = float2(uv.x*4.0 - xx,uv.y*4.0 - yy);
				xy = lerp(-float2(1.0,1.0), float2(1.0,1.0), xy);
				float mipLevel = yy*2.0 + floor(xx*0.5);
				float z = 0.5 - 0.5 * (xy.x * xy.x+ xy.y * xy.y);
				return float4(xy,z * (floor(xx%2.0)*2.0-1.0),mipLevel);
			}
			// float4 getPos(float2 uv)
			// {
			// 	if(uv.y < 0.5)
			// 	{
			// 		float front = floor(uv.x*2.0);
			// 		float2 xy = float2(uv.x * 2.0 - front,uv.y*2.0);
			// 		xy = lerp(-float2(1.0,1.0), float2(1.0,1.0), xy);
			// 		float z = 0.5 - 0.5 * (xy.x * xy.x+ xy.y * xy.y);
			// 		return float4(xy, z * (front*2.0 - 1.0),0);
			// 	}
			// 	else
			// 	{
			// 		if(uv.y > 0.75 && uv.x>0.5)
			// 		{
			// 			uv.x = uv.x- 0.5;
			// 			uv.y = uv.y- 0.75;
			// 			float xx = floor(uv.x * 8.0);
			// 			float yy = floor(uv.y * 8.0);
			// 			float2 xy = float2(uv.x*8.0 - xx,uv.y*8.0 - yy);
			// 			xy = lerp(-float2(1.0,1.0), float2(1.0,1.0), xy);
			// 			float mipLevel =4+ yy*2.0 + floor(xx*0.5);
			// 			float z = 0.5 - 0.5 * (xy.x * xy.x+ xy.y * xy.y);
			// 			return float4(xy,z * (floor(xx%2.0)*2.0-1.0),mipLevel);
			// 		}
			// 		else
			// 		{
			// 			uv.y = uv.y- 0.5;
			// 			float xx = floor(uv.x * 4.0);
			// 			float yy = floor(uv.y * 4.0);
			// 			float2 xy = float2(uv.x*4.0 - xx,uv.y*4.0 - yy);
			// 			xy = lerp(-float2(1.0,1.0), float2(1.0,1.0), xy);
			// 			float mipLevel = 1 + yy*2.0 + floor(xx*0.5);
			// 			float z = 0.5 - 0.5 * (xy.x * xy.x+ xy.y * xy.y);
			// 			return float4(xy,z * (floor(xx%2.0)*2.0-1.0),mipLevel);
			// 		}
			// 	}
			// 	
			// }
			
			fixed4 frag (v2f_img i) : SV_Target
			{
				float4 pos = getPos(i.uv);
				half4 colorCubemap = texCUBElod(_EnvMap, pos);
                half3 envColor = DecodeHDR(colorCubemap, _EnvMap_HDR);
				return float4(envColor,1.0);
			}
			ENDCG
		}
	}
}