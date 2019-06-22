using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using MidiJack;

public class Chain : MonoBehaviour
{
    [SerializeField]
    List<ShaderPass> shaders = new List<ShaderPass>();

    [SerializeField]
    Vector2 baseResolution;

    [SerializeField]
    Material destMaterial;

    [SerializeField]
    float duration = 1.570795f;

    [SerializeField]
    int fps = 30;

    [SerializeField]
    string filename = "screen";

    [SerializeField]
    int currentMidiShaderIndex = 0;

    [SerializeField]
    Preset preset;

    private int frameNumber = 0;

    [SerializeField]
    KeyCode switchKey = KeyCode.Space;

    private int totalFrames;
    private bool isCapturing = false;
    
    void Start()
    {
        foreach (ShaderPass shaderPass in shaders)
        {
            shaderPass.InitWithResolution(baseResolution);
        }

        MidiMaster.knobDelegate += Knob;
        
        if (preset)
        {
            int index = 0;
            foreach (PassUniforms pass in preset.passUniforms)
            {
                if (index < shaders.Count)
                {
                    for (int i = 0; i < shaders[index].uniforms.Count; i++)
                    {
                        shaders[index].uniforms[i].Val = pass.uniforms[i].Val;
                    }
                }
                index++;
            }
        }
    }

    [ContextMenu("capture")]
    void Capture()
    {
        StartCoroutine(Render());
    }

    [ContextMenu("Save Preset")]
    void SavePreset()
    {
        List<PassUniforms> passes = new List<PassUniforms>();

        foreach(ShaderPass shaderPass in shaders)
        {
            PassUniforms info = new PassUniforms();
            info.shaderName = shaderPass.name;

            info.uniforms = shaderPass.uniforms;
            passes.Add(info);
        }
        
        Preset.CreatePreset(passes);
    }

    void UpdateUniformsWithMidi()
    {
        for (int i = 0; i < shaders[currentMidiShaderIndex].uniforms.Count; i++)
        {
            float v = MidiMaster.GetKnob(MidiJack.MidiChannel.All, i+1);
            shaders[currentMidiShaderIndex].uniforms[i].Val = v;
        }
    }

    IEnumerator Render()
    {
        isCapturing = true;
        totalFrames = (int)(duration * fps);
        float sTime = Time.time;

        while(frameNumber <= totalFrames)
        {
            float time = ((float)frameNumber / totalFrames) * duration;
            Shader.SetGlobalFloat("_T", sTime + time);

            RunChain();

            RenderTexture.active = shaders[shaders.Count - 1].renderTexture;
            Texture2D tex = new Texture2D(shaders[shaders.Count - 1].renderTexture.width, shaders[shaders.Count - 1].renderTexture.height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0, 0, tex.width, tex.height), 0, 0);
            RenderTexture.active = null;

            byte[] bytes;
            bytes = tex.EncodeToPNG();

            string path = Application.dataPath + Path.DirectorySeparatorChar + ".." + Path.DirectorySeparatorChar + filename + "_" + frameNumber.ToString().PadLeft(2, '0') + ".png";
            File.WriteAllBytes(path, bytes);
            Debug.Log("saved png to " + path);

            if (frameNumber > totalFrames)
            {
                frameNumber = 0;
            }
            frameNumber++;
            yield return null;
        }
        isCapturing = false;
    }

    void FixedUpdate()
    {
        if (!isCapturing)
        {
            RunChain();
            Shader.SetGlobalFloat("_T", Time.time);
        }

    }

    void Update()
    {
        if (Input.GetKeyDown(switchKey))
        {
            currentMidiShaderIndex = (currentMidiShaderIndex + 1) % shaders.Count;
        }
    }
    void RunChain()
    {
        shaders[0].Blit(null);

        for (int i = 1; i < shaders.Count; i++)
        {
            shaders[i].SetTexture("_MainTex", shaders[i - 1].renderTexture);
            shaders[i].Blit(shaders[i - 1].renderTexture);
        }

        if (destMaterial != null)
        {
            destMaterial.mainTexture = shaders[shaders.Count - 1].renderTexture;
        }
    }
    void Knob(MidiChannel channel, int knobNumber, float knobValue)
    {
        shaders[currentMidiShaderIndex].uniforms[knobNumber-1].Val = knobValue;
            Debug.Log("Knob: " + knobNumber + "," + knobValue);
    }
}
