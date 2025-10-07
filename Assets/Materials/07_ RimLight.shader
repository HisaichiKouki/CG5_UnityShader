Shader "Unlit/07_ RimLight"
{
    Properties{
        _Color("Color", Color) = (1, 0, 0, 1)
        _RimColor("RimColor",Color)=(1,1,1,1)
        _RimLightPower("RimLightPower",range(0,10))=1
        _Threshold("Threshold",range(1,10))=1
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
            fixed4 _RimColor;
            float _RimLightPower;
            float _Threshold;
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
                //視線ベクトルを求める
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition.xyz);
                //法線とカメラのベクトル内積の計算
                float rim=1.0-saturate(dot(eyeDir,i.normal));
                fixed4 color=lerp(_Color,_RimColor,pow(rim,_Threshold)*_RimLightPower);
               
                return color;
            }
            ENDCG
        }
    }
}
