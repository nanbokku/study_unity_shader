Shader "Unlit/Refrection"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AlphaLevel ("AlphaLevel", Range(0.5,2)) = 1
        _SpecularCoef ("SpecularCoef", float) = 1
        _SpecularPower ("SpecularPower", float) = 1
        _Distance ("Distance", Range(0,100)) = 1
        _RelativeRefractiveIndex ("RelativeRefractiveIndex", Range(0, 1)) = 0.75
    }
    SubShader
    {
        //! 描画結果をテクスチャに書き込みたいタイミングに応じてQueueを調整
        Tags { "Queue"="Transparent" }
        LOD 100

        //! alpha * (生成した色) + (1 - alpha) * (既に描画されている色)
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass    //! オブジェクトの背景画をテクスチャとして取得できるようになる
        { "_GrabPassTexture" }

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
                float4 samplingScreenPos : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 eyeDirection : TEXCOORD2;
            };

            fixed4 _LightColor0;
            sampler2D _GrabPassTexture;     // オブジェクトの背景テクスチャ
            float4 _GrabPassTexture_ST;
            float3 _Color;
            float _AlphaLevel;
            float _SpecularCoef;
            float _SpecularPower;
            float _Distance;            
            float _RelativeRefractiveIndex;  // 相対屈折率

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.grabPos = ComputeGrabScreenPos(v.vertex);

                // ワールド座標系の法線ベクトルを取得
                o.normal = UnityObjectToWorldNormal(v.normal);

                // 視線方向ベクトルを取得
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));

                // 屈折方向を求める
                half3 refractDir = refract(o.eyeDirection, o.normal, _RelativeRefractiveIndex);

                // 屈折方向の先にある位置をサンプリング位置とする
                half3 samplingPos = mul(unity_ObjectToWorld, v.vertex).xyz + refractDir * _Distance;

                // サンプリング点をプロジェクション変換
                half4 samplingScreenPos = mul(UNITY_MATRIX_VP, half4(samplingPos, 1));
                o.samplingScreenPos = ComputeScreenPos(samplingScreenPos);  // 0-1の範囲に正規化
                
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

                fixed4 col = tex2Dproj(_GrabPassTexture, i.samplingScreenPos);// * fixed4(_Color, alpha) * fixed4(diffuse, 1);
                return col;
            }
            ENDCG
        }
    }
}
