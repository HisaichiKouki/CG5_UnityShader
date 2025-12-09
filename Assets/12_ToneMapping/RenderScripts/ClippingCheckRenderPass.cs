using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

// ScriptableRenderPassを継承
public class ClippingCheckRenderPass : ScriptableRenderPass
{
  private Material material_ = null;

  public ClippingCheckRenderPass(
    Material postEffectMaterial)
  {
    // ShaderからMaterialを生成する
    material_ = postEffectMaterial;
  }

  // RenderGraphへの描画設定や描画実行など一連の操作
  public override void RecordRenderGraph(
    RenderGraph renderGraph, ContextContainer frameData)
  {
    if (material_ == null)
    {
      // material_がnullならば従来通りの描画を行なう  
      base.RecordRenderGraph(renderGraph, frameData);
      return;
    }
    // このフレームの描画リソースを取得する。
    UniversalResourceData resourceData =
    frameData.Get<UniversalResourceData>();

    // 取得したResourceDataがBackBufferであれば仕様上読み込み
    // 不可なので早期リターン。
    if (resourceData.isActiveTargetBackBuffer)
    {
      base.RecordRenderGraph(renderGraph, frameData);
      return;
    }

    // カメラ（描画予定）のテクスチャを取得
    TextureHandle cameraTexture = resourceData.activeColorTexture;

    // ポストエフェクトを適用したテクスチャを作るために
    // カメラの情報を取得する
    TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
    // 名前などの一部設定は書き換える。
    tempDesc.name = "_GreenTexture";
    // 深度値は使わない
    tempDesc.depthBufferBits = 0;

    // 仮テクスチャを作成
    TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);

    // カメラテクスチャにmaterial_を適用し仮テクスチャに
    // 出力する設定を作成
    RenderGraphUtils.BlitMaterialParameters
      blitMaterialParameters =
      new RenderGraphUtils.BlitMaterialParameters(
        cameraTexture, tempTexture, material_, 0);
    // その設定をURPに適用
    renderGraph.AddBlitPass(blitMaterialParameters,"BlitGreenPostEffect");
    // URPがポストエフェクトを元のカメラテクスチャにコピーする
    renderGraph.AddCopyPass(tempTexture, cameraTexture,"CopyGreenPostEffect");
  }
}
