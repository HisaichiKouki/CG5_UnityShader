Shader "PostEffect/Green"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
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

            half4 Frag(Varyings input):SV_Target{
                half4 output=SAMPLE_TEXTURE2D(
                    _BlitTexture,sampler_LinearRepeat,
                    input.texcoord);

                    output.r=0;
                    output.b=0;
                    return output;
            }
           
            ENDHLSL
        }
    }
}
