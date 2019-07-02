using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class FloatUniform
{
    public string UniformName = "_";

    public float Val = 0.0f;

    public float DefaultVal = 0.0f;

    public Vector2 Range;

    public void UpdateWithValue(float value)
    {
        Val = Mathf.Lerp(Range.x, Range.y, value);
    }
}
