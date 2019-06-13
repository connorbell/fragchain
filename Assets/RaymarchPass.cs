using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MidiJack;

public class RaymarchPass : ShaderPass
{
    [SerializeField]
    float midi1Strength = 1.0f;

    [SerializeField]
    float midi2Strength = 1.0f;

    [SerializeField]
    float midi3Strength = 1.0f;

    [SerializeField]
    float midi4Strength = 1.0f;

    [SerializeField]
    float maxDepth = 10f;

    protected override void UpdateUniforms()
    {
        float v1 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 1) * midi1Strength;
        float v2 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 2) * midi2Strength;
        float v3 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 3) * midi3Strength;
        float v4 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 4) * midi4Strength;
        float v5 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 5);
        float v6 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 6);
        float v7 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 7);
        float v8 = MidiMaster.GetKnob(MidiJack.MidiChannel.All, 8);
        
        Mat.SetFloat("_Midi1", v1);
        Mat.SetFloat("_Midi2", v2);
        Mat.SetFloat("_Midi3", v3);
        Mat.SetFloat("_Midi4", v4);
        Mat.SetFloat("_Midi5", v5);
        Mat.SetFloat("_Midi6", v6);
        Mat.SetFloat("_Midi7", v7);
        Mat.SetFloat("_Midi8", v8);
        Mat.SetVector("_CamPos", Camera.main.transform.position);
        Mat.SetVector("_CamForward", Camera.main.transform.forward);
        Mat.SetVector("_CamRight", Camera.main.transform.right);
        Mat.SetVector("_CamUp", Camera.main.transform.up);
        Mat.SetFloat("_FocalLength", 1f);
        Mat.SetFloat("_MaxDist", maxDepth);
    }
}
