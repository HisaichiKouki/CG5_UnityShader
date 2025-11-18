Shader "Unlit/18_ParallaxShader_Height"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _HeightTex ("Height", 2D) = "black" {}
        _ParallaxShallow("Shallow Parallax Scale", float) = 0
        _ParallaxDeep("Deep Parallax Scale", float) = 0.05

    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTS : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ParallaxShallow;
            sampler2D _HeightTex;
            float4 _HeightTex_ST;
            float _ParallaxDeep;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //ワールド空間の視線ベクトル
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;
                //タンジェント空間の基底ベクトルをワールド空間へ
                float3 t = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float3 n = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                float3 b = cross(n, t) * v.tangent.w * unity_WorldTransformParams.w;

               float3x3 tbn = float3x3(t,b,n);
                //視線ベクトルをタンジェント空間へ
                o.viewDirTS= mul(tbn,viewDirWS);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                //高さ
                float3 viewDirTS = normalize(- i.viewDirTS);
                float2 mainUV = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                float2 heightUV = i.uv * _HeightTex_ST.xy + _HeightTex_ST.zw;
                //高さマップのr値を参照して高さの情報を取得
                float height = tex2D(_HeightTex, heightUV).r;

                //浅い場所と深い場所でoffsetの計算
                float2 shallowOffset = viewDirTS.xy * _ParallaxShallow;
                float2 deepOffset = viewDirTS.xy * height * _ParallaxDeep;

                //高さ情報に応じてoffsetを使い分ける
                float2 uv = mainUV + lerp(shallowOffset, deepOffset, height);

                // apply fog
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
