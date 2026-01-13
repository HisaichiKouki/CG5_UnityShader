Shader "Custom/14_01_TextureComposite"
{
    Properties
    {
       //輝度の閾値最大
       _OtherTexture("OtherTexture",2D)="black"{}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            //合成テクスチャの定義
            TEXTURE2D(_OtherTexture);
            SAMPLER(sampler_OtherTexture);


            half4 Frag(Varyings IN) : SV_Target
            {
               //一つ目のテクスチャをサンプリング
               half4 blitColor=SAMPLE_TEXTURE2D(_BlitTexture,sampler_LinearRepeat,IN.texcoord);
               //二つ目のテクスチャをサンプリング
               half4 otherColor=SAMPLE_TEXTURE2D(_OtherTexture,sampler_OtherTexture,IN.texcoord);
               //二つの色を合成
               half4 output=saturate(blitColor+otherColor);
               return output;
            }
            ENDHLSL
        }
    }
}
