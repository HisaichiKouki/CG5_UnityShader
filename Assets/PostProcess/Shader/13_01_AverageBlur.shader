Shader "Custom/13_01_AverageBlur"
{
    Properties
    {
        //カーネルのピクセルごとの幅
        _StepWidth("ブラー密度", Float )=0.01
        //カーネルの1辺の要素数
        _StepNums("ブラー強度",Float)=3.0
    }

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

            CBUFFER_START(UnityPerMaterial)
            float _StepWidth;
            float _StepNums;
            CBUFFER_END

            half4 Frag(Varyings IN):SV_Target{
                //出力する色の初期値は0
                half4 output=half4(0,0,0,0);
                //ループ可能カウンタ
                float loopCount=0;
                //ステップ数の整数化
                _StepNums=floor(_StepNums);
                //回り込み防止用にテクセルサイズの半分を取得
                float2 margin=_BlitTexture_TexelSize.xy/2;

                for(float y=-_StepNums/2; y<=_StepNums/2; y+=1.0){
                    for(float x=-_StepNums/2; x<=_StepNums/2; x+=1.0){
                        
                        //サンプリング座標
                        float2 pickUV=IN.texcoord+float2(x,y)*_StepWidth;
                        //回り込み防止
                        pickUV=clamp(pickUV,margin,1-margin);
                        //サンプリング座標から色をサンプリングし、outputに加算
                        output+=SAMPLE_TEXTURE2D(_BlitTexture,sampler_LinearRepeat,pickUV);
                        //カウンタに加算
                        loopCount+=1.0;

                    }
                }

                //全ての加算が終わったらループ回数で割る
                output/=loopCount;
                //アルファ値は1で固定
                output.a=1;
                return output;
            }

           
            ENDHLSL
        }
    }
}
