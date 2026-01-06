using UnityEngine;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material postEffectMaterial_;//ポストプロセス用マテリアル
    [SerializeField] private Material passThroughMaterial_;//Blit用マテリアル
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
        renderPass_ = new PostEffectRenderPass(postEffectMaterial_, passThroughMaterial_);
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
