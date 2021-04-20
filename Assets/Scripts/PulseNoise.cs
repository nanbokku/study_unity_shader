using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PulseNoise : MonoBehaviour
{
    [SerializeField]
    private Image myImage = null;
    [SerializeField]
    private AnimationCurve curve = null;
    [SerializeField]
    private float pulsePower = 1;
    [SerializeField]
    private float pulseSpeed = 0.1f;
    private int maxPulseId = 0;

    void Awake()
    {
        maxPulseId = Shader.PropertyToID("_MaxPulse");
    }

    void Start()
    {
        Pulse();
    }

    [ContextMenu("Pulse")]
    public void Pulse()
    {
        StartCoroutine(PulseAction());
    }

    IEnumerator PulseAction()
    {
        const float pulseTime = 1;

        for (var currentTime = 0f; currentTime < pulseTime; currentTime += pulseSpeed)
        {
            float pulse = pulsePower * curve.Evaluate(currentTime);
            myImage.material.SetFloat(maxPulseId, pulse);
            yield return null;
        }

        myImage.material.SetFloat(maxPulseId, 0);   // 0に戻す
    }
}
