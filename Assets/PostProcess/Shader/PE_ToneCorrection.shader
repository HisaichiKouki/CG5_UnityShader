Shader "PostEffect/ToneCorrection"
{
    Properties{
        saturation("彩度",float)=1
    }
    SubShader
    {
         Tags { "RenderType" = "UniversalPipeline" }

        Pass
        {
            Zwrite Off
            Ztest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation
            //URP用のシェーダの機能群
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //ポストプロセス用の機能群
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            half saturation;
            half4 Frag(Varyings input):SV_Target{
                half4 output=SAMPLE_TEXTURE2D(
                    _BlitTexture,sampler_LinearRepeat,
                    input.texcoord);

                    half grayscale=
                    0.2126*output.r+
                    0.7152*output.g+
                    0.0722*output.b;

                    half4 monochromeColor=half4 (grayscale,grayscale,grayscale,1);

                    half4 outputColor=lerp(monochromeColor,output,saturation);
                    return outputColor;
            }
           
            ENDHLSL
        }
    }
}
