Shader "PostEffect/ToneMapping"
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

            //色から輝度を算出
            half GetLuminance(half3 color){
                return dot(color,half3(0.2126,0.7152,0.0722));
            }
            //受け取った色をそのまま返す
            half Linear(half luminance){
                return luminance;
            }
            //全体的に割り算
            half Division(half luminance,half divider){
                return luminance/divider;
            }
            half4 Frag(Varyings input):SV_Target{
                half4 output=SAMPLE_TEXTURE2D(
                    _BlitTexture,sampler_LinearRepeat,
                    input.texcoord);

                    //輝度を算出
                    half lIn=GetLuminance(output.rgb);
                    //輝度からトーンマッピングを算出
                    half lOut=Division(lIn,8);
                    //トーンマッピング値を色に乗算
                    half4 outputColor=output*lOut/max(lIn,0.01);
                    //アルファ値は1に固定
                    outputColor.a=1;
                    return outputColor;
            }
           
            ENDHLSL
        }
    }
}
