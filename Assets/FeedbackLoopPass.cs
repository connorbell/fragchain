using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FeedbackLoopPass : ShaderPass
{
    [SerializeField]
    float feedbackScale = 0.5f;
    [SerializeField]
    float feedbackFactor = 2f;

    protected override void UpdateUniforms()
    {
        Mat.SetFloat("_Scale", feedbackScale);
        Mat.SetFloat("_FeedbackFactor", feedbackFactor);
    }
}
