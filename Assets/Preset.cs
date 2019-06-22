using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[System.Serializable]
public class Preset : ScriptableObject
{
    public List<PassUniforms> passUniforms;
    public Vector3 cameraPos = Vector3.zero;
    public Quaternion cameraRotation = Quaternion.identity;
    public static void CreatePreset(List<PassUniforms> dict)
    {
        Preset asset = ScriptableObject.CreateInstance<Preset>();
        asset.passUniforms = dict;
        asset.cameraPos = Camera.main.transform.position;
        asset.cameraRotation = Camera.main.transform.rotation;

        AssetDatabase.CreateAsset(asset, "Assets/NewScripableObject.asset");
        AssetDatabase.SaveAssets();

        EditorUtility.FocusProjectWindow();

        Selection.activeObject = asset;
    }
}
