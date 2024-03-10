using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using ZXing;
using ZXing.QrCode;

public class QRCodeGeneration : MonoBehaviour
{
    [SerializeField]
    private RawImage _rawImageReceiver;

    private string sessionId;

    private string sessionIdRaw;

    private string url = "http://test-pocketcenter.tedv2023zxcv.top:8088";

    private Texture2D _storeEncodedTexture;


    // Start is called before the first frame update
    void Start()
    {
        _storeEncodedTexture = new Texture2D(256, 256);
        StartCoroutine(GetSession());
    }

    private Color32[] Encode(string textForEncoding, int width, int height)
    {
        BarcodeWriter writer = new BarcodeWriter
        {
            Format = BarcodeFormat.QR_CODE,
            Options = new QrCodeEncodingOptions
            {
                Height = height,
                Width = width
            }
        };
        return writer.Write(textForEncoding);
    }

    public void OnClickEncode()
    {
        EncodeTextToQRCode();
    }

    private void EncodeTextToQRCode()
    {
        string textWrite = string.IsNullOrEmpty(sessionId) ? "Write something" : sessionId;
        Debug.Log(textWrite);
        Color32[] _convertPixelTotexture = Encode(textWrite, _storeEncodedTexture.width, _storeEncodedTexture.height);
        _storeEncodedTexture.SetPixels32(_convertPixelTotexture);
        _storeEncodedTexture.Apply();

        _rawImageReceiver.texture = _storeEncodedTexture;
    }

    IEnumerator GetSession()
    {
        UnityWebRequest request = UnityWebRequest.Get(url + "/auth/session");
        yield return request.SendWebRequest();

        if (request.isNetworkError || request.isHttpError)
        {
            Debug.Log(request.error);
        }
        else
        {
            sessionIdRaw = request.downloadHandler.text;
            SessionResponse response = JsonConvert.DeserializeObject<SessionResponse>(sessionIdRaw);
            sessionId = response.SessionId;
            StartCoroutine(WaitForTracker());

            // Process the data received from the server
            EncodeTextToQRCode();
        }

    }

    IEnumerator WaitForTracker()
    {
        var uwr = new UnityWebRequest(url + "/auth/waitfortracker", "POST");
        byte[] jsonToSend = new System.Text.UTF8Encoding().GetBytes(sessionIdRaw);
        uwr.uploadHandler = (UploadHandler)new UploadHandlerRaw(jsonToSend);
        uwr.downloadHandler = (DownloadHandler)new DownloadHandlerBuffer();
        uwr.SetRequestHeader("Content-Type", "application/json");

        yield return uwr.SendWebRequest();

        if (uwr.isNetworkError)
        {
            Debug.Log("Error While Sending: " + uwr.error);
        }
        else
        {
            AuthResponse response = JsonConvert.DeserializeObject<AuthResponse>(uwr.downloadHandler.text);
            PlayerPrefs.SetString("username", response.Username);
            PlayerPrefs.SetString("token", response.Token);
            PlayerPrefs.SetString("session", sessionId);
            Debug.Log("Received: " + uwr.downloadHandler.text);
            SceneManager.LoadScene(3);
        }

    }


    public class SessionResponse
    {
        [JsonProperty("sessionid")]
        public string SessionId;
    }

    public class AuthResponse
    {
        [JsonProperty("username")]
        public string Username;
        [JsonProperty("token")]
        public string Token;
    }
}
