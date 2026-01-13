using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class s14_BloomRenderPass : ScriptableRenderPass
{
    //ブラー用マテリアル
    private Material blurMaterial_;
    //輝度抽出用マテリアル
    private Material luminanceExtractMaterial_;
    //テクスチャ合成用マテリアル
    private Material compositeTextureMaterial_;

    //シェーダーで定義されてる変数の取得
    static readonly int luminanceBlurTextureID = Shader.PropertyToID("_OtherTexture");

    //自作Blitに必要なデータ
    class CompositePassDate
    {
        //_BlitTextureに渡されるテクスチャ
        public TextureHandle sourceTexture;
        //合成用のテクスチャ
        public TextureHandle otherTexture;
        //出力先
        public TextureHandle destination;
        //適用するマテリアル
        public Material material;
    }
    public s14_BloomRenderPass(Material luminanceExtractMaterial, Material blurMaterial, Material compositeTextureMaterial)
    {
        //コンストラクタ引数からマテリアルを取得
        blurMaterial_ = blurMaterial;
        luminanceExtractMaterial_ = luminanceExtractMaterial;
        compositeTextureMaterial_ = compositeTextureMaterial;
    }

    //RenderGraphへの描画設定や描画実行など一連の操作
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (blurMaterial_ == null || luminanceExtractMaterial_ == null || compositeTextureMaterial_ == null)
        {
            //material_がnullなら従来通りの描画をおこなう
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }
        //このフレームの描画リソースを取得する
        UniversalResourceData resourceData =
            frameData.Get<UniversalResourceData>();
        //取得したResourceDataがBackBufferであれば仕様上読み込み不可なので早期リターン
        if (resourceData.isActiveTargetBackBuffer)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }
        //カメラ(描画予定)のテクスチャを取得
        TextureHandle cameraTexture = resourceData.activeColorTexture;

        //ポストエフェクトを適用したテクスチャを作るためにカメラの情報を取得する
        TextureDesc originalTextureDesc = renderGraph.GetTextureDesc(cameraTexture);
        //名前などの一部設定は書き換える
        originalTextureDesc.name = "_OrignalTexture";
        //深度値は使わない
        originalTextureDesc.depthBufferBits = 0;
        //元サイズの一次テクスチャ
        TextureHandle origTempTexture = renderGraph.CreateTexture(originalTextureDesc);
        //縮小サイズの一次テクスチャ
        //輝度抽出とそのブラーの計算に使用する
        TextureDesc luminanceTextureDesc = originalTextureDesc;
        luminanceTextureDesc.name = "_SmallTempTexture";
        //縮小をおこなう
        int div = 4;
        originalTextureDesc.width /= div;
        originalTextureDesc.height /= div;
        //明るさ情報から作成するマスクなので、0-1の範囲に丸める
        luminanceTextureDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm;
        //輝度抽出テクスチャ
        TextureHandle luminanceTexture = renderGraph.CreateTexture(luminanceTextureDesc);
        //抽出した輝度にブラーを掛けるテクスチャ
        TextureHandle luminanceBlurTexture = renderGraph.CreateTexture(luminanceTextureDesc);
        //輝度を抽出する
        RenderGraphUtils.BlitMaterialParameters luminanceExtractBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, luminanceTexture, luminanceExtractMaterial_, 0);
        //設定をURPに適用
        renderGraph.AddBlitPass(luminanceExtractBlitMaterialParameters, "LuminanceExtractBlit");

        //輝度にブラーをかける
        RenderGraphUtils.BlitMaterialParameters brightnessBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(luminanceTexture, luminanceBlurTexture, blurMaterial_, 0);
        //設定をURPに適用
        renderGraph.AddBlitPass(brightnessBlitMaterialParameters, "BrightnessBlit");

        //Blitコマンドを自作してBuilderに積む
        using (IRasterRenderGraphBuilder builder=renderGraph.AddRasterRenderPass("BloomComposite",out CompositePassDate passDate))
        {
            //必要なデータを集める
            passDate.sourceTexture = cameraTexture;
            passDate.otherTexture = luminanceBlurTexture;
            passDate.destination = origTempTexture;
            passDate.material = compositeTextureMaterial_;
            //Blit用に使用するテクスチャの割り当て
            builder.UseTexture(passDate.sourceTexture);
            builder.UseTexture(passDate.otherTexture);
            //出力となるテクスチャの割り当て
            builder.SetRenderAttachment(passDate.destination, 0);
            //描画関数の登録
            builder.SetRenderFunc((CompositePassDate date, RasterGraphContext ctx) =>
            {
                //合成用のテクスチャをothertextureに渡す
                date.material.SetTexture(luminanceBlurTextureID,date.otherTexture);
                //第三引数はScaleBias拡縮はそれぞれ1でスクロールは0
                Blitter.BlitTexture(ctx.cmd, date.sourceTexture, new Vector4(1, 1, 0, 0), date.material, 0);

            });
        }
        //cameraTextureに戻す
        renderGraph.AddCopyPass(origTempTexture, cameraTexture, "CopyBloom");

        ////PassThroughをつかってサイズを戻す
        //RenderGraphUtils.BlitMaterialParameters upSampleBlitMaterialParameters =
        //   new RenderGraphUtils.BlitMaterialParameters(luminanceTexture, origTempTexture, blurMaterial_, 0);
        ////設定をURPに適用
        //renderGraph.AddBlitPass(upSampleBlitMaterialParameters, "UpSamplingBlitBlur");
        //renderGraph.AddCopyPass(origTempTexture, cameraTexture, "CopyBlur");
    }


}
