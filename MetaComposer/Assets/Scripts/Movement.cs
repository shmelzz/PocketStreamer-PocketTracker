using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using MetaComposer.Assets;
using UnityEditor;
using UnityEngine;
using VRM;
using UnityRandom = UnityEngine.Random;
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
        // Extract the names of the properties and store them in a string array

        if (Input.GetKeyDown("space"))
        {
            var data = FaceTrackingData.GenerateRandomFaceTrackingData();
            proxy.SetValues(FaceBlendShapeValueSetter.ToBlendShapeDictionary(data));
            Debug.Log("Space pressed");
        }
    }
}
