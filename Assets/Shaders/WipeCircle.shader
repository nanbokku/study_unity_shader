Shader "Unlit/WipeCircle"
{
    Properties
    {
        _MainTex ("MainTexure", 2D) = "white" {}
        _Center ("Center", Vector) = (300,300, 0, 0)
        _Radius ("Radius", Range(0,600)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed2 _Center;
            fixed _Radius;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed dist = distance(_Center, i.uv * _ScreenParams.xy);

                return lerp(fixed4(0,0,0,1), tex2D(_MainTex, i.uv), step(dist, _Radius));
            }
            ENDCG
        }
    }
}
