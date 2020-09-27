Shader "Unlit/Mekuri"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HiddenTex ("HiddenTexture", 2D) = "white" {}
        _Slope ("Slope", float) = 1
        _BottomPointPosition ("BottomPointPosition", Vector) = (0, 0, 0, 0)
        _Speed ("Speed", float) = 1
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
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float4 intersection : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _HiddenTex;
            float4 _HiddenTex_ST;
            float _Slope;                   // めくるときの傾き
            float3 _BottomPointPosition;    // 紙の下にある頂点どちらかの位置(傾きで決まる)
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv, _HiddenTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                // 辺との交点を計算
                fixed b = _BottomPointPosition.y * _Time * _Speed - _Slope * _BottomPointPosition.x * _Time * _Speed;   // 時間に応じて位置を移動
                o.intersection.xy = float2(0, b);
                o.intersection.zw = float2(1, _Slope + b);
                o.color = v.color;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 線分のどちら側にあるかを判定する
                float3 vec1 = float3(i.intersection.zw - i.intersection.xy, 0.0);
                float3 vec2 = float3(i.uv1 - i.intersection.xy, 0.0);
                fixed isRight = cross(vec1, vec2).z;

                // sample the texture
                fixed4 mainColor = tex2D(_MainTex, i.uv1) * i.color;
                fixed4 hiddenColor = tex2D(_HiddenTex, i.uv2) * fixed4(1,1,1,1);
                fixed4 col = lerp(hiddenColor, mainColor, step(0, isRight));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
