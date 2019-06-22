using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamPost : MonoBehaviour
{
    [SerializeField]
    Shader shader;
    [SerializeField]
    float amplitude = 0.025f;

    private Material mat;
    void Start()
    {
        mat = new Material(shader);
    }
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_Amp", amplitude);
        if (mat)
        {
            Graphics.Blit(source, destination, mat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
