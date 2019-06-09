using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderPass : MonoBehaviour
{
    [HideInInspector]
    public Material Mat;
    [SerializeField]
    public float Scale;

    [SerializeField]
    bool backBufferEnabled = false;

    public RenderTexture renderTexture;

    public void InitWithResolution(Vector2 resolution)
    {
        renderTexture = new RenderTexture((int)(resolution.x * Scale), (int)(resolution.y * Scale), 24);
    }

    public void Blit(Texture source)
    {
        Graphics.Blit(source, renderTexture, Mat);
    }
}
