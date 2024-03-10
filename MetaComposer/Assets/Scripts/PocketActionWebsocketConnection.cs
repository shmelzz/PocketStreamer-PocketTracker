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


public class PocketActionWebSocketConnection : MonoBehaviour
{
    WebSocket websocket;
    public CameraSwitcher cameraSwitcher;

    private ConcurrentQueue<Action> actions = new ConcurrentQueue<Action>();  // Create a thread-safe queue for actions

    public TMP_InputField JWTInputField;

    public TMP_InputField sessionInputField;

    public TMP_InputField ipInputField;

    public Button connectButton;


    // Debug use
    public GameObject Rain;

    // Start is called before the first frame update
    async void Start()
    {
        connectButton.onClick.AddListener(StartWebSocket);
    }

    async void StartWebSocket()
    {
        Debug.Log("Start PocketActionManger");

        Dictionary<string, string> headers = new Dictionary<string, string>
        {
            // Add the Authentication header
            { "Authentication", JWTInputField.text },

            // Add the SessionId header
            { "SessionId", sessionInputField.text }
        };
        string path = (ipInputField.text + ":9091/action/action-composed​").Replace("\u200B", ""); ;
        Debug.Log(path);
        websocket = new WebSocket(path, headers);
        TextMeshProUGUI textMeshPro = connectButton.GetComponentInChildren<TextMeshProUGUI>();

        websocket.OnOpen += () =>
        {
            Debug.Log("PocketAction Connection open!");
            textMeshPro.color = UnityEngine.Color.green;
        };

        websocket.OnError += (e) =>
        {
            Debug.Log("Face/Body Error! " + e);
            textMeshPro.color = UnityEngine.Color.red;
        };

        websocket.OnClose += (e) =>
        {
            Debug.Log("PocketAction Connection closed!");
            textMeshPro.color = UnityEngine.Color.red;
        };


        websocket.OnMessage += (bytes) =>
        {
            // getting the message as a string
            var message = System.Text.Encoding.UTF8.GetString(bytes);
            PocketAction pocketAction = JsonConvert.DeserializeObject<PocketAction>(message);
            // Enqueue the action you want to perform on the main thread
            actions.Enqueue(() =>
            {
                switch (pocketAction.Type)
                {
                    case "startrain":
                        Rain.GetComponent<ParticleSystem>().Play();
                        break;
                    case "stoprain":
                        Rain.GetComponent<ParticleSystem>().Stop();
                        break;
                    case "camera":
                        if (int.TryParse(pocketAction.Payload, out int num))
                        {
                            // Conversion successful, do something with num.
                            Console.WriteLine("Successful");
                            cameraSwitcher.action += (() =>
                                {
                                    cameraSwitcher.ActivateCamera(num);
                                }
                            );

                        }
                        else
                        {
                            // Conversion failed, handle the error.
                            Console.WriteLine("Unsuccessful..");
                        }
                        break;
                    default:
                        break;
                }
            });
        };

        // waiting for messages
        await websocket.Connect();
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