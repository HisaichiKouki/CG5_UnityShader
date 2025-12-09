
Shader "PostEffect/ClippingChecker"
{
  SubShader
  {
    // URP用であると記述
    Tags{ "RenderPipeline" = "UniversalPipeline" }
    Pass
    {
      // ポストエフェクトでは不要な機能を切る
      ZWrite Off 
      ZTest Always 
      Blend Off 
      Cull Off
      // CGではなくHLSLを使う
      HLSLPROGRAM
        #pragma vertex Vert
        #pragma fragment Frag
        #pragma editor_sync_compilation


        // URP用のシェーダの機能群
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        // ポストエフェクト用の機能群
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"


        half GetLuminance(half3 color){
          return dot(color, half3(0.2126, 0.7152, 0.0722));
        }

        // vertはBlit.hlslに書いてあるので不要
        half4 Frag(Varyings input):SV_Target
        {
          // テクスチャの読み込み
          half4 output = SAMPLE_TEXTURE2D(
            _BlitTexture, sampler_LinearRepeat, 
            input.texcoord);

          // 輝度情報を取得
          half luminance = GetLuminance(output.rgb);
          // 輝度が過度だと紫にする
          half4 halationColor = half4(1,0,1,1);
          half4 outputColor = (luminance>1)?halationColor:output;
          return outputColor;
        }
      ENDHLSL
    }
  }
}

