using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderPass : MonoBehaviour
{
    [HideInInspector]
    public Material Mat;
    [SerializeField]
    public float Scale = 1f;

    [SerializeField]
    bool backBufferEnabled = false;

	[SerializeField]
	Shader shader;
	
    public RenderTexture renderTexture;

    [HideInInspector]
    public RenderTexture feedbackTexture;

    public List<FloatUniform> uniforms;

    private Vector2 finalResolution;
    protected virtual void UpdateUniforms()
    {

    }

    void OnDestroy()
	{
		if (renderTexture != null)
		{
			renderTexture.Release();		
		}
        if (feedbackTexture != null)
        {
            feedbackTexture.Release();
        }
	}
	
    public void InitWithResolution(Vector2 resolution)
    {
        renderTexture = new RenderTexture((int)(resolution.x * Scale), (int)(resolution.y * Scale), 24);
		Mat = new Material(shader);

        if (backBufferEnabled)
        {
            feedbackTexture = new RenderTexture((int)(resolution.x * Scale), (int)(resolution.y * Scale), 24);
        }
    }

	public void SetTexture(string uniform, Texture tex)
	{
		Mat.SetTexture(uniform, tex);
	}

    public void Blit(Texture source)
    {
        UpdateUniforms();
        
        foreach (FloatUniform uni in uniforms)
        {
            Mat.SetFloat(uni.UniformName, uni.Val);
        }

        Mat.SetVector("_Texel", renderTexture.texelSize);
      
        if (backBufferEnabled)
		{
            Graphics.Blit(renderTexture, feedbackTexture);
            Mat.SetTexture("_LastTex", feedbackTexture);
		}
		
        Graphics.Blit(source, renderTexture, Mat);
    }
}
