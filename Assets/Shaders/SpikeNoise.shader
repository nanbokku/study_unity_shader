Shader "Unlit/SpikeNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaxPulse ("MaxPulse", float) = 1
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _MaxPulse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // f(x)=((x-1)^(2)-1) sin(10 (x-2))
                fixed y = i.uv.y;
                fixed x = i.uv.x + _MaxPulse * (pow(y - 1, 2) - 1) * sin(10 * (y - 2));  // yの値に応じてxを変化させる
                fixed4 col = tex2D(_MainTex, fixed2(x, y));
                return col;
            }
            ENDCG
        }
    }
}
