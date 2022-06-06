using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlanarReflectionManager : MonoBehaviour
{
    Camera m_ReflectionCamera;
    Camera m_MainCamera;

    public GameObject m_ReflectionPlane;

    public Material m_FloorMaterial;

    RenderTexture m_RenderTarget;
    // Start is called before the first frame update
    void Start()
    {
        GameObject reflectionCameraGo = new GameObject("ReflectionCamera");
        m_ReflectionCamera = reflectionCameraGo.AddComponent<Camera>();
        m_ReflectionCamera.enabled = false;
       
        m_MainCamera = Camera.main;
        m_RenderTarget = new RenderTexture(Screen.width, Screen.height, 24);

    }

    // Update is called once per frame
    void Update()
    {
        
    }
    private void OnPostRender()
    {
        RenderReflection();
    }
    void RenderReflection()
    {
        m_ReflectionCamera.CopyFrom(m_MainCamera);
        m_ReflectionCamera.cullingMask = ~(1 << LayerMask.NameToLayer("Reflect"));

        Vector3 cameraDirectionWorldSpace = m_MainCamera.transform.forward;
        Vector3 cameraUpWorldSpace = m_MainCamera.transform.up;
        Vector3 cameraPositionWorldSpace = m_MainCamera.transform.position;

        //Transform to plane space
        Vector3 cameraDirectionPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraDirectionWorldSpace);
        Vector3 cameraUpPlaneSpace = m_ReflectionPlane.transform.InverseTransformDirection(cameraUpWorldSpace);
        Vector3 cameraPositionPlaneSpace = m_ReflectionPlane.transform.InverseTransformPoint(cameraPositionWorldSpace);

        //Mirror the vectors 
        cameraDirectionPlaneSpace.y *= -1.0f;
        cameraUpPlaneSpace.y *= -1.0f;
        cameraPositionPlaneSpace.y *= -1.0f;

        // Transform back to world space

        cameraDirectionWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraDirectionPlaneSpace);
        cameraUpWorldSpace = m_ReflectionPlane.transform.TransformDirection(cameraUpPlaneSpace);
        cameraPositionWorldSpace = m_ReflectionPlane.transform.TransformPoint(cameraPositionPlaneSpace);

        // set camera pos and rotation

        m_ReflectionCamera.transform.position = cameraPositionWorldSpace;
        m_ReflectionCamera.transform.LookAt(cameraPositionWorldSpace + cameraDirectionWorldSpace, cameraUpWorldSpace);

        //Setr render targer
        m_ReflectionCamera.targetTexture = m_RenderTarget;

        //render the reflection camera
        m_ReflectionCamera.Render();

        //Draw full screen quad
        DrawQuad();
    }
    
    void DrawQuad()
    {
        GL.PushMatrix();

        m_FloorMaterial.SetPass(0);
        m_FloorMaterial.SetTexture("_ReflectionTex", m_RenderTarget);

        GL.LoadOrtho();

        GL.Begin(GL.QUADS);
        GL.TexCoord2(1.0f, 0.0f);
        GL.Vertex3(0.0f, 0.0f, 0.0f);
        GL.TexCoord2(1.0f, 1.0f);
        GL.Vertex3(0.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 1.0f);
        GL.Vertex3(1.0f, 1.0f, 0.0f);
        GL.TexCoord2(0.0f, 0.0f);
        GL.Vertex3(1.0f, 0.0f, 0.0f);
        GL.End();

        GL.PopMatrix();
    }
}
