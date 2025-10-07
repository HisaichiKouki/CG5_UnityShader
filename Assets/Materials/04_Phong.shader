Shader "Unlit/04_Phong"
{
    Properties{
        _Color("Color", Color) = (1, 0, 0, 1)
        _AmbientScale("AmbientScale", range(0,0.4))=0.3
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

            fixed4 _Color;
            float _AmbientScale;
            struct appdate
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
                float3 normal : NORMAL;

            };


            v2f vert(appdate v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                
                fixed4 ambient =_Color* _AmbientScale*_LightColor0;

                float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0.xyz));
                fixed4 diffuse =_Color*intensity * _LightColor0;

                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                i.normal = normalize(i.normal);
                float3 reflectDir = - lightDir + 2 * i.normal * dot(i.normal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 20) * _LightColor0;

                fixed4 phong = ambient+diffuse+specular;
                return phong;
            }
            ENDCG
        }
    }
}
