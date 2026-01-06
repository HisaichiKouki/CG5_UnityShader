Shader "Custom/PE_PassThrough"
{
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            //同期コンパイルの強制
            #pragma editor_sync_compilation

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           
            half4 Frag(Varyings IN):SV_Target{
                half4 output=SAMPLE_TEXTURE2D(_BlitTexture,sampler_LinearRepeat,IN.texcoord);
                return output;
            }

           
            ENDHLSL
        }
    }
}
