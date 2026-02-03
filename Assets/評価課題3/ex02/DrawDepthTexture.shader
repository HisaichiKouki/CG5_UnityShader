Shader "Custom/DrawDepthTexture"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags {  "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
            //同期コンパイルの強制
            #pragma editor_sync_compilation

            //RPを使うための本体
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //深度バッファを使うための本体
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            //ポストエフェクトに必要なファイル
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           half4 Frag(Varyings IN) : SV_Target
            {
             // 深度テクスチャの取得。
            float rawSceneDepth =
            SampleSceneDepth(IN.texcoord);

            // 深度値をワールド空間のメートル単位に直し
            rawSceneDepth = LinearEyeDepth(rawSceneDepth,_ZBufferParams );

            // 返す
                return rawSceneDepth;
            }
        ENDHLSL
        }
    }
}
