Shader "Unlit/17_NormalMap"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex("MainTex", 2D) = "white" {}
        _NormalTex ("NormalTex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #include "UnityCG.cginc"
            # include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                 float3 normal : NORMAL;
                 float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 tangent:TANGENT;
                float3 binormal:TEXCOORD2;
            };
             fixed4 _Color;

            float4 _MainTex_ST;
            float4 _NormalTex_ST;
            sampler2D _NormalTex;
            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv=v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent=normalize(v.tangent.xyz);
                o.binormal=normalize(cross(o.normal,o.tangent)*v.tangent.w*unity_WorldTransformParams.w);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 nMap=tex2D(_NormalTex,i.uv*_NormalTex_ST.xy+_NormalTex_ST.zw)*2-1;
                float3 normal=normalize(nMap.xyz);
                i.tangent=normalize(i.tangent);
                i.binormal=normalize(i.binormal);
                i.normal=normalize(i.normal);

                float3 lNormal=normalize(i.tangent*nMap.x+i.binormal*nMap.y+i.normal*nMap.z);
                float3 wNormal=UnityObjectToWorldNormal(lNormal);
                
                float intensity=(saturate(dot(wNormal,_WorldSpaceLightPos0.xyz)));

                fixed4 col = tex2D(_MainTex, i.uv*_MainTex_ST.xy+_MainTex_ST.zw)*_Color;

                 fixed4 ambient =col* 0.3f*_LightColor0;

                //float intensity = saturate(dot(normalize(i.normal), _WorldSpaceLightPos0.xyz));
                fixed4 diffuse =col*intensity * _LightColor0;

                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                i.normal = normalize(wNormal);
                float3 reflectDir = - lightDir + 2 * i.normal * dot(i.normal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 20) * _LightColor0;

                fixed4 phong = ambient+diffuse+specular;
                // sample the texture
               // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                return phong;
            }
            ENDCG
        }
    }
}
