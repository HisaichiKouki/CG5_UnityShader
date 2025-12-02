using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material postEffectMaterial_;
    private PostEffectRenderPass renderPass_;

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
        renderPass_ = new PostEffectRenderPass(postEffectMaterial_);
        renderPass_.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;

        //    throw new System.NotImplementedException();
    }
    //public override void Create()
    //{
    //}
    //public override void AddRenderPasses(ScriptableRenderer rendererPass, ref RenderingData renderingData)
    //{

    //}


}
