using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Chain : MonoBehaviour
{
    [SerializeField]
    List<ShaderPass> shaders = new List<ShaderPass>();

    [SerializeField]
    Vector2 baseResolution;

    [SerializeField]
    Material destMaterial;

    void Start()
    {
        foreach (ShaderPass shaderPass in shaders)
        {
            shaderPass.InitWithResolution(baseResolution);
        }
    }
    void FixedUpdate()
    {
        shaders[0].Blit(null);

        for (int i = 1; i < shaders.Count; i++)
        {
            shaders[i].SetTexture("_MainTex", shaders[i-1].renderTexture);
            shaders[i].Blit(shaders[i-1].renderTexture);
        }

        if (destMaterial != null)
        {
            destMaterial.mainTexture = shaders[shaders.Count - 1].renderTexture;
        }
    }
}
