using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Concurrent;  // Required for ConcurrentQueue
using UnityEngine;
using NativeWebSocket;
using Newtonsoft.Json;
using MetaComposer.Assets;

public class WebSocketConnection : MonoBehaviour
{
    WebSocket websocket;
    private ConcurrentQueue<Action> actions = new ConcurrentQueue<Action>();  // Create a thread-safe queue for actions

    // Start is called before the first frame update
    async void Start()
    {
        websocket = new WebSocket("ws://localhost:3000/composed");

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
                Debug.Log("Changing game object based on message: " + faceData.mouthStretch_R);
                GetComponent<Rigidbody>().velocity = new Vector3(0, (float)faceData.mouthStretch_R, 0);
            });
        };

        // waiting for messages
        await websocket.Connect();
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