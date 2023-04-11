using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public class DualParaboloidTools : EditorWindow
{
    private enum SizeEnum
    {
        _128 = 128,
        _256 = 256,
        _512 = 512,
        _1024 = 1024,
        _2048 = 2048,
        _4096 = 4096
    }
    
    [MenuItem("Tools/DualParaboloidTools")]
    static void OpenAbility()
    {
        EditorWindow.GetWindow<DualParaboloidTools>().Show();
    }
    private Cubemap m_cubeValue;
    private SizeEnum m_size = SizeEnum._512;
    private void OnGUI()
    {
        GUILayout.BeginVertical();
        m_cubeValue = EditorGUILayout.ObjectField(m_cubeValue, typeof(Cubemap), true) as Cubemap;
        if (m_cubeValue != null)
        {
            m_size = (SizeEnum)EditorGUILayout.EnumPopup("Size", m_size);
            if (GUILayout.Button("Generate"))
            {
                Generate();
            }
        }
        GUILayout.EndVertical();
    }

    private void Generate()
    {
        if (m_cubeValue != null)
        {
            var path = AssetDatabase.GetAssetPath(m_cubeValue);
            path = path.Replace(".", "_d.");
            RenderTexture rt = RenderImage();
            Texture2D png = new Texture2D(rt.width, rt.height, TextureFormat.RGB24, false);
            png.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);
            png.Apply();
            File.WriteAllBytes(path, png.EncodeToPNG());
            AssetDatabase.Refresh();
            rt.Release();
        }
    }
    
    private RenderTexture RenderImage()
    {
        if (m_size == default) m_size = SizeEnum._512;
        int size = (int) m_size;
        RenderTexture destination = new RenderTexture(size, size, 0);
        Shader sd = Shader.Find("Unlit/DualParaboloidGenerate");
        Material mt = new Material(sd);
        mt.SetTexture("_EnvMap",m_cubeValue);
        Graphics.Blit(null, destination, mt);
        return destination;
    }
}
