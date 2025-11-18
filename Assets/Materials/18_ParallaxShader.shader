Shader "Unlit/18_ParallaxShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Parallax("ParallaxScale",float)=0.5

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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTS:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Parallax;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //ワールド空間の視線ベクトル
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                float3 viewDirWS=_WorldSpaceCameraPos.xyz-worldPos;
                //タンジェント空間の基底ベクトルをワールド空間へ
                float3 t=normalize(mul((float3x3)unity_ObjectToWorld,v.tangent.xyz));
                float3 n=normalize(mul((float3x3)unity_ObjectToWorld,v.normal));                
                float3 b=cross(n,t)*v.tangent.w*unity_WorldTransformParams.w;

                //視線ベクトルをタンジェント空間へ
                o.viewDirTS=t*viewDirWS.x+b*viewDirWS.y+n*viewDirWS.z;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                //奥に
                float3 viewDirTS=normalize(-i.viewDirTS);
                //視差オフセット
                float2 offset=viewDirTS.xy*_Parallax;
                //UVスクロール
                float2 uv=i.uv+offset;



                
                // apply fog
                return tex2D(_MainTex,uv);
            }
            ENDCG
        }
    }
}
