using System;
using System.Collections.Concurrent;  // Required for ConcurrentQueue
using UnityEngine;
using UnityEngine.Events; // Import this for UnityAction

public class CameraSwitcher : MonoBehaviour
{
    private GameObject[] cameras;
    private int currentCameraIndex = 0;
    public UnityAction action;  // Create a thread-safe queue for actions

    void Start()
    {
        cameras = FindObjectsOfType<GameObject>();

        // Optionally, you can filter cameras by layer and tag here if needed
        // For demonstration, let's assume you want to find cameras on layer 8 and with tag "MainCamera"
        int targetLayer = 6; // Replace with your target layer
        string targetTag = "Camera"; // Replace with your target tag

        // Filter cameras based on layer and tag
        System.Collections.Generic.List<GameObject> filteredCameras = new System.Collections.Generic.List<GameObject>();
        foreach (GameObject cam in cameras)
        {
            if (cam.gameObject.layer == targetLayer && cam.gameObject.CompareTag(targetTag))
            {
                filteredCameras.Add(cam);
            }
        }

        // Convert the filtered list back to an array
        cameras = filteredCameras.ToArray();

        if (cameras.Length > 0)
        {
            cameras[0].SetActive(true);
            for (int i = 1; i < cameras.Length; i++)
            {
                cameras[i].SetActive(false);
            }
        }
    }

    public void ActivateCamera(int index)
    {
        if (index >= cameras.Length || index < 0)
        {
            return;
        }
        cameras[currentCameraIndex].SetActive(false);

        // Move to the next camera, or loop back to the first if at the end

        // Activate the next camera
        cameras[index].SetActive(true);

        currentCameraIndex = index;

    }

    void Update()
    {
        action?.Invoke();
    }

}