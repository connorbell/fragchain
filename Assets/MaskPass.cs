using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskPass : ShaderPass
{
    [SerializeField]
    RenderTexture mask;
    [SerializeField]
    Color maskColor;
    [SerializeField]
    float tolerance = 1f;
    
    protected override void UpdateUniforms()
    {
        Mat.SetTexture("_MaskTex", mask);
        Mat.SetColor("_MaskColor", maskColor);
        Mat.SetFloat("_MaskTolerance", tolerance);
    }
}
