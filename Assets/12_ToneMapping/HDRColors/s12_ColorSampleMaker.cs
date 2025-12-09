using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[ExecuteInEditMode]
public class s12_ColorSampleMaker : MonoBehaviour
{
  [SerializeField]
  private GameObject cubePrefab_;
  [SerializeField]
  private Texture texture_;
  private float[] intensitys_;
  private Color[] colors_;


  /// <summary>
  /// 起動時・シーン読み込み時・コンポーネント有効化時
  /// </summary>
  void OnEnable()
  {
    // まず子供を全員消す
    AllDestroyChildren();

    // 明るさテーブル
    intensitys_ = new float[] {
      0.01f, 0.02f, 0.04f, 0.08f,
      0.1f, 0.2f, 0.4f,0.8f,
      1, 2, 4, 8,
      10
    };
    // 色テーブル
    colors_ = new Color[] {
      new Color(1f,1f,1f),
      new Color(1f,0.1f,0.1f),
      new Color(0.1f,1f,0.1f),
      new Color(0.1f,0.1f,1f),
    };

    int iNum = 0;
    // キューブの間隔
    float spacing = 1.2f;
    // 初期位置
    Vector3 offset = new Vector3(
        (intensitys_.Length - 1) * spacing / 2,
        (colors_.Length) * spacing / 2
      );
    // コピー元マテリアル
    Material origMaterial = cubePrefab_.GetComponent<Renderer>().sharedMaterial;

    foreach (var intensity in intensitys_)
    {
      for (int c = 0; c <= colors_.Length; c++)
      {
        // 位置調整
        Vector3 position = new Vector3(
            spacing * iNum,
            spacing * c
          ) - offset + transform.position;
        // 調整した位置にCube生成
        GameObject cubeObject = Instantiate(cubePrefab_, position, Quaternion.identity);

        // 自身の子にする
        cubeObject.transform.parent = transform;
        // 専用マテリアル生成
        Material material = new Material(origMaterial);
        // 線用マテリアル割り当て
        cubeObject.GetComponent<Renderer>().sharedMaterial = material;
        // 明るさを設定
        material.SetFloat("_Intensity", intensity);
        // 色テーブル内ならその色を、はみ出たらテクスチャを割り当て
        if (c < colors_.Length)
        {
          // 色を設定
          material.SetColor("_Color", colors_[c]);
        }
        else
        {
          // シェーダ内でテクスチャ+色としてるので、色は0に
          material.SetColor("_Color", new Color(0, 0, 0));
          // テクスチャ設定
          material.SetTexture("_Texture", texture_);
        }
      }
      iNum++;
    }
  }

  /// <summary>
  /// コンポーネント無効化地
  /// </summary>
  private void OnDisable()
  {
    // コンポーネント無効時に子供全消去
    AllDestroyChildren();
  }

  /// <summary>
  /// 子オブジェクト全削除
  /// </summary>
  private void AllDestroyChildren()
  {
    int childCount = transform.childCount;
    for (int i = 0; i < childCount; i++)
    {
      DestroyImmediate(transform.GetChild(0).gameObject);
    }

  }
}
