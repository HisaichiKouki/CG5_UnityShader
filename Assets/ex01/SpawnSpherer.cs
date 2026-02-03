using UnityEngine;
using static UnityEngine.ParticleSystem;

public class SpawnSpherer : MonoBehaviour
{
    [SerializeField] GameObject intersectionHighlightSpherePrefab;
    [SerializeField] float ct = 1;
    float curCT;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

        if (curCT > 0)
        {
            curCT -= Time.deltaTime;
            return;
        }
        curCT = ct;
        Instantiate(intersectionHighlightSpherePrefab, transform);

    }
}
