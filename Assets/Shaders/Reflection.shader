Shader "Unlit/Reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _DiffuseCoef ("DiffuseCoef", Float) = 1
        _SpecularCoef ("SpecularCoef", Float) = 1
        _SpecularPower ("SpecularPower", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }  //! これがないとLightColor0が取得できない

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
                float3 eyeDirection : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _LightColor0;
            fixed _DiffuseCoef;
            fixed _SpecularCoef;
            fixed _SpecularPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                // ワールド座標系の法線ベクトルを取得
                o.normal = UnityObjectToWorldDir(v.normal);

                // 視線方向ベクトルを取得
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Lambertian反射(拡散反射)
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0);    //! _WorldSpaceLightPos0 は Directional Light の光源の方向
                fixed3 NdotL = max(0, dot(i.normal, lightDirection));   //! 光源に照らされていないところは暗くするため負数(反射角が90度より大きくなる)は0にする
                fixed3 diffuse = _LightColor0.rgb * _DiffuseCoef * NdotL;

                // Phong反射(鏡面反射)
                fixed3 R = lerp(2 * i.normal * NdotL - lightDirection, 0, step(NdotL, 0));   //! 光源が当たらないところは反射しないようにする
                // 反射ベクトル
                fixed3 specular = _LightColor0.rgb * _SpecularCoef * pow(max(0, dot(R, i.eyeDirection)), _SpecularPower);

                fixed4 col = _Color * tex2D(_MainTex, i.uv);
                col.rgb = col.rgb + diffuse + specular;
           
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
