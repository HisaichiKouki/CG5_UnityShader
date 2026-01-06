Shader "Custom/ex01_02_IntersectionHighLight"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        //透過有効の距離
        _Softness("Softness",Range(0.001,1.0))=0.15
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Name "IntersectionHighLight"
            Cull off
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                //ParticleSystemで設定する色は頂点カラーとして受け取れる
                float4 color:COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color:COLOR;
                float4 screenPosPreDivW:TEXCOORD1;
                //カメラからの距離
                float eyeDepth:TEXCOORD2;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float _Softness;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs vp=GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS=vp.positionCS;

                //BaseMap_STを考慮してuv座標を設定する
                OUT.uv=TRANSFORM_TEX(IN.uv,_BaseMap);
                OUT.color=IN.color;

                //スクリーン座標を手動で行うための情報
                OUT.screenPosPreDivW=ComputeScreenPos(OUT.positionCS);
                //ViewSpace上で距離を測る
                OUT.eyeDepth=abs(vp.positionVS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
               float2 screenUV=IN.screenPosPreDivW.xy/IN.screenPosPreDivW.w;
               //シーン深度をサンプルし、カメラ空間距離へ変換
               float rawSceneDepth=SampleSceneDepth(screenUV);
               //深度値をメートル単位に変換
               float sceneEyeDepth=LinearEyeDepth(rawSceneDepth,_ZBufferParams);
               //交差付近でフェード。シーンの方が手前なら負となり消える
               float diff=sceneEyeDepth-IN.eyeDepth;
               //1-(値)にして近接箇所のみ描画をする
               float soft=1-saturate(diff/max(_Softness,0.001));
               half4 tex=SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,IN.uv);
               //テクスチャカラーに頂点カラーを乗算
               half4 col=tex*IN.color;
               //深度値と距離で得た値をアルファ値に乗さん
               col.a*=soft;
               return col;
            }
            ENDHLSL
        }
    }
}
