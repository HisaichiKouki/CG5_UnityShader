using UnityEngine;

public class IntersectionHighlightSphere : MonoBehaviour
{
    [SerializeField] float scaleUpTime = 1;
    float curScaleUpTime;
    [SerializeField] float maxSize = 10;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        curScaleUpTime += Time.deltaTime;

        float newScale=Mathf.Lerp(0,maxSize, curScaleUpTime/ scaleUpTime);
        transform.localScale=new Vector3 (newScale, newScale, newScale);

        if(curScaleUpTime>scaleUpTime)
        {
            Destroy(gameObject);
        }

    }
}
