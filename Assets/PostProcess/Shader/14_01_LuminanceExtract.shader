Shader "Custom/14_01_LuminanceExtract"
{
    Properties
    {
        //キドの閾値最小
       _ThresholdMin("ThresholdMin",Float)=1
       //輝度の閾値最大
       _ThresholdMax("ThresholdMax",Float)=1.5
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

          


            CBUFFER_START(UnityPerMaterial)
                float _ThresholdMin;
                float _ThresholdMax;
            CBUFFER_END

           

            half4 Frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, IN.texcoord);
                //輝度計算
                half luminance=
                color.r*0.2126+
                color.g*0.7152+
                color.b*0.0772;

                //閾値を超えた輝度値を0~1に変換
                luminance=smoothstep(_ThresholdMin,_ThresholdMax,luminance);
                //輝度値で色を乗算。Min以下は切り捨て
                half4 output=color*luminance;
                output.a=1;
                return output;
            }
            ENDHLSL
        }
    }
}
