using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DepthOfFieldRenderFeature : ScriptableRendererFeature
{
    //深度描画用マテリアル
    [SerializeField] private Material depthMat_;
    [SerializeField] private Material dofhMat_;
    [SerializeField] private Material blurMat_;
    private DepthOfFieldRenderPass renderPass_;
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
        renderPass_ = new DepthOfFieldRenderPass(depthMat_, dofhMat_, blurMat_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
}
