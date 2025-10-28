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
                float v00=random((floor(i.uv*density)+float2(0,0))/density);
                float v01=random((floor(i.uv*density)+float2(0,1))/density);
                float v10=random((floor(i.uv*density)+float2(1,0))/density);
                float v11=random((floor(i.uv*density)+float2(1,1))/density);
                
                float2 p=frac(i.uv*density);
                float v0010=lerp(v00,v10,p.x);
                float v0111=lerp(v01,v11,p.x);
                fixed lerpNoise=lerp(v0010,v0111,p.y);

                return fixed4(lerpNoise,lerpNoise,lerpNoise,1);
            }
            ENDCG
        }

    }
}
