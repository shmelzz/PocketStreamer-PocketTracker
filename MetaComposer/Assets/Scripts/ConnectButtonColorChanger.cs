using System.Collections;
using System.Collections.Generic;
using TMPro; // Make sure to include this namespace
using UnityEngine;


public class ConnectButtonColorChanger : MonoBehaviour
{

    public void ChangeButtonTextColor()
    {
        // Find the TextMesh Pro component in the button's children
        TextMeshProUGUI textMeshPro = GetComponentInChildren<TextMeshProUGUI>();

        // Change the color to red
        textMeshPro.color = Color.red;
    }
}
