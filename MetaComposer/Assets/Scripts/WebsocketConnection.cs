#pragma warning disable 0414, 0649
using System;
using System.Collections;
using System.Collections.Concurrent;  // Required for ConcurrentQueue
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using MetaComposer.Assets;
using NativeWebSocket;
using Newtonsoft.Json;
using TMPro;
using UniGLTF;
using UnityEngine;
using UnityEngine.Assertions.Comparers;
using UnityEngine.UI;
using VRM;


public class WebSocketConnection : MonoBehaviour
{
    WebSocket websocket;
    private ConcurrentQueue<Action> actions = new ConcurrentQueue<Action>();  // Create a thread-safe queue for actions

    public TMP_InputField ipInputField;

    public TMP_InputField JWTInputField;

    public TMP_InputField sessionInputField;

    public Button connectButton;
    private VRMBlendShapeProxy Proxy = null;

    [Range(0.0f, 1.0f)]
    public OffsetOnTransform LeftEye;

    [Range(0.0f, 1.0f)]
    public OffsetOnTransform RightEye;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookDownLeft;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookDownRight;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookInLeft;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookInRight;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookOutLeft;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookOutRight;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookUpLeft;

    // [Range(0.0f, 1.0f)]
    // public double EyeLookUpRight;


    [Range(0.0f, 90.0f)]
    public float HorizontalOuter = 45.0f;

    [Range(0.0f, 90.0f)]
    public float HorizontalInner = 45.0f;

    [Range(0.0f, 90.0f)]
    public float VerticalDown = 45.0f;

    [Range(0.0f, 90.0f)]
    public float VerticalUp = 45.0f;

    // Start is called before the first frame update
    async void Start()
    {
        connectButton.onClick.AddListener(StartWebSocket);
        VerticalUp = 20f;
        VerticalDown = 20f;
        HorizontalInner = 18f;
        HorizontalOuter = 18f;
    }

    async void StartWebSocket()
    {
        Debug.Log("Start");
        Dictionary<string, string> headers = new Dictionary<string, string>
        {
            // Add the Authentication header
            { "Authentication", JWTInputField.text },

            // Add the SessionId header
            { "SessionId", sessionInputField.text }
        };
        websocket = new WebSocket(ipInputField.text, headers);
        TextMeshProUGUI textMeshPro = connectButton.GetComponentInChildren<TextMeshProUGUI>();

        websocket.OnOpen += () =>
        {
            Debug.Log("Connection open!");
            textMeshPro.color = UnityEngine.Color.green;
        };

        websocket.OnError += (e) =>
        {
            Debug.Log("Error! " + e);
            textMeshPro.color = UnityEngine.Color.red;
        };

        websocket.OnClose += (e) =>
        {
            Debug.Log("Connection closed!");
            textMeshPro.color = UnityEngine.Color.red;
        };

        Proxy = GetComponent<VRMBlendShapeProxy>();

        websocket.OnMessage += (bytes) =>
        {
            // getting the message as a string
            var message = System.Text.Encoding.UTF8.GetString(bytes);
            // Enqueue the action you want to perform on the main thread
            actions.Enqueue(() =>
            {
                // Parse the JSON message and use it to change your game object
                // This is just a placeholder, replace with your own logic
                FaceTrackingData faceData = JsonConvert.DeserializeObject<FaceTrackingData>(message);
                if (faceData == null)
                {
                    return;
                }
                // Extract the names of the properties and store them in a string array
                Proxy.SetValues(FaceBlendShapeValueSetter.ToBlendShapeDictionary(faceData));
                ApplyEyeRotations(faceData);
            });
        };

        // waiting for messages
        await websocket.Connect();
    }

    void ApplyEyeRotations(FaceTrackingData data = null)
    {
        // Apply
        if (LeftEye.Transform != null && RightEye.Transform != null)
        {
            float leftPitch = data.ToEyePitchDegree(VerticalDown, VerticalUp).Item1;
            float leftYaw = data.ToEyeYawDegree(HorizontalInner, HorizontalOuter).Item1;

            float rightPitch = data.ToEyePitchDegree(VerticalDown, VerticalUp).Item2;
            float rightYaw = data.ToEyeYawDegree(HorizontalInner, HorizontalOuter).Item2;

            // Create a Quaternion from the pitch and yaw values
            Quaternion leftRotation = Quaternion.Euler(leftPitch, leftYaw, 0);

            Quaternion rightRotation = Quaternion.Euler(rightPitch, rightYaw, 0);

            // Apply the rotation to the eye's transform
            LeftEye.Transform.localRotation = leftRotation;
            RightEye.Transform.localRotation = rightRotation;

        }
    }




    void Update()
    {
#if !UNITY_WEBGL || UNITY_EDITOR
        if (websocket == null)
        {
            return;
        }
        websocket.DispatchMessageQueue();
        // Dequeue and perform the actions on the main thread
        while (actions.Count > 0)
        {
            if (actions.TryDequeue(out var action))
            {
                action?.Invoke();
            }
        }
#endif
    }

    async void SendWebSocketMessage()
    {
        if (websocket.State == WebSocketState.Open)
        {
            // Sending bytes
            await websocket.Send(new byte[] { 10, 20, 30 });

            // Sending plain text
            await websocket.SendText("plain text message");
        }
    }

    private async void OnApplicationQuit()
    {
        await websocket.Close();
    }
}