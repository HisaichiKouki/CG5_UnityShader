Shader "Unlit/08_EX1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 0, 0, 1)
         _AmbientScale("AmbientScale", range(0,0.4))=0.3
         _LightPower("LightPower",range(0.01,30))=20


        _RimColor("RimColor", Color) = (1, 1, 1, 1)
        _RimLightPower("RimLightPower", range(0, 10)) = 1
        _RimLightRange("RimLightRange", range(1, 10)) = 1

         _ShadowThereshold("ShadowThereshold",range(0,1))=0.5
         _LightThereshold("LightThereshold",range(0,1))=0.55
         _RimLightThreshold("RimLightThreshold",range(0.01,1))=0.5

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
            fixed4 _Color;
            float _LightPower;

            fixed4 _RimColor;
            float _RimLightPower;
            float _RimLightRange;
            
            float _ShadowThereshold;
            float _LightThereshold;
            float _RimLightThreshold;


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
                fixed4 diffuse =col*step(_ShadowThereshold,intensity) * _LightColor0;

                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 iNormal=normalize(i.normal);
                float3 reflectDir = - lightDir + 2 * iNormal * dot(iNormal, lightDir);
                fixed4 specular = pow(saturate(step(_LightThereshold,dot(reflectDir, eyeDir))), _LightPower) * _LightColor0;


                //法線とカメラのベクトル内積の計算
                float rim=1.0-saturate(dot(eyeDir,i.normal));
                fixed4 rimResult=lerp(fixed4(0,0,0,0),_RimColor,pow(rim,_RimLightRange)*_RimLightPower);
                rimResult=step(_RimLightThreshold,rimResult);

                fixed4 specularOnly=step(ambient,specular);
                // (1) AmbientOnly = ambient - 他成分がある部分を除外
                fixed4 ambientOnly = ambient * (1 - step(0.1,  + specular + rimResult));
                //fixed specularOnly=specular*step(0.5,1-diffuse);

                fixed4 result = ambientOnly;// + diffuseOnly*diffuse+ specularOnly * specular
                //fixed4 result = ambient+diffuse+specular+rimResult;



                return result;
            }
            ENDCG
        }
    }
}
