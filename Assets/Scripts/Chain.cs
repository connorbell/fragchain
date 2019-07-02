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

    [SerializeField]
    Transform displayQuad;

    [SerializeField]
    List<RenderTexture> otherCamRenderTextures;

    private int frameNumber = 0;

    [SerializeField]
    KeyCode switchKey = KeyCode.Space;

    private int totalFrames;
    private bool isCapturing = false;
    private float aspect = 1f;

    void Start()
    {
        foreach (ShaderPass shaderPass in shaders)
        {
            shaderPass.InitWithResolution(baseResolution);
        }

        foreach (RenderTexture rt in otherCamRenderTextures)
        {
            rt.width = (int)baseResolution.x;
            rt.height = (int)baseResolution.y;
        }
        aspect = (float)baseResolution.x / baseResolution.y;
        Shader.SetGlobalFloat("_Aspect", aspect);
        displayQuad.localScale = new Vector3(displayQuad.localScale.x, displayQuad.localScale.y / aspect, displayQuad.localScale.z);
        MidiMaster.knobDelegate += Knob;

        LoadPreset();
    }

    [ContextMenu("capture")]
    void Capture()
    {
        StartCoroutine(Render());
    }

    [ContextMenu("Save new Preset")]
    void SaveNewPreset()
    {
        SavePreset(Time.time.ToString() + ".asset");
    }

    [ContextMenu("Update Loaded Preset")]
    void UpdatePreset()
    {
        SavePreset(preset.name + ".asset");
    }

    void SavePreset(string fileName)
    {
        List<PassUniforms> passes = new List<PassUniforms>();

        foreach (ShaderPass shaderPass in shaders)
        {
            PassUniforms info = new PassUniforms();
            info.shaderName = shaderPass.name;
            info.uniforms = shaderPass.uniforms;
            passes.Add(info);
        }

        Preset.CreatePreset(passes, fileName);
    }

    void LoadPreset()
    {
        if (preset)
        {
            // i should use a dictionary but i couldn't get it to serialize
            foreach (PassUniforms pass in preset.passUniforms)
            {
                int targetShaderIndex = -1;

                for (int i = 0; i < shaders.Count; i++)
                {
                    if (shaders[i].name == pass.shaderName)
                    {
                        targetShaderIndex = i;
                        break;
                    }
                }

                if (targetShaderIndex != -1)
                {
                    for (int i = 0; i < pass.uniforms.Count; i++)
                    {
                        int targetUniformIndex = -1;

                        for (int j = 0; j < shaders[targetShaderIndex].uniforms.Count; j++)
                        {
                            if (shaders[targetShaderIndex].uniforms[j].UniformName == pass.uniforms[i].UniformName)
                            {
                                targetUniformIndex = i;
                                break;
                            }
                        }

                        if (targetUniformIndex != -1)
                        {
                            shaders[targetShaderIndex].uniforms[targetUniformIndex].Val = pass.uniforms[i].Val;
                            shaders[targetShaderIndex].uniforms[targetUniformIndex].Range = pass.uniforms[i].Range;   
                        }
                    }
                }
            }

            Camera.main.transform.position = preset.cameraPos;
            Camera.main.transform.rotation = preset.cameraRotation;
        }
    }

    IEnumerator Render()
    {
        isCapturing = true;
        totalFrames = (int)(duration * fps);
        float sTime = Time.time;

        while(frameNumber < totalFrames)
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
            int padding = (int)Mathf.Floor(Mathf.Log10((float)totalFrames) + 1);

            string path = Application.dataPath + Path.DirectorySeparatorChar 
                                               + ".." + Path.DirectorySeparatorChar
                                               + "Renders" + Path.DirectorySeparatorChar 
                                               + filename + "_" + frameNumber.ToString().PadLeft(padding, '0') + ".png";

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
        if (knobNumber < shaders[currentMidiShaderIndex].uniforms.Count)
        {
            shaders[currentMidiShaderIndex].uniforms[knobNumber-1].UpdateWithValue(knobValue);
        }
    }
}
