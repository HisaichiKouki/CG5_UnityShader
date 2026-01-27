using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DrawDepthRenderFeature : ScriptableRendererFeature
{
    //深度描画用マテリアル
    [SerializeField] private Material depthTextureMaterial_;
    private DrawDepthRenderPass renderPass_;
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
        renderPass_ = new DrawDepthRenderPass(depthTextureMaterial_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
}
