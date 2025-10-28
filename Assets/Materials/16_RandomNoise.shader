Shader "Unlit/16_RandomNoise"
{
   Properties{
    _Density("Density",float)=10
    }

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            # include "UnityCG.cginc"
            # include "Lighting.cginc"

            float _Density;

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

            float random(float2 fact)
            {
                return frac(sin(dot(float2(fact.x,fact.y),float2(12.9898,78.233)))*43758.5453);

            }


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
                float density=_Density;
                float2 uv=floor(i.uv*density)/density;
                float r=random(uv);

                return fixed4(r,r,r,1);
            }
            ENDCG
        }

    }
}
