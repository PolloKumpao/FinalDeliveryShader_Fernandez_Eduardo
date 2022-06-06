Shader "Unlit/TransparetnStencil"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_alpha("Alpha", Range(0,1)) = 1
		_Amplitude("Amplitude factor", Range(0, 30)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Geometry+1" }
        LOD 200
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
				Stencil
		{
			Ref 1
			Comp always
			Pass replace
		}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _alpha;
			fixed _Amplitude;
            v2f vert (appdata v)
            {
                v2f o;
				v.vertex.y += (v.vertex.y) * sin((v.vertex.y + _Time)*_Amplitude);
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col.a = _alpha;
                // apply fog
         
                return col;
            }
            ENDCG
        }
    }
}
