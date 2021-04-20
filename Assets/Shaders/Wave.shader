Shader "Unlit/Wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveLevel ("WaveLevel", Range(0,3)) = 1
        _Speed ("Speed", Range(1, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _WaveLevel;   // 波の大きさ
            float _Speed;       // 波打つ速さ
            const float PI = 3.14159;

            v2f vert (appdata v)
            {
                // fixed dist = distance(fixed2(0,0), v.vertex.xz);

                // 頂点をずらしてなびくようにする
                v.vertex.y = v.vertex.y +  _WaveLevel * sin(v.vertex.x + v.vertex.z + _Time.y * _Speed);    

                // v.vertex.y = v.vertex.y + _WaveLevel * sin(dist + _Time.y * _Speed);    // 中心から同心円状に波打つ

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
