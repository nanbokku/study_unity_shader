Shader "Custom/Silhouette"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("MaskTexture", 2D) = "white" {}
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _MaskColor ("MaskColor", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        //! 障害物よりも後に描画されなければならない
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        LOD 100

       Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
                Pass IncrSat
            }
            ColorMask 0     // ステンシルのみ書き込む
            ZTest Always    // 深度に左右されずに書き込む
            ZWrite Off      // デプスバッファに書き込まない
        }

        Pass
        {
            Stencil
            {
                Ref 3
                Comp Always     // ZTest Alwaysではないので隠れている部分は対象外
                Pass Replace    // ステンシルバッファを3に書き換え
            }

            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _MainColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
        
        Pass
        {
            Stencil
            {
                Ref 2
                Comp Equal  // 2と一致するもの
            }
            ZTest Always    // 深度に関わらず描画

            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float4 _MaskColor;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MaskTex, i.uv) * _MaskColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
