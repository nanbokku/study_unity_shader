using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WipeEffect : MonoBehaviour
{
    [SerializeField]
    private Material wipeEffect = null;
    [SerializeField]
    private Vector2 centerPosition = Vector2.zero;  // 円の中心位置
    [SerializeField]
    private float wipeSpeed = 1;                    // 円が小さくなる速度
    [SerializeField]
    private float minRadiusBeforeStopping = 1;      // 円が一旦停止する前の円の半径
    [SerializeField]
    private float stopTime = 0;                     // 円が一旦停止する時間
    private Vector2 center = Vector2.zero;
    private float radius = 1;
    private int centerPropertyId = 0;
    private int radiusPropertyId = 0;
    private float startStoppingTime = -1;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        UpdateMaterial();

        Graphics.Blit(src, dest, wipeEffect);
    }

    void Awake()
    {
        centerPropertyId = Shader.PropertyToID("_Center");
        radiusPropertyId = Shader.PropertyToID("_Radius");

        center = centerPosition;
        radius = 600;
        startStoppingTime = -1;
    }

    void UpdateMaterial()
    {
        var r = radius - wipeSpeed * Time.deltaTime;
        if (r < minRadiusBeforeStopping && startStoppingTime < 0)
        {
            startStoppingTime = Time.time;
            return;
        }

        if (startStoppingTime >= 0 && Time.time - startStoppingTime <= stopTime)
        {
            return;
        }

        radius = r;

        wipeEffect.SetVector(centerPropertyId, center);
        wipeEffect.SetFloat(radiusPropertyId, radius);
    }
}
