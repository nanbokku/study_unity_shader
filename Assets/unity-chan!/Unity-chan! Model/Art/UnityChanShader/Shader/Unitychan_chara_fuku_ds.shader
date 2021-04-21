Shader "UnityChan/Clothing - Double-sided"
{
	Properties
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 1, 1)
		_SpecularPower ("Specular Power", Float) = 20
		_EdgeThickness ("Outline Thickness", Float) = 1
				
		_MainTex ("Diffuse", 2D) = "white" {}
		_FalloffSampler ("Falloff Control", 2D) = "white" {}
		_RimLightSampler ("RimLight Control", 2D) = "white" {}
		_SpecularReflectionSampler ("Specular / Reflection Mask", 2D) = "white" {}
		_EnvMapSampler ("Environment Map", 2D) = "" {} 
		_NormalMapSampler ("Normal Map", 2D) = "" {} 
		_OutlineWidth ("Outline Width", float) = 0.05
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
		_BlightColor ("Blight Color", Color) = (1, 1, 1, 1)
		_DarkColor ("Dark Color", Color) = (0, 0, 0, 1)
	}

	SubShader
	{
		Tags
		{
			"RenderType"="Opaque"
			"Queue"="Geometry"
			"LightMode"="ForwardBase"
		}

		Pass
		{
			Cull Front
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float _OutlineWidth;
			float4 _OutlineColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				float4 normal = mul(UNITY_MATRIX_IT_MV, v.normal);	// UNITY_MATRIX_IT_MVはMVの逆行列の転置行列
				float2 offset = TransformViewToProjection(normal.xy);	// zを求めても意味がないので求めない
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertex.xy += offset.xy * o.vertex.z * _OutlineWidth;	// 遠くても小さくても同じ大きさのアウトラインを作るため
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return _OutlineColor;
			}
			ENDCG
		}	

		Pass
		{
			Cull Off
			ZTest LEqual
CGPROGRAM
#pragma multi_compile_fwdbase
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#define ENABLE_NORMAL_MAP
#define ENABLE_TOON
#include "CharaMain.cg"
ENDCG
		}

		Pass
		{
			Cull Front
			ZTest Less
CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "CharaOutline.cg"
ENDCG
		}

	}

	FallBack "Transparent/Cutout/Diffuse"
}
