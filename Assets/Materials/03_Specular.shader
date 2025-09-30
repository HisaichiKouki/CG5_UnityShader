Shader "Unlit/03_Specular"
{

    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition=mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 eyeDir=normalize(_WorldSpaceCameraPos.xyz-i.worldPosition);
                float3 lightDir=normalize(_WorldSpaceLightPos0);
                i.normal=normalize(i.normal);
                float3 reflectDir=-lightDir+2*i.normal*dot(i.normal,lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir,eyeDir)),20)*_Lightcolor0;
                return specular;
            }
            ENDCG
        }
    }
}
