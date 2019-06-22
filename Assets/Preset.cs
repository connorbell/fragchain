using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[System.Serializable]
public class Preset : ScriptableObject
{
    public List<PassUniforms> passUniforms;

    public static void CreatePreset(List<PassUniforms> dict)
    {
        Preset asset = ScriptableObject.CreateInstance<Preset>();
        asset.passUniforms = dict;
        
        AssetDatabase.CreateAsset(asset, "Assets/NewScripableObject.asset");
        AssetDatabase.SaveAssets();

        EditorUtility.FocusProjectWindow();

        Selection.activeObject = asset;
    }
}
