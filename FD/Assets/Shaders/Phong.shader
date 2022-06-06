﻿Shader "Unlit/Phong"
{
	Properties
	{
		 _objectColor("Main color",Color) = (0,0,0,1)
		 _ambientInt("Ambient int", Range(0,1)) = 0.25
		 _ambientColor("Ambient Color", Color) = (0,0,0,1)

		 _diffuseInt("Diffuse int", Range(0,1)) = 1
		_scecularExp("Specular exponent",Float) = 2.0

		_pointLightPos("Point light Pos",Vector) = (0,0,0,1)
		_pointLightColor("Point light Color",Color) = (0,0,0,1)
		_pointLightIntensity("Point light Intensity",Float) = 1

		_directionalLightDir("Directional light Dir",Vector) = (0,1,0,1)
		_directionalLightColor("Directional light Color",Color) = (0,0,0,1)
		_directionalLightIntensity("Directional light Intensity",Float) = 1


		_specularAlpha("Specular alpha",Range(0,1)) = 0.0
		_fresnelQ("Fresnel q",Float) = 1.0

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON
            #include "UnityCG.cginc"
			#include "Assets/Shaders/BRDF.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

			fixed4 _objectColor;
			
			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _scecularExp;

			float4 _pointLightPos;
			float4 _pointLightColor;
			float _pointLightIntensity;

			float4 _directionalLightDir;
			float4 _directionalLightColor;
			float _directionalLightIntensity;


			float _specularAlpha;
			float _fresnelQ;

            fixed4 frag (v2f i) : SV_Target
            {
				

				//3 phong model light components
                //We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = ambientComp;
				
				float3 viewVec;
				float3 halfVec;
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 FSchlick = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 lightColor;
				float3 lightDir;
#if DIRECTIONAL_LIGHT_ON

				//Directional light properties
				lightColor = _directionalLightColor.xyz;
				lightDir = normalize(_directionalLightDir);

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal),0,1);

				//Specular component	
				//Los componentes son FresnelSchlick Function, Geometry function, Distribution function
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				halfVec = reflect(-lightDir, i.worldNormal);
				//specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);
				specularComp = lightColor * BRDF(_specularAlpha, _fresnelQ, viewVec, i.worldNormal, lightDir);
				//blinnPhong
				//halfVec = normalize(viewVec + lightDir);
				//specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal),0), _scecularExp);

				//Sum
				finalColor += clamp(float4(_directionalLightIntensity*(difuseComp+specularComp),1),0,1);
#endif
#if POINT_LIGHT_ON
				//Point light properties
				lightColor = _pointLightColor.xyz;
				lightDir = _pointLightPos - i.wPos;
				float lightDist = length(lightDir);
				lightDir = lightDir / lightDist;
				//lightDir *= 4 * 3.14;

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal), 0, 1)/ lightDist;

				//Specular component	
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				halfVec = reflect(-lightDir, i.worldNormal);
				//fixed4 specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);
				specularComp = lightColor * BRDF(_specularAlpha, _fresnelQ, viewVec, i.worldNormal, lightDir);
				//blinnPhong
				/*halfVec = normalize(viewVec + lightDir);
				specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal), 0), _scecularExp) / lightDist;*/

				//Sum
				finalColor += clamp(float4(_pointLightIntensity*(difuseComp + specularComp),1),0,1);
				
				
#endif
				//pointLight
                
				return finalColor * _objectColor;
            }
            ENDCG
        }
    }
}
