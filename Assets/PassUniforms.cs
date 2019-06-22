using System.Collections.Generic;

[System.Serializable]
public class PassUniforms
{
    public string shaderName = "";
    public List<FloatUniform> uniforms = new List<FloatUniform>();
}
