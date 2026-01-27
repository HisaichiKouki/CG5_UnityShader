Shader "Custom/DepthOfField_CoC"
{
    Properties
    {
         _FNumber            ("F値", Range(1,32)) = 2.8
         _FocalLengthMilimerter ("レンズ焦点距離[mm]", Float) = 50
         _FocusDistance      ("ピント距離[m]", Float) = 2
         _BlurLevelWidth     ("ブラー範囲", Range(0,1)) = 0.1
         _LowBlurLevel       ("弱ブラー閾値", Range(0,1)) = 0.05
         _MiddleBlurLevel    ("中ブラー閾値", Range(0,1)) = 0.1
         _HighBlurLevel      ("強ブラー閾値", Range(0,1)) = 0.3
         _DepthTexture       ("深度テクスチャ", 2D)  = "black"{}
         _LowBlurTexture     ("弱ブラーテクスチャ", 2D) = "black"{}
         _MiddleBlurTexture  ("中ブラーテクスチャ", 2D) = "black"{}
         _HighBlurTexture    ("強ブラーテクスチャ", 2D) = "black"{}
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //ポストエフェクトに必要なファイル
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           
            // ブラーテクスチャと深度テクスチャの定義
            TEXTURE2D(_LowBlurTexture);
            TEXTURE2D(_MiddleBlurTexture);
            TEXTURE2D(_HighBlurTexture);
            TEXTURE2D(_DepthTexture);

            // Propertiesで操作する変数はテクスチャを除き
            // CBUFFERにまとめる
            CBUFFER_START(UnityPerMaterial)
                // F値
                float _FNumber;
                // レンズ焦点距離[mm]
                float _FocalLengthMilimerter;
                // ピント距離[m]
                float _FocusDistance;
                //ブラー範囲
                float _BlurLevelWidth;
                //弱ブラー閾値
                float _LowBlurLevel;
                //中ブラー閾値
                float _MiddleBlurLevel;
                //強ブラー閾値
                float _HighBlurLevel;
           
            CBUFFER_END

           
            half4 Frag(Varyings IN) : SV_Target
            {
                //深度値を取得
                half depth=SAMPLE_TEXTURE2D(_DepthTexture,sampler_LinearClamp,IN.texcoord);
                // 焦点距離をmmからmへ
                float focalLengthMerter = _FocalLengthMilimerter / 1000;
                // ゼロ除算回避
                depth = max(depth, 1e-3);
                // ゼロ除算回避
                _FocusDistance = max(_FocusDistance, focalLengthMerter + 1e-3);
                // ボケ量の最小単位
                float sensorTexelSize = min(_BlitTexture_TexelSize.x, _BlitTexture_TexelSize.y);
                
                // 錯乱円サイズの計算
                float coc = abs(_FocusDistance - depth) / depth * focalLengthMerter * focalLengthMerter / (_FNumber * (_FocusDistance - focalLengthMerter)) / sensorTexelSize;
                // 0-1でクランプ
                coc = saturate(coc);

                // ピントが合ってるテクスチャを取得
                half4 inFocusColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, IN.texcoord);
                // 弱ブラーテクスチャのサンプリング
                half4 lowBlurColor = SAMPLE_TEXTURE2D(_LowBlurTexture, sampler_LinearClamp, IN.texcoord);
                // 中ブラーテクスチャのサンプリング
                half4 middleBlurColor = SAMPLE_TEXTURE2D(_MiddleBlurTexture, sampler_LinearClamp, IN.texcoord);
                // 強ブラーテクスチャのサンプリング
                half4 highBlurColor = SAMPLE_TEXTURE2D(_HighBlurTexture, sampler_LinearClamp, IN.texcoord);
                // 弱ブラーがかかる範囲
                float lowWeight = smoothstep(_LowBlurLevel - _BlurLevelWidth / 2, _LowBlurLevel + _BlurLevelWidth / 2, coc);
                // 中ブラーがかかる範囲
                float middleWeight = smoothstep(_MiddleBlurLevel - _BlurLevelWidth / 2, _MiddleBlurLevel + _BlurLevelWidth / 2, coc);
                // 強ブラーがかかる範囲
                float highWeight = smoothstep(_HighBlurLevel - _BlurLevelWidth / 2, _HighBlurLevel + _BlurLevelWidth / 2, coc);
            
                // //ブレンド前に色を差し替えてデバッグする
                // //弱ブラー箇所は赤に
                // lowBlurColor=half4(1,0,0,1);
                // //中ブラー箇所は緑に
                // middleBlurColor=half4(0,1,0,1);
                // //強ブラー箇所は青に
                // highBlurColor=half4(0,0,1,1);

                // 各テクスチャのブレンド
                half4 output = inFocusColor;
                output = lerp(output, lowBlurColor, lowWeight);
                output = lerp(output, middleBlurColor, middleWeight);
                output = lerp(output, highBlurColor, highWeight);

                return output;
            }
            ENDHLSL
        }
    }
}
