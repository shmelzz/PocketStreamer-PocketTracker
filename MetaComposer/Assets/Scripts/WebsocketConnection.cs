#pragma warning disable 0414, 0649
using System;
using System.Collections;
using System.Collections.Concurrent;  // Required for ConcurrentQueue
using System.Collections.Generic;
using MetaComposer.Assets;
using NativeWebSocket;
using Newtonsoft.Json;
using UniGLTF;
using UnityEngine;
using VRM;


public class WebSocketConnection : MonoBehaviour
{
    WebSocket websocket;
    private ConcurrentQueue<Action> actions = new ConcurrentQueue<Action>();  // Create a thread-safe queue for actions

    private VRMBlendShapeProxy Proxy = null;

    [SerializeField]
    public OffsetOnTransform LeftEye;

    [SerializeField]
    public OffsetOnTransform RightEye;

    [SerializeField]
    public double EyeLookDownLeft { get; set; }

    [SerializeField]
    public double EyeLookDownRight { get; set; }

    [SerializeField]
    public double EyeLookInLeft { get; set; }

    [SerializeField]
    public double EyeLookInRight { get; set; }

    [SerializeField]
    public double EyeLookOutLeft { get; set; }

    [SerializeField]
    public double EyeLookOutRight { get; set; }

    [SerializeField]
    public double EyeLookUpLeft { get; set; }

    [SerializeField]
    public double EyeLookUpRight { get; set; }


    [SerializeField, Header("Degree Mapping")]
    public CurveMapper HorizontalOuter = new CurveMapper(90.0f, 10.0f);

    [SerializeField]
    public CurveMapper HorizontalInner = new CurveMapper(90.0f, 10.0f);

    [SerializeField]
    public CurveMapper VerticalDown = new CurveMapper(90.0f, 10.0f);

    [SerializeField]
    public CurveMapper VerticalUp = new CurveMapper(90.0f, 10.0f);

    // Start is called before the first frame update
    async void Start()
    {
        Debug.Log("Start");
        Dictionary<string, string> headers = new Dictionary<string, string>();

        // Add the Authentication header
        headers.Add("Authentication", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlZGR5enhjdiIsImV4cCI6MTcwOTQyNTU2Nn0.OFoxKg6LvMtp7TwRGs4QgLyyB_wVDsMfqPfdfBiP7Fc");

        // Add the SessionId header
        headers.Add("SessionId", "6dcca1cb-6bb7-44f5-a5c2-ff5c6680782e");
        websocket = new WebSocket("ws://84.201.133.103:4545/composed", headers);

        websocket.OnOpen += () =>
        {
            Debug.Log("Connection open!");
        };

        websocket.OnError += (e) =>
        {
            Debug.Log("Error! " + e);
        };

        websocket.OnClose += (e) =>
        {
            Debug.Log("Connection closed!");
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
            });
        };

        // waiting for messages
        await websocket.Connect();
    }

    void ApplyRotations(float yaw, float pitch)
    {
        // TODO: Need add up down inner outer parser. 
        // horizontal
        float leftYaw, rightYaw;
        if (yaw < 0)
        {
            leftYaw = -HorizontalOuter.Map(-yaw);
            rightYaw = -HorizontalInner.Map(-yaw);
        }
        else
        {
            rightYaw = HorizontalOuter.Map(yaw);
            leftYaw = HorizontalInner.Map(yaw);
        }

        // vertical
        if (pitch < 0)
        {
            pitch = -VerticalDown.Map(-pitch);
        }
        else
        {
            pitch = VerticalUp.Map(pitch);
        }


        // Apply
        if (LeftEye.Transform != null && RightEye.Transform != null)
        {
            LeftEye.Transform.rotation = LeftEye.InitialWorldMatrix.ExtractRotation() * Matrix4x4.identity.YawPitchRotation(leftYaw, pitch);
            RightEye.Transform.rotation = RightEye.InitialWorldMatrix.ExtractRotation() * Matrix4x4.identity.YawPitchRotation(rightYaw, pitch);
        }
    }

    void Update()
    {
#if !UNITY_WEBGL || UNITY_EDITOR
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
        ApplyRotations(0, 0);
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