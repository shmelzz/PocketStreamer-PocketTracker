using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement; 

public class DebugMenu : MonoBehaviour
{
    //public GameObject settingsScene;

    public void SceneSwitch (int scene_num) 
    {
        SceneManager.LoadScene(scene_num);
    }

    public void ExitButton()
    {
        Application.Quit();
    }

    void Update()
   {
      if (Input.GetKey("escape"))  // если нажата клавиша Esc (Escape)
      {
         Application.Quit();    // закрыть приложение
      }
   }

    //public void SettingsButton() {}
 
}
