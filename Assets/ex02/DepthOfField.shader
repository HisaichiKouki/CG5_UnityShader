Shader "Custom/DepthOfField"
{
    Properties
    {
       //フォーカスがあう距離
       _FocusDistance("FocusDistance",Float)=1.0
       //フォーカスがあう範囲
       _FocusRange("FocusRange",Float)=2.0
       //深度テクスチャ
       _DepthTexture("DepthTexture",2D)="black"{}
       //ブラーテクスチャ
       _BlurTexture("BlurTexture",2D)="black"{}
     }

    SubShader
    {
        Tags {  "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //ポストエフェクトに必要なファイル
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

           

            TEXTURE2D(_DepthTexture);
            TEXTURE2D(_BlurTexture);

            CBUFFER_START(UnityPerMaterial)
                float _FocusDistance;
                float _FocusRange;
            CBUFFER_END

            
            half4 Frag(Varyings IN) : SV_Target
            {
                //深度値を取得
                half depth=SAMPLE_TEXTURE2D(_DepthTexture,sampler_LinearClamp,IN.texcoord);

                //フォーカス位置との差を計算
                half focusDistance=abs(_FocusDistance-depth);
                //フォーカス位置に近いほど1,遠いほど0になる値を計算
                half focusFactor=smoothstep(0.0,_FocusRange,focusDistance);
                //フォーカスがあってるテクスチャを取得
                half4 inFocusColor=SAMPLE_TEXTURE2D(_BlitTexture,sampler_LinearClamp,IN.texcoord);
                //フォーカスがあってないブラーテクスチャを取得
                half4  outOfFocusColor=SAMPLE_TEXTURE2D(_BlurTexture,sampler_LinearClamp,IN.texcoord);
                //focusFactorでフォーカスがあってるカメラテクスチャとフォーカスがぼけているブラーテクスチャをブレンド
                half4 output=lerp(inFocusColor,outOfFocusColor,focusFactor);
                
                return output;
            }
            ENDHLSL
        }
    }
}
