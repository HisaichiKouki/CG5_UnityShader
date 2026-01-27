using UnityEngine;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DrawDepthRenderPass : ScriptableRenderPass
{

    public Material depthTextureMaterial_;
    // 略。フィールド変数やコンストラクタ

    public DrawDepthRenderPass(Material depthTextureMaterial)
    {
        depthTextureMaterial_ = depthTextureMaterial;
    }
    public override void RecordRenderGraph(
        RenderGraph renderGraph,
        ContextContainer frameData
    )
    {
        if (depthTextureMaterial_ == null)
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

        //元サイズの一次テクスチャ
        TextureHandle origTempTexture = renderGraph.CreateTexture(originalTextureDesc);
        // 深度値用のテクスチャ。
        TextureDesc depthTextureDesc = originalTextureDesc;
        depthTextureDesc.name = "_DepthTexture";
        // 深度値は使わない
        depthTextureDesc.depthBufferBits = 0;
        // 赤しか使っていないので精度を最低限に
        depthTextureDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
        // 赤しか使っていないので精度を最低限に
        TextureHandle depthTexture = renderGraph.CreateTexture(depthTextureDesc);

        // 深度値を抽出する
        RenderGraphUtils.BlitMaterialParameters depthTextureBlitDesc = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, depthTexture, depthTextureMaterial_, 0);
        // この設定をURPに適用
        renderGraph.AddBlitPass(depthTextureBlitDesc, "DrawDepthBlit");

        // cameraTextureに戻す
        renderGraph.AddCopyPass(depthTexture, cameraTexture, "CopyBlur");
    }
}
