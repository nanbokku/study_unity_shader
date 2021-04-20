Shader "Unlit/Transparent"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        //! Queueに注意．不透明オブジェクトの後に描画されるようにしておく．
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        
        //! alpha * (生成した色) + (1 - alpha) * (既に描画されている色)
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 eyeDirection : TEXCOORD2;
            };

            float3 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 法線をワールド座標系に変換
                o.normal = UnityObjectToWorldDir(v.normal);

                // 視線方向ベクトルを取得
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 視線方向と法線の角度が小さいほど透明になる
                fixed alpha = 1 - abs(dot(i.normal, i.eyeDirection));
                fixed4 col = fixed4(_Color, alpha);
                return col;
            }
            ENDCG
        }
    }
}
