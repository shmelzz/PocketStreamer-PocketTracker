using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class OnIPFieldChangedScript : MonoBehaviour
{
    // Start is called before the first frame update

    public TMP_InputField inputField;
    void Start()
    {
        inputField.onValueChanged.AddListener(SaveInputFieldText);
    }

    // Update is called once per frame
    void Update()
    {

    }

    void SaveInputFieldText(string newText)
    {
        // Assuming the text represents an integer
        int value;
        if (int.TryParse(newText, out value))
        {
            PlayerPrefs.SetInt("SavedValue", value);
            PlayerPrefs.Save();
        }
        else
        {
            Debug.LogError("The input text is not a valid integer.");
        }
    }
}
