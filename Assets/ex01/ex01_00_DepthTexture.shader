Shader "Custom/ex01_00_DepthTexture"
{
    Properties
    {
      
    }

    SubShader
    {
        Tags {
            //不透明の描画の後に描画する設定
             "RenderType" = "Transparent" 
             "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline" 
            }

        Pass
        {
            //パス名デバッグ用
            Name "DrawDepthTexture"
            //深度値への書き込みは行わない
            ZWrite off
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                //オブジェクト空間上の座標
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                //深度サンプル用
                float4 screenPosPreDivW:TEXCOORD1;
            };

           
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                //オブジェクト空間上の座標をワールド空間、ビュー空間、クリップ空間等に変換する
                VertexPositionInputs vp=GetVertexPositionInputs(IN.positionOS.xyz);
                //クリップ空間の取得
                OUT.positionCS=vp.positionCS;

                //UV座標の取得
                OUT.uv=IN.uv;
                //スクリーン座標を手動で行うための情報
                OUT.screenPosPreDivW=ComputeScreenPos(OUT.positionCS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //視錐台のビュー空間のXY座標を0-1の値で処理されるクリップ空間に押し込んでいる
                float2 screenUV=IN.screenPosPreDivW.xy/IN.screenPosPreDivW.w;
                //深度値の値を取得
                float rawScreenDepth=SampleSceneDepth(screenUV);
               //赤に変換
               half4 col=half4(1,0,0,0)*rawScreenDepth*10;
               //アルファ値は1に
               col.a=1;
               return col;
            }
            ENDHLSL
        }
    }
}
