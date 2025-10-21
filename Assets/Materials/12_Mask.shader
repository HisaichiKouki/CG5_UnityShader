Shader "Unlit/12_Mask"
{
    Properties{
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("MaskTex", 2D) = "white" { }
        _MaskT("MaskT", range(0, 1)) = 0.5

    }

    SubShader
    {

        Tags{
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            # include "UnityCG.cginc"
            # include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            sampler2D _MaskTex;
            float4 _MainTex_ST;
            float _AmbientScale;

            float _MaskT;
            struct appdate
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;

            };


            v2f vert(appdate v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 itling = _MainTex_ST.xy;
                float2 offset = _MainTex_ST.zw;
                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv * itling + offset);
                fixed4 ambient = _Color * tex;

               fixed4 mask = tex2D(_MaskTex, i.uv * itling + offset);
               clip(_MaskT - mask.r);

               return ambient;
            }
            ENDCG
        }
    }
}
