using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;

public class Chain : MonoBehaviour
{
    [SerializeField]
    List<ShaderPass> shaders = new List<ShaderPass>();

    [SerializeField]
    Vector2 baseResolution;

    [SerializeField]
    Material destMaterial;

    [SerializeField]
    bool capture = false;

    [SerializeField]
    float duration = 1.570795f;

    [SerializeField]
    int fps = 30;

    [SerializeField]
    string filename = "screen";

    private int frameNumber = 0;

    void Start()
    {
        if (capture)
        {
            Time.fixedDeltaTime = (1f / fps) * duration;
        }

        Debug.Log(Time.fixedDeltaTime);

        foreach (ShaderPass shaderPass in shaders)
        {
            shaderPass.InitWithResolution(baseResolution);
        }
    }

    void FixedUpdate()
    {
        for (int i = 1; i < shaders.Count; i++)
        {
            shaders[i].SetTexture("_MainTex", shaders[i-1].renderTexture);
            shaders[i].Blit(shaders[i-1].renderTexture);
        }

        if (destMaterial != null)
        {
            destMaterial.mainTexture = shaders[shaders.Count - 1].renderTexture;
        }

        if (capture)
        {
            RenderTexture.active = shaders[shaders.Count - 1].renderTexture;
            Texture2D tex = new Texture2D(shaders[shaders.Count - 1].renderTexture.width, shaders[shaders.Count - 1].renderTexture.height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
            RenderTexture.active = null;

            byte[] bytes;
            bytes = tex.EncodeToPNG();

            string path = Application.dataPath+Path.DirectorySeparatorChar+".."+Path.DirectorySeparatorChar+ filename+"_"+frameNumber.ToString().PadLeft(4, '0')+".png";
            File.WriteAllBytes(path, bytes);
            Debug.Log("ok" + path );
        }

        frameNumber++;
    }
}
