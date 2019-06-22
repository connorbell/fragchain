using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MidiJack;

public class RaymarchPass : ShaderPass
{
    [SerializeField]
    float maxDepth = 10f;

    [SerializeField]
    float focalLength = 1f;

    protected override void UpdateUniforms()
    {
        Mat.SetVector("_CamPos", Camera.main.transform.position);
        Mat.SetVector("_CamForward", Camera.main.transform.forward);
        Mat.SetVector("_CamRight", Camera.main.transform.right);
        Mat.SetVector("_CamUp", Camera.main.transform.up);
        Mat.SetFloat("_FocalLength", focalLength);
        Mat.SetFloat("_MaxDist", maxDepth);
    }

}
