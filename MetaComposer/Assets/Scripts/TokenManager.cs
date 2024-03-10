using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;


public class TokenManager : MonoBehaviour
{

    public TMP_InputField JWTInputField;

    public TMP_InputField sessionInputField;
    // Start is called before the first frame update
    void Start()
    {
        string username = PlayerPrefs.GetString("username");
        string token = PlayerPrefs.GetString("token");
        string session = PlayerPrefs.GetString("session");
        Debug.Log(token);
        Debug.Log(session);
        JWTInputField.text = token;
        sessionInputField.text = session;
    }


    // Update is called once per frame
    void Update()
    {

    }
}
