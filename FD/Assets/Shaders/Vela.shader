Shader "Custom/Vela"
{
    Properties
    {
		_TintColor("Tint Color", Color) = (1,1,1,1)
		_Amplitude("Amplitude factor", Range(0, 30)) = 0.01
    }
SubShader{
	Tags { "RenderType" = "Opaque" }

	CGPROGRAM
	#pragma surface surf Lambert vertex:vert
	sampler2D _NoiseTex;
	sampler2D _RampTex; 
	fixed _RampVal;
	fixed _Amplitude;
	float4 _TintColor;
	struct Input {
		float2 uv_NoiseTex;
	};
	void vert(inout appdata_full v) {
		 //Cuanto más abajo mas afecta
			v.vertex.z += (0.1 / v.vertex.y) * sin((v.vertex.z + _Time)*_Amplitude);
	
	}
	void surf(Input IN, inout SurfaceOutput o) {
		
		fixed4 color = _TintColor;
		o.Albedo = color.rgb;
		o.Emission = color.rgb;
	}
	ENDCG
}
FallBack "Diffuse"
}