Shader "Custom/13_02_GaussianBlur"
{
    Properties
    {
        //カーネルのピクセルごとの幅
        _StepWidth("ブラー密度", Range(0.001,0.02) )=0.05
        //カーネルの1辺の要素数
        _Sigma("ブラー強度",Range(0,0.02) )=0.001
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
            float _Sigma;
            CBUFFER_END

            float Gaussian(float x,float sigma){
                //ゼロ除算対策
                sigma=max(sigma,0.0001);
                //不要な値を省いたガウス関数
                return exp(-(x*x)/(2*sigma*sigma));

            }

            half4 Frag(Varyings IN):SV_Target{
                //出力する色の初期値は0
                half4 output=half4(0,0,0,0);
                //累計ウェイト
                float totalWeight=0;
                //カーネルの範囲は3*sigmaの範囲
                float kernelWidth=3*_Sigma;
                //回り込み防止用にテクセルサイズの半分を取得
                float2 margin=_BlitTexture_TexelSize.xy/2;

                int count=0;
                for(float y=-kernelWidth / 2; y<= kernelWidth / 2; y+= _StepWidth)
                {
                    for(float x=-kernelWidth / 2; x<= kernelWidth / 2; x+= _StepWidth)
                     {
                        //描画座標
                        float2 drawUV = IN.texcoord;
                        //サンプリング座標
                        float2 pickUV=IN.texcoord+float2(x,y);
                        //回り込み防止
                        pickUV=clamp(pickUV,margin,1-margin);
                        //それらの距離
                        float d=distance(drawUV,pickUV);
                        //ガウス関数から重みを産出
                        float weight=Gaussian(d,_Sigma);
                        //pickUVからテクスチャをサンプリングする
                        half4 color=SAMPLE_TEXTURE2D(_BlitTexture,sampler_LinearRepeat,pickUV);
                        //色に重みをかけてoutputに加算
                        output+=color*weight;
                        //累計の重みに加算
                        totalWeight+=weight;

                        count++;

                        // if(count>=1000){
                        //     break;
                        // }
                    }
                    // if(count>=1000){
                    //         break;
                    //     }
                }

                //全ての加算が終わったら累計の重みで割る
                output/=max(totalWeight,0.0001);
                //アルファ値は1で固定
                output.a=1;
                return output;
            }

           
            ENDHLSL
        }
    }
}
