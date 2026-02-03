using UnityEngine;
using UnityEngine.UIElements;

public class IntersectionHighlightSphere : MonoBehaviour
{
    [SerializeField] float scaleUpTime = 1;
    float curScaleUpTime;
    [SerializeField] float maxSize = 10;
    [SerializeField] Renderer myRenderer;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        curScaleUpTime += Time.deltaTime;

        float newScale=Mathf.Lerp(0,maxSize, curScaleUpTime/ scaleUpTime);
        myRenderer.material.SetFloat("_Softness", Mathf.Lerp(0.3f, 0, curScaleUpTime / scaleUpTime));
        transform.localScale=new Vector3 (newScale, newScale, newScale);

        if(curScaleUpTime>scaleUpTime)
        {
            Destroy(gameObject);
        }

    }
}
