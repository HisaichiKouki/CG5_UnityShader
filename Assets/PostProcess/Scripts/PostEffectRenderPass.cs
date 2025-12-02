using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    private Material material_;

    public PostEffectRenderPass(Material material)
    {
        //shaderからmaterialを生成する
        material_ = material;
    }

    //RenderGraphへの描画設定や描画実行など一連の操作
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (material_ != null)
        {
            //material_がnullなら従来通りの描画をおこなう
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }
        //このフレームの描画リソースを取得する
        UniversalResourceData resourceData=
            frameData.Get<UniversalResourceData>();
        //取得したResourceDataがBackBufferであれば仕様上読み込み不可なので早期リターン
        if (resourceData.isActiveTargetBackBuffer)
        {
            return;
        }
        //カメラ(描画予定)のテクスチャを取得
        TextureHandle cameraTexture = resourceData.activeColorTexture;

        //ポストエフェクトを適用したテクスチャを作るためにカメラの情報を取得する
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
        //名前などの一部設定は書き換える
        tempDesc.name = "_GreenTex";
        //深度値は使わない
        tempDesc.depthBufferBits = 0;

        //仮テクスチャを作成
        TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);
        //カメラテクスチャにmaterial_を適用し仮テクスチャに出力する設定を作成
        RenderGraphUtils.BlitMaterialParameters blitMaterialParameters=
            new RenderGraphUtils.BlitMaterialParameters(
                cameraTexture,tempTexture,material_,0);

        renderGraph.AddBlitPass( blitMaterialParameters ,"BlitGreenPostEffect");
        renderGraph.AddCopyPass(tempTexture, cameraTexture, 0,0,0,0,"CopyGreenPostEffect");
    }


}
