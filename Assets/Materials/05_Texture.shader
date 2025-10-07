Shader "Unlit/05_Texture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
         _AmbientScale("AmbientScale", range(0,0.4))=0.3
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
             # include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
         float3 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AmbientScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv=v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 itling=_MainTex_ST.xy;
                float2 offset=_MainTex_ST.zw;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv*itling+offset);

                fixed4 ambient =col* _AmbientScale*_LightColor0;

                float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0.xyz));
                fixed4 diffuse =col*intensity * _LightColor0;

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
