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
			
			fixed4 frag (v2f_img i) : SV_Target
			{
				float2 xy = i.uv - float2(0.5,0.5);
				float zFlag = step(xy.x, 0.0) + step(xy.y, 0.0) - 1.0;
				zFlag = zFlag + (1.0 - abs(zFlag))*(step(xy.y,-xy.x)*2.0-1.0);
	
				xy = lerp(-float2(1.0,1.0), float2(1.0,1.0), xy * 2.0 * - zFlag);
				xy.xy = clamp(xy.xy, -1.0, 1.0);

				float z = 0.5 - 0.5 * (xy.x * xy.x+xy.y*xy.y);
				float4 pos = float4(xy , -z * zFlag, 0.0);
				half4 color_cubemap = texCUBElod(_EnvMap, pos);
                half3 env_color = DecodeHDR(color_cubemap, _EnvMap_HDR);
				return float4(env_color,1.0);
			}
			ENDCG
		}
	}
}