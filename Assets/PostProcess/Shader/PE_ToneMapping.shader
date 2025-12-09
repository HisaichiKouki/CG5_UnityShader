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
            //ラインハルトトーンマッピング
            half Reinhard(half lIn){
                return lIn/(1+lIn);
            }
            //ACES色空間に変換
            half3 MulAcesInputMatrix(half3 col){
                half3x3 acesInputMatrix=half3x3 (
                    0.59719,0.35458,0.04823,
                    0.07600,0.90834,0.01566,
                    0.02840,0.13383,0.83777
                );
                return mul(acesInputMatrix,col);
            }
            //人の間隔に近く、出力に適した色に変換
            half3 RRTAndODFit(half3 v){
                half3 a=v*(v+0.0245786)-0.000090537;
                half3 b=v*(0.983729*v+0.4329510)+0.238081;
                return a/b;
            }
            //sRGB空間に変換
            half3 MulAcesOutputMatrix(half3 col){
                half3x3 acesOutputMatrix=half3x3(
                    1.60475,-0.53108,-0.07367,
                    -0.10208,1.10813,-0.00605,
                    -0.00327,-0.07276,1.07602
                );
                return mul(acesOutputMatrix,col);
            }

            half4 Frag(Varyings input):SV_Target{

                half4 output=SAMPLE_TEXTURE2D(
                    _BlitTexture,sampler_LinearRepeat,
                    input.texcoord);

                half3 acesInput=MulAcesInputMatrix(output.rgb);
                half3 transpose=RRTAndODFit(acesInput);
                half3 acesOutput=MulAcesOutputMatrix(transpose);
                half4 outputColor=half4(acesOutput,1);

                    // //輝度を算出
                    // half lIn=GetLuminance(output.rgb);
                    // //輝度からトーンマッピングを算出
                    // half lOut=Reinhard(lIn);
                    // //トーンマッピング値を色に乗算
                    // half4 outputColor=output*lOut/max(lIn,0.01);
                    //アルファ値は1に固定
                    outputColor.a=1;
                    return outputColor;
            }
           
            ENDHLSL
        }
    }
}
