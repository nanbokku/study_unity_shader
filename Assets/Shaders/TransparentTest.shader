// 半透明オブジェクトが重なっている時に、重なり部分の描画順が変わってしまう問題に対処するためのシェーダー
// Queueをインスペクタから変更し、後に描画するオブジェクトの_Blendプロパティを調整することで、重なり部分が一定になる
Shader "Unlit/TransparentTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _DiffuseCoef ("Diffuse coefficient", Range(0, 1)) = 0.5
        _SpecularCoef ("Specular coefficient", Range(0, 1)) = 0.5
        _SpecularPower ("Specular power", float) = 2
        _Blend ("Blend", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "LightMode"="ForwardBase"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        ZTest always

        Pass
        {
            Tags {"Queue"="Transparent"}
            Stencil
            {
                Ref 1
                Comp Always
                Pass IncrSat
            }
            ColorMask 0
        }

        // Queueが小さいオブジェクトは全ての範囲で描かれる.
        // Queueが大きいオブジェクトは重なった部分が描かれない。
        Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
                Pass Keep
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _DiffuseCoef;
            float _SpecularCoef;
            float _SpecularPower;
            fixed4 _LightColor0;

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                UNITY_FOG_COORDS(1)
                float3 eyeDirection : TEXCOORD2;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o, o.vertex);
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0);
                fixed NdotL = saturate(dot(i.normal, lightDirection));
                fixed3 diffuse = _LightColor0.rgb * _DiffuseCoef * NdotL;

                fixed3 R = lerp(2 * i.normal * NdotL - lightDirection, 0, step(NdotL, 0));  // 内積が負の数なら0とする
                fixed3 specular = _LightColor0.rgb * _SpecularCoef * pow(saturate(dot(R, i.eyeDirection)), _SpecularPower);

                fixed4 color = _Color * tex2D(_MainTex, i.uv);
                color.rgb += diffuse + specular + UNITY_LIGHTMODEL_AMBIENT;
                UNITY_APPLY_FOG(i.fogCoord, color);

                return color;
            }
            ENDCG
        }

        // Queueが小さいオブジェクトはこのパスを通らない
        // Queueが大きいオブジェクトはこのパスを通る
        Pass
        {
            BlendOp Add
            Stencil
            {
                Ref 2
                Comp LEqual // ステンシルバッファが2以上のとき
                Pass Keep
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 eyeDirection : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _DiffuseCoef;
            float _SpecularCoef;
            float _SpecularPower;
            fixed4 _LightColor0;
            float _Blend;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.eyeDirection = normalize(WorldSpaceViewDir(v.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0);
                fixed3 NdotL = saturate(dot(i.normal, lightDirection));
                fixed3 diffuse = _LightColor0.rgb * _DiffuseCoef * NdotL;

                fixed3 R = lerp(2 * i.normal * NdotL - lightDirection, 0, step(NdotL, 0));
                fixed3 specular = _LightColor0.rgb * _SpecularCoef * pow(saturate(dot(R, i.eyeDirection)), _SpecularPower);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb += diffuse + specular + UNITY_LIGHTMODEL_AMBIENT;
                col.rgb *= _Blend;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
