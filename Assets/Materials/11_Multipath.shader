Shader "Unlit/11_Multipath"
{
    Properties{
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Discard("Discard", range(0, 1)) = 0.5
        _ScrollSpeed("ScrollSpeed", Vector) =(0,0,0,0 )

    }

    SubShader
    {

        //Tags{
            // "Queue" = "Transparent"
        //}
        //Blend SrcAlpha OneMinusSrcAlpha

        CGINCLUDE
        #pragma vertex vert
        #pragma fragment frag

        # include "UnityCG.cginc"
        # include "Lighting.cginc"

        fixed4 _Color;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float _AmbientScale;
        float4 _ScrollSpeed;

        float _Discard;
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
        ENDCG



        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            Cull front
            CGPROGRAM


            fixed4 frag(v2f i) : SV_Target
            {
                float2 itling = _MainTex_ST.xy;
                float2 offset = _MainTex_ST.zw;
                offset+=_ScrollSpeed.xy* _Time.y;

                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv * itling + offset);
                fixed4 ambient = _Color * tex;

                //ディゾルブ
                clip(ambient.r - _Discard);
                return fixed4(0, 1, 1, 1);
            }
            ENDCG
        }

        Pass
        {
            Cull back
            CGPROGRAM


            fixed4 frag(v2f i) : SV_Target
            {
                float2 itling = _MainTex_ST.xy;
                float2 offset = _MainTex_ST.zw;
                 offset+=_ScrollSpeed.xy* _Time.y;
                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv * itling + offset);
                fixed4 ambient = _Color * tex;

                //ディゾルブ
                clip(ambient.r - _Discard);

                //if (ambient.a <= _Discard)
                //{
                    // discard;

                //}

                return ambient;
            }
            ENDCG
        }
    }
}
