using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRM;

public class Movement : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame

    void Update()
    {
        var proxy = GetComponent<VRMBlendShapeProxy>();
        if (Input.GetKeyDown("space"))
        {
            proxy.SetValues(new Dictionary<BlendShapeKey, float>
            {
                {BlendShapeKey.CreateUnknown("JawOpen"), 1f},
                {BlendShapeKey.CreateUnknown("TongueOut"), 1f},
            });
            Debug.Log("Space pressed");
        }
        else if (Input.GetKeyDown(KeyCode.C))
        {
            proxy.SetValues(new Dictionary<BlendShapeKey, float>
            {
                {BlendShapeKey.CreateUnknown("JawOpen"), 0f},
                {BlendShapeKey.CreateUnknown("TongueOut"), 0f},
            });
            Debug.Log("C pressed");
        }
    }
}
