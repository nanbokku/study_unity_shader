Shader "Unlit/Ice"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AlphaLevel ("AlphaLevel", Range(0.5,2)) = 1
        _SpecularCoef ("SpecularCoef", float) = 1
        _SpecularPower ("SpecularPower", float) = 1
    }
    SubShader
    {
        //! Queueに注意．不透明オブジェクトの後に描画されるようにしておく．
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        //! alpha * (生成した色) + (1 - alpha) * (既に描画されている色)
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass    //! オブジェクトの背景画をテクスチャとして取得できるようになる
        {}

        Pass
        {
            Tags { "LightMode"="ForwardBase" }  //! これがないとLightColor0が取得できない

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 eyeDirection : TEXCOORD2;
            };

            fixed4 _LightColor0;
            sampler2D _GrabTexture;     // オブジェクトの背景テクスチャ
            float4 _GrabTexture_ST;
            float3 _Color;
            float _AlphaLevel;
            float _SpecularCoef;
            float _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(v.vertex);

                // ワールド座標系の法線ベクトルを取得
                o.normal = UnityObjectToWorldNormal(v.normal);

                // 視線方向ベクトルを取得
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed alpha = 1 - abs(dot(i.normal, i.eyeDirection));
                alpha *= _AlphaLevel;  // 調整

                // Phong反射
                float3 lightDir = normalize(_WorldSpaceLightPos0);  //! _WorldSpaceLightPos0 は Directional Light の光源の向き
                float3 NdotL = max(0, dot(i.normal, lightDir));
                float3 R = lightDir - 2 * i.normal * NdotL;
                fixed3 diffuse = _LightColor0.rgb * _SpecularCoef * pow(dot(R, i.eyeDirection), _SpecularPower);

                fixed4 col = fixed4(_Color, alpha) * fixed4(diffuse, 1);

                // TODO: 屈折させたい
                float2 uv = i.grabPos.xy / i.grabPos.w;
                uv.y = uv.y * -1 + 1;               // 反転していたのでY軸反転
                col = tex2D(_GrabTexture, uv);
                return col;
            }
            ENDCG
        }
    }
}
