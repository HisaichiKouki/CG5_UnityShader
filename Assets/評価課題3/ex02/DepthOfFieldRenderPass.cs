using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DepthOfFieldRenderPass : ScriptableRenderPass

{
    [SerializeField] Material depthMat_;
    [SerializeField] Material blurMat_;
    [SerializeField] Material dofMat_;

    //シェーダーないで定義されている変数のIDを取得
    static readonly int depthTexID = Shader.PropertyToID("_DepthTexture");
    static readonly int blurTexID = Shader.PropertyToID("_BlurTexture");

    class DepthOfFieldPassDate
    {
        public TextureHandle sourceTex;
        public TextureHandle depthTex;
        public TextureHandle blurTex;
        public TextureHandle destination;
        public Material material;
    }

    private void DepthOfFieldBlit(RenderGraph renderGraph, TextureHandle cameraTex, TextureHandle destinationTex, TextureHandle depthTex, TextureHandle blurTex)
    {
        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass("DepthOfFieldBlit", out DepthOfFieldPassDate passData))
        {
            //必要なデータを集める
            passData.sourceTex = cameraTex;
            passData.depthTex = depthTex;
            passData.blurTex = blurTex;
            passData.destination = destinationTex;
            passData.material = dofMat_;

            //Blit用に使用するテクスチャを割り当て
            builder.UseTexture(passData.sourceTex);
            builder.UseTexture(passData.depthTex);
            builder.UseTexture(passData.blurTex);
            //出力先テクスチャを割り当て
            builder.SetRenderAttachment(passData.destination, 0);

            //描画関数の登録
            builder.SetRenderFunc((DepthOfFieldPassDate data, RasterGraphContext ctx) =>
            {
                //合成用のテクスチャを_DepthTexに渡す
                data.material.SetTexture(depthTexID, data.depthTex);
                //合成用のテクスチャを_BlurTexに渡す
                data.material.SetTexture(blurTexID, data.blurTex);
                //Blitコマンドを積む
                Blitter.BlitTexture(ctx.cmd, data.sourceTex, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }
    } 
    public DepthOfFieldRenderPass(Material depthMat, Material dofMat, Material blurMat)
    {
        depthMat_ = depthMat;
        blurMat_ = blurMat;
        dofMat_ = dofMat;
    }
    public override void RecordRenderGraph(
          RenderGraph renderGraph,
          ContextContainer frameData
      )
    {
        if (depthMat_ == null|| blurMat_ == null|| dofMat_ == null)
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
        TextureDesc depthTexDesc=renderGraph.GetTextureDesc(cameraTex);
        depthTexDesc.name = "_DepthTex";
        //深度は使わない
        depthTexDesc.depthBufferBits = 0;
        depthTexDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
        //テクスチャの作成
        TextureHandle depthTex=renderGraph.CreateTexture(depthTexDesc);

        //ブラーテクスチャ
        TextureDesc blurTexDesc = renderGraph.GetTextureDesc(cameraTex);
        blurTexDesc.name = "_BlurTex";
        //縮小バッファ
        int div = 2;
        blurTexDesc.width /= div;
        blurTexDesc.height /= div;
        blurTexDesc.depthBufferBits = 0;
        TextureHandle blurTex=renderGraph.CreateTexture(blurTexDesc);
        //出力先テクスチャ
        TextureDesc destinationTexDesc = renderGraph.GetTextureDesc(cameraTex);
        destinationTexDesc.name = "_DestinationTex";
        destinationTexDesc.depthBufferBits= 0;
        TextureHandle destinationTex=renderGraph.CreateTexture(destinationTexDesc);

        //深度値を抽出する
        RenderGraphUtils.BlitMaterialParameters depthTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex, depthTex, depthMat_, 0);

        //URPに適用
        renderGraph.AddBlitPass(depthTexBlitDesc, "DrawDepthBlit");
        //ブラーシェーダーをBlitする
        RenderGraphUtils.BlitMaterialParameters blurTexBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTex, blurTex, blurMat_, 0);
        //その設定をURPに適用
        renderGraph.AddBlitPass(blurTexBlitDesc, "DrawBlurBlit");
        //被写界深度の適用
        DepthOfFieldBlit(renderGraph,cameraTex,destinationTex,depthTex,blurTex);
        //被写界深度を適用したテクスチャをcameraTexに戻す
        renderGraph.AddCopyPass(destinationTex, cameraTex, "CopyDof");
    }

    }

