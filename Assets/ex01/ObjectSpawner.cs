using UnityEngine;

public partial class ObjectSpawner : MonoBehaviour
{
    [Header("生成するプレハブ")]
    public GameObject prefabToSpawn;

    [Header("生成する場所のレイヤー（地面など）")]
    public LayerMask groundLayer;

    void Update()
    {
        // マウス左クリック（0）が押された瞬間
        if (Input.GetMouseButtonDown(0))
        {
            SpawnObjectAtMousePosition();
        }
    }

    void SpawnObjectAtMousePosition()
    {
        // 1. カメラからマウスの位置に向かう「レイ（光線）」を作成
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;

        // 2. レイを飛ばして何かに当たったか判定
        // 引数: (レイ, ヒット情報, 距離, 対象レイヤー)
        if (Physics.Raycast(ray, out hit, Mathf.Infinity, groundLayer))
        {
            // 3. 当たった位置（hit.point）にオブジェクトを生成
            // 第2引数は当たった位置、第3引数は回転（無回転）
            Instantiate(prefabToSpawn, hit.point, prefabToSpawn.transform.rotation);

            Debug.Log("生成した場所: " + hit.point);
        }
    }
}