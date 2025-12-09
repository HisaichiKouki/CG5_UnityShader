using UnityEngine;
using UnityEngine.Rendering.Universal;

public class ToneMappingRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material postEffectMaterial_;
    private ToonMappingRenderPass renderPass_;

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
        renderPass_ = new ToonMappingRenderPass(postEffectMaterial_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
}
