using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    //ポストプロセス用マテリアル
    private Material blurMaterial_;
    //Blit用のパススルーマテリアル
    private Material passThroughMaterial_;

    //public PostEffectRenderPass(Material material)
    //{
    //    //shaderからmaterialを生成する
    //    material_ = material;
    //}
    public PostEffectRenderPass(Material material,Material passThroughMaterial)
    {
        //shaderからmaterialを生成する
        blurMaterial_ = material;
        passThroughMaterial_ = passThroughMaterial;
    }

    //RenderGraphへの描画設定や描画実行など一連の操作
    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (blurMaterial_ == null||passThroughMaterial_==null)
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
           // return;
        }
        //カメラ(描画予定)のテクスチャを取得
        TextureHandle cameraTexture = resourceData.activeColorTexture;

        //ポストエフェクトを適用したテクスチャを作るためにカメラの情報を取得する
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
        //名前などの一部設定は書き換える
        tempDesc.name = "_OrigTempTexture";
        //深度値は使わない
        tempDesc.depthBufferBits = 0;
        //元サイズの一次テクスチャ
        TextureHandle origTempTexture=renderGraph.CreateTexture(tempDesc);
        //縮小サイズの一次テクスチャ
        tempDesc.name = "_SmallTempTexture";
        int div = 2;
        tempDesc.width/=div;
        tempDesc.height/=div;
        TextureHandle smallTempTexture=renderGraph.CreateTexture(tempDesc);
        //カメラテクスチャにmaterial_を適用し仮テクスチャに出力する設定を作成。小さくする際にブラーを適用
        RenderGraphUtils.BlitMaterialParameters downSampleBlitMaterialParameters=
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture,smallTempTexture, blurMaterial_,0);

        //設定をURPに適用
        renderGraph.AddBlitPass(downSampleBlitMaterialParameters, "DownSamplingBlitBlur");

        //PassThroughをつかってサイズを戻す
         RenderGraphUtils.BlitMaterialParameters upSampleBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(smallTempTexture,origTempTexture, blurMaterial_,0);
        //設定をURPに適用
        renderGraph.AddBlitPass(upSampleBlitMaterialParameters, "UpSamplingBlitBlur");
        renderGraph.AddCopyPass(origTempTexture, cameraTexture, "CopyBlur");
    }


}
