Shader "Unlit/Dithering"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Alpha ("Alpha", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DitherMaskLOD2D;
            float4 _Color;
            float _Alpha;

            v2f vert (appdata v, out float4 vertex : SV_POSITION)
            {
                v2f o;
                vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i, UNITY_VPOS_TYPE vpos : VPOS) : SV_Target
            {
                // 4px x 4pxのブロックごとにテクスチャをマッピングする
                vpos *= 0.25;
                // ディザテクスチャのheightは4*16pxなので小数部分を16で割る
                vpos.y = frac(vpos.y) * 0.0625;
                // alphaに応じてオフセットを加える
                // alphaが1の時はyが0.9375～1の値をとるようにする
                vpos.y += _Alpha * 0.9375;

                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                UNITY_APPLY_FOG(i.fogCoord, col);

                // ディザの値はaチャンネルに格納されている
                clip(tex2D(_DitherMaskLOD2D, vpos).a - 0.5);
                return col;
            }
            ENDCG
        }
    }
}
