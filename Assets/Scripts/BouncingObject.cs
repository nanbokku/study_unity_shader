using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BouncingObject : MonoBehaviour
{
    [SerializeField]
    private Vector3 direction = Vector3.zero;
    [SerializeField]
    private float goPower = 5;
    [SerializeField]
    private float bouncePower = 10;
    [SerializeField]
    private SphereCollider myCollider = null;
    [SerializeField]
    private float gravity = -9.8f;
    private Vector3 currentPosition = Vector3.zero;
    private int maskLayer = 0;
    private float vy = 0;

    // Start is called before the first frame update
    void Start()
    {
        maskLayer = (1 << LayerMask.NameToLayer("Ground"));
    }

    // Update is called once per frame
    void Update()
    {
        currentPosition = this.transform.position;
        Fall();
        Go();
        this.transform.position = currentPosition;
    }

    void Fall()
    {
        var move = vy * Time.deltaTime + gravity * Time.deltaTime * Time.deltaTime;
        currentPosition.y += move;
        vy = vy + gravity * Time.deltaTime;

        Collider[] cols = Physics.OverlapSphere(currentPosition, myCollider.radius, maskLayer);
        if (cols.Length <= 0) return;

        currentPosition.y -= move;
        vy *= -0.5f;
    }

    void Go()
    {
        currentPosition += direction * goPower * Time.deltaTime;
    }
}
