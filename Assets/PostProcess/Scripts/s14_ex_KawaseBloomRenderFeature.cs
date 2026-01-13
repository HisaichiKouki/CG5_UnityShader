using UnityEngine;
using UnityEngine.Rendering.Universal;

public class s14_ex_KawaseBloomRenderFeature : ScriptableRendererFeature
{
    //ブラー用マテリアル
    [SerializeField] private Material blurMaterial_;
    //輝度抽出用マテリアル
    [SerializeField] private Material luminanceExtractMaterial_;
    //テクスチャ合成用マテリアル
    [SerializeField] private Material compositeTextureMaterial_;
    private s14_ex_KawaseBloomRenderPass renderPass_;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (renderer != null)
        {
            renderer.EnqueuePass(renderPass_);
        }
        //  throw new System.NotImplementedException();
    }

    public override void Create()
    {
        renderPass_ = new s14_ex_KawaseBloomRenderPass(luminanceExtractMaterial_, blurMaterial_, compositeTextureMaterial_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
}
