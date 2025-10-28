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

            float randomVec(float2 fact)
            {
                float2 angle=float2(
                    dot(fact,fixed2(127.1,311.7)),
                    dot(fact,fixed2(269.5,183.3))
                );
                return frac(sin(angle)*43758.5453123)*2-1;
            }

            float ValueNoise(float density,float2 uv)
            {
                float2 uvFloor=floor(uv*density);
                float2 uvFrac=frac(uv*density);

                float v00=random((uvFloor+float2(0,0))/density);
                float v01=random((uvFloor+float2(0,1))/density);
                float v10=random((uvFloor+float2(1,0))/density);
                float v11=random((uvFloor+float2(1,1))/density);
                
                fixed2 u=uvFrac*uvFrac*(3-2*uvFrac);
                float v0010=lerp(v00,v10,u.x);
                float v0111=lerp(v01,v11,u.x);

                return lerp(v0010,v0111,u.y);
            }

            float PerlinNoise(float density,float2 uv)
            {

                float2 uvFloor=floor(uv*density);
                float2 uvFrac=frac(uv*density);

                float v00=randomVec(uvFloor+float2(0,0));
                float v01=randomVec(uvFloor+float2(0,1));
                float v10=randomVec(uvFloor+float2(1,0));
                float v11=randomVec(uvFloor+float2(1,1));

                float c00=dot(v00,uvFrac-fixed2(0,0));
                float c01=dot(v01,uvFrac-fixed2(0,1));
                float c10=dot(v10,uvFrac-fixed2(1,0));
                float c11=dot(v11,uvFrac-fixed2(1,1));

                fixed2 u=uvFrac*uvFrac*(3-2*uvFrac);

                float v0010=lerp(c00,c10,u.x);
                float v0111=lerp(c01,c11,u.x);

                return lerp(v0010,v0111,u.y)/2+0.5;
            }

            float FractalSumNoise(float density,float2 uv)
            {
                float fn;
                fn=PerlinNoise(density*1,uv)*1.0/2;
                fn+=PerlinNoise(density*2,uv)*1.0/4;
                fn+=PerlinNoise(density*8,uv)*1.0/8;
                fn+=PerlinNoise(density*16,uv)*1.0/16;

                return fn;

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
                
                fixed pn=FractalSumNoise(density,i.uv);
                fixed4 col=fixed4(pn,pn,pn,1);
                
               return col;
            }
            ENDCG
        }

    }
}
