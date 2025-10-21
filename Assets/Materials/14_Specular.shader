Shader "Unlit/14_Specular"
{

    Properties{

        _MaskTex("MaskTex", 2D) = "black" { }
        _Color("Color", Color) = (1, 0, 0, 1)
        _MaskT("MaskT", range(0, 1)) = 0.5
    _SpecurlarStrength("SpecurlarStrength",range(0.0001,30))=5

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
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskT;
float _SpecurlarStrength;

struct appdate
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
                float3 normal : NORMAL;
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
                float2 itling = _MaskTex_ST.xy;
                float2 offset = _MaskTex_ST.zw;

fixed4 ambient = _Color * 0.3f * _LightColor0;

float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0.xyz));
fixed4 diffuse = _Color * intensity * _LightColor0;

float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                i.normal = normalize(i.normal);
                float3 reflectDir = - lightDir + 2 * i.normal * dot(i.normal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), _SpecurlarStrength) * _LightColor0;
                fixed4 mask = tex2D(_MaskTex, i.uv * itling + offset);

                //fixed4 phong = ambient + diffuse + specular;
                return ambient+diffuse+ mask.r * specular;
            }
            ENDCG
        }
    }
}
