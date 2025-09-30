Shader "Unlit/02_Lambert"
{
Properties{
    _Color("Color",color)=(0,0,1,1)
}

   SubShader{
    Pass{
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        fixed4 _Color;

        struct appdate{
            float4 vertex : POSITION;
            float3 normal : NORMAL;

        };
        struct v2f{
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        v2f vert(appdate v){
            v2f o;
            o.vertex=UnityObjectToClipPos(v.vertex);
            o.normal=UnityObjectToWorldNormal(v.normal);
            return o;
        }
        fixed4 frag(v2f i):SV_TARGET{
            float intensity=saturate(dot(normalize(i.normal),_WorldSpaceLightPos0));

            fixed4 color=_Color;
            fixed4 diffuse=color*intensity*_LightColor0;
            return diffuse;
        }
        ENDCG
    }
   }
}
