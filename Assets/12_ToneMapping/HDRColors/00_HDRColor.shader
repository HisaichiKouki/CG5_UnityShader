Shader "Unlit/00_HDRColor"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _Intensity("Intensity", Float) = 1
        _Texture("Texture", 2D) = "black"{}
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            fixed4 _Color;
            float _Intensity;
            sampler2D _Texture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_Texture, i.uv);
                // 色をIntensity倍する。
                half4 result = (tex + _Color)*_Intensity;
                // アルファ値は強制的に1
                result.a = 1;
                return result;
            }
            ENDCG
        }
    }
}
