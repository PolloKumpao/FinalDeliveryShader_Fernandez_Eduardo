Shader "Unlit/BlendingShader"
{
    Properties
    {
		_TintColor("Tint Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex ("Second Texture", 2D) = "white" {}
        _LerpStep ("Blend Weight", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            sampler2D _SecondTex;
			float _LerpStep;
			float4 _TintColor;
            float4 _MainTex_ST;
            float4 _SecondTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
				fixed4 colorEffect = tex2D(_MainTex, i.uv) * _TintColor;
				if (colorEffect.r == 0 && colorEffect.b < 50 && colorEffect.g < 50)
				{
					colorEffect.r += sin(50 * _Time);
				}
                fixed4 col = lerp(colorEffect,tex2D(_SecondTex, i.uv),_LerpStep);
           
                return col;
            }
            ENDCG
        }
    }
}
