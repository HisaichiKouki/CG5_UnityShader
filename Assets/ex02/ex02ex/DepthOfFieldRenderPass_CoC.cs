using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DepthOfFieldRenderPass_CoC : ScriptableRenderPass
{
    private Material depthMat_;
    private Material lowBlurMat_;
    private Material middleBlurMat_;
    private Material highBlurMat_;
    private Material dofMat_;

    //シェーダーないで定義されている変数のIDを取得
    static readonly int depthTexID = Shader.PropertyToID("_DepthTexture");
    static readonly int lowBlurTexID = Shader.PropertyToID("_LowBlurTexture");
    static readonly int middleBlurTexID = Shader.PropertyToID("_MiddleBlurTexture");
    static readonly int highBlurTexID = Shader.PropertyToID("_HighBlurTexture");

    class DepthOfFieldPassData
    {
        public TextureHandle sourceTex;
        public TextureHandle depthTex;
        public TextureHandle blurLowTex;
        public TextureHandle blurMiddleTex;
        public TextureHandle blurHighTex;
        public TextureHandle destination;
        public Material material;
    }
    private void DepthOfFieldBlit(RenderGraph renderGraph,
        TextureHandle cameraTex,
        TextureHandle destinationTex,
        TextureHandle depthTex,
        TextureHandle blurLowTex,
        TextureHandle blurMiddleTex,
        TextureHandle blurHighTex
        )
    {
        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass("DepthOfFieldBlit", out DepthOfFieldPassData passData))
        {
            //必要なデータを集める
            passData.sourceTex = cameraTex;
            passData.depthTex = depthTex;
            passData.blurLowTex = blurLowTex;
            passData.blurMiddleTex = blurMiddleTex;
            passData.blurHighTex = blurHighTex;
            passData.destination = destinationTex;
            passData.material = dofMat_;

            //Blit用に使用するテクスチャを割り当て
            builder.UseTexture(passData.sourceTex);
            builder.UseTexture(passData.depthTex);
            builder.UseTexture(passData.blurLowTex);
            builder.UseTexture(passData.blurMiddleTex);
            builder.UseTexture(passData.blurHighTex);
            //出力先テクスチャを割り当て
            builder.SetRenderAttachment(passData.destination, 0);

            //描画関数の登録
            builder.SetRenderFunc((DepthOfFieldPassData data, RasterGraphContext ctx) =>
            {
                //合成用のテクスチャを_DepthTexに渡す
                data.material.SetTexture(depthTexID, data.depthTex);
                //合成用のテクスチャを_BlurTexに渡す
                data.material.SetTexture(lowBlurTexID, data.blurLowTex);
                data.material.SetTexture(middleBlurTexID, data.blurMiddleTex);
                data.material.SetTexture(highBlurTexID, data.blurHighTex);
                //Blitコマンドを積む
                Blitter.BlitTexture(ctx.cmd, data.sourceTex, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }
    }

    public DepthOfFieldRenderPass_CoC(
        Material depthMat,
        Material dofMat,
        Material lowBlurMat,
        Material middleBlurMat,
        Material highBlurMat)
    {
        depthMat_ = depthMat;
        dofMat_ = dofMat;
        lowBlurMat_ = lowBlurMat;
        middleBlurMat_ = middleBlurMat;
        highBlurMat_ = highBlurMat;
    }

    public override void RecordRenderGraph(
          RenderGraph renderGraph,
          ContextContainer frameData
      )
    {
        if (depthMat_ == null || lowBlurMat_ == null || middleBlurMat_ == null || highBlurMat_ == null || dofMat_ == null)
        {
            //material_がnullなら従来通りの描画をおこなう
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }
        //このフレームの描画リソースを取得する
        UniversalResourceData resourceData =
            frameData.Get<UniversalResourceData>();
        //カメラのテクスチャを取得
        TextureHandle cameraTex = resourceData.activeColorTexture;
        //深度テクスチャ
        TextureDesc depthTexDesc = renderGraph.GetTextureDesc(cameraTex);
        depthTexDesc.name = "_DepthTex";
        //深度は使わない
        depthTexDesc.depthBufferBits = 0;
        depthTexDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
        //テクスチャの作成
        TextureHandle depthTex = renderGraph.CreateTexture(depthTexDesc);

        //ブラーテクスチャ
        TextureDesc blurTexDesc = renderGraph.GetTextureDesc(cameraTex);
        blurTexDesc.name = "_LowBlurTex";
        //縮小バッファ
        int div = 2;
        blurTexDesc.width /= div;
        blurTexDesc.height /= div;
        blurTexDesc.depthBufferBits = 0;
        TextureHandle lowBlurTex = renderGraph.CreateTexture(blurTexDesc);

        blurTexDesc.name = "_MiddleBlurTex";
        TextureHandle middleBlurTex = renderGraph.CreateTexture(blurTexDesc);

        blurTexDesc.width /= div;
        blurTexDesc.height /= div;
        blurTexDesc.depthBufferBits = 0;
        blurTexDesc.name = "_HighBlurTex";
        TextureHandle highBlurTex = renderGraph.CreateTexture(blurTexDesc);

        //出力先テクスチャ
        TextureDesc destinationTexDesc = renderGraph.GetTextureDesc(cameraTex);
        destinationTexDesc.name = "_DestinationTex";
        destinationTexDesc.depthBufferBits = 0;
        TextureHandle destinationTex = renderGraph.CreateTexture(destinationTexDesc);
        //深度値を抽出する
        RenderGraphUtils.BlitMaterialParameters depthTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex, depthTex, depthMat_, 0);
        //URPに適用
        renderGraph.AddBlitPass(depthTexBlitDesc, "DrawDepthBlit");

        //弱ブラーの適用
        RenderGraphUtils.BlitMaterialParameters lowBlurTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex, lowBlurTex, lowBlurMat_, 0);
        //URPに適用
        renderGraph.AddBlitPass(lowBlurTexBlitDesc, "DrawLowBlurBlit");

        //中ブラーの適用
        RenderGraphUtils.BlitMaterialParameters middleBlurTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex, middleBlurTex, middleBlurMat_, 0);
        //URPに適用
        renderGraph.AddBlitPass(middleBlurTexBlitDesc, "DrawMiddleBlurBlit");

        //高ブラーの適用
        RenderGraphUtils.BlitMaterialParameters highBlurTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex,highBlurTex, highBlurMat_, 0);
        //URPに適用
        renderGraph.AddBlitPass(highBlurTexBlitDesc, "DrawHighBlurBlit");

        //各テクスチャを渡して被写界深度の適用
        DepthOfFieldBlit(renderGraph, cameraTex, destinationTex, depthTex, lowBlurTex, middleBlurTex,highBlurTex);
        //被写界深度を適用したテクスチャをcameraTexに戻す
        renderGraph.AddCopyPass(destinationTex, cameraTex, "CopyDof");
    }
}

