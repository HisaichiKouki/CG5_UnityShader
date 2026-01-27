using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DepthOfFieldRenderFeature_CoC : ScriptableRendererFeature
{
    //深度描画用マテリアル

    [SerializeField] private Material depthMat_;
    [SerializeField] private Material lowBlurMat_;
    [SerializeField] private Material middleBlurMat_;
    [SerializeField] private Material highBlurMat_;
    [SerializeField] private Material dofMat_;
    private DepthOfFieldRenderPass_CoC renderPass_;
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
        renderPass_ = new DepthOfFieldRenderPass_CoC(depthMat_, dofMat_, lowBlurMat_,middleBlurMat_,highBlurMat_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
}
