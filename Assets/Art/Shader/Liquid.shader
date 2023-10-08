// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Liquid"
{
	Properties
	{
		_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 0
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_ShalowColor("Shalow Color", Color) = (1,1,1,0)
		_WaterDepth("Water Depth", Float) = 0
		_WaterFalloff("Water Falloff", Float) = 0
		_WaterSpecular("Water Specular", Float) = 0
		_WaterSmoothness("Water Smoothness", Float) = 0
		_Distortion("Distortion", Float) = 0.5
		_Foam("Foam", 2D) = "white" {}
		_FoamDepth("Foam Depth", Float) = 0
		_FoamFalloff("Foam Falloff", Float) = 0
		_FoamSpecular("Foam Specular", Float) = 0
		_FoamSmoothness("Foam Smoothness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha 
		struct Input
		{
			half2 uv_texcoord;
			float4 screenPos;
		};

		uniform sampler2D _WaterNormal;
		uniform half _NormalScale;
		uniform float4 _WaterNormal_ST;
		uniform half4 _DeepColor;
		uniform half4 _ShalowColor;
		uniform sampler2D _CameraDepthTexture;
		uniform half _WaterDepth;
		uniform half _WaterFalloff;
		uniform half _FoamDepth;
		uniform half _FoamFalloff;
		uniform sampler2D _Foam;
		uniform sampler2D _GrabTexture;
		uniform half _Distortion;
		uniform half _WaterSpecular;
		uniform half _FoamSpecular;
		uniform half _WaterSmoothness;
		uniform half _FoamSmoothness;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_WaterNormal = i.uv_texcoord * _WaterNormal_ST.xy + _WaterNormal_ST.zw;
			float2 panner52 = ( 1.0 * _Time.y * float2( -0.03,0 ) + uv_WaterNormal);
			float2 panner55 = ( 1.0 * _Time.y * float2( 0.04,0.04 ) + uv_WaterNormal);
			float3 temp_output_64_0 = BlendNormals( UnpackScaleNormal( tex2D( _WaterNormal, panner52 ), _NormalScale ) , UnpackScaleNormal( tex2D( _WaterNormal, panner55 ), _NormalScale ) );
			o.Normal = temp_output_64_0;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float eyeDepth42 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float temp_output_45_0 = abs( ( eyeDepth42 - ase_screenPos.w ) );
			float temp_output_71_0 = saturate( pow( ( temp_output_45_0 + _WaterDepth ) , _WaterFalloff ) );
			float4 lerpResult83 = lerp( _DeepColor , _ShalowColor , temp_output_71_0);
			float2 panner70 = ( 1.0 * _Time.y * float2( -0.01,0.01 ) + i.uv_texcoord);
			float temp_output_80_0 = ( saturate( pow( ( temp_output_45_0 + _FoamDepth ) , _FoamFalloff ) ) * tex2D( _Foam, panner70 ).r );
			float4 lerpResult84 = lerp( lerpResult83 , half4(1,1,1,0) , temp_output_80_0);
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor90 = tex2D( _GrabTexture, ( half3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( temp_output_64_0 * _Distortion ) ).xy );
			float4 lerpResult95 = lerp( lerpResult84 , screenColor90 , temp_output_71_0);
			o.Albedo = lerpResult95.rgb;
			float lerpResult94 = lerp( _WaterSpecular , _FoamSpecular , temp_output_80_0);
			half3 temp_cast_3 = (lerpResult94).xxx;
			o.Specular = temp_cast_3;
			float lerpResult96 = lerp( _WaterSmoothness , _FoamSmoothness , temp_output_80_0);
			o.Smoothness = lerpResult96;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16201
-342.4;720;2035;1078;2671.661;1445.187;2.309317;True;False
Node;AmplifyShaderEditor.CommentaryNode;40;-2713.377,-987.796;Float;False;828.5967;315.5001;Screen depth difference to get intersection and fading effect with terrain and objects;4;45;43;42;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;41;-2663.377,-884.2959;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;42;-2441.377,-886.796;Float;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;43;-2233.977,-841.4957;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;45;-2048.78,-843.6797;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;-1595.682,-1813.58;Float;False;1281.603;457.1994;Blend panning normals to fake noving ripples;7;64;59;57;55;52;50;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;-1523.476,-1198.597;Float;False;1113.201;508.3005;Depths controls and colors;11;86;83;75;73;71;68;67;65;60;58;53;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1545.682,-1736.281;Float;False;0;57;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;47;-1766.283,-723.5804;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-1503.679,-328.3783;Float;False;1083.102;484.2006;Foam controls and texture;9;80;77;72;70;66;63;62;61;54;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1473.476,-859.2959;Float;False;Property;_WaterDepth;Water Depth;9;0;Create;True;0;0;False;0;0;0.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;51;-1735.384,-894.1797;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;56;-1582.482,-340.7802;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;55;-1270.682,-1651.081;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.04,0.04;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1247.082,-1519.482;Float;False;Property;_NormalScale;Normal Scale;3;0;Create;True;0;0;False;0;0;0.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-1381.978,-204.4777;Float;False;Property;_FoamDepth;Foam Depth;16;0;Create;True;0;0;False;0;0;0.927;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;52;-1273.982,-1763.58;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.03,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1481.679,-42.97723;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;57;-916.0811,-1545.381;Float;True;Property;_WaterNormal;Water Normal;1;0;Create;True;0;0;False;0;e2b5beb3b75256b45970f6d87093d15c;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-1295.976,-810.2965;Float;False;Property;_WaterFalloff;Water Falloff;10;0;Create;True;0;0;False;0;0;-3.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1191.178,-142.5776;Float;False;Property;_FoamFalloff;Foam Falloff;17;0;Create;True;0;0;False;0;0;-60;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1291.781,-935.679;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;59;-926.9728,-1726.152;Float;True;Property;_Normal2;Normal2;1;0;Create;True;0;0;False;0;None;24e31ecbf813d9e49bf7a1e0d4034916;True;0;True;bump;Auto;True;Instance;57;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-1201.777,-278.3783;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;70;-1232.977,-10.77814;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.01,0.01;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;68;-1114.876,-1059.396;Float;False;Property;_ShalowColor;Shalow Color;6;0;Create;True;0;0;False;0;1,1,1,0;0,0.9352341,0.945098,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;64;-489.0787,-1610.781;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;65;-1357.276,-1148.597;Float;False;Property;_DeepColor;Deep Color;4;0;Create;True;0;0;False;0;0,0,0,0;0.1234424,0.2472026,0.3584905,0.03529412;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;67;-1115.582,-849.2795;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;66;-1016.978,-269.4778;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;69;-192.58,-2232.879;Float;False;985.6011;418.6005;Get screen color for refraction and disturbe it with normals;7;90;85;81;79;78;76;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;74;-172.2815,-1919.978;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GrabScreenPosition;78;-148.4731,-2173.521;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;76;50.32027,-1934.279;Float;False;Property;_Distortion;Distortion;14;0;Create;True;0;0;False;0;0.5;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;73;-810.7832,-1085.68;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;71;-909.28,-828.0802;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;75;-808.8833,-993.0797;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;77;-964.1777,-56.17773;Float;True;Property;_Foam;Foam;15;0;Create;True;0;0;False;0;bfb4da109e9b5834e967235fd7f6f1cd;d01457b88b1c5174ea4235d140b5fab8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;72;-795.7767,-221.4782;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;79;154.8746,-2116.387;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-579.5767,-127.0781;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;82;-600.7788,-585.0781;Float;False;Constant;_Color0;Color 0;-1;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;83;-599.2756,-951.7961;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;228.4216,-2010.879;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;381.5202,-2077.779;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;84;-335.9788,-653.1779;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;86;-564.0803,-1052.18;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;96.42117,-1198.277;Float;False;Property;_FoamSpecular;Foam Specular;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;94.22115,-1296.578;Float;False;Property;_WaterSpecular;Water Specular;12;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;91;260.4202,-1010.282;Float;False;Property;_WaterSmoothness;Water Smoothness;13;0;Create;True;0;0;False;0;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;93;0.7176704,-1481.78;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenColorNode;90;573.0214,-2081.579;Float;False;Global;_WaterGrab;WaterGrab;-1;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;89;254.6221,-930.5763;Float;False;Property;_FoamSmoothness;Foam Smoothness;19;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;88;652.5173,-1625.479;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-66.20804,739.1174;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;2;-994.2085,515.1176;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;7;-1266.209,611.1174;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;94;296.0213,-1196.977;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;-242.2081,867.1172;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;785.0711,825.6196;Float;False;Property;_Opacity;Opacity;8;0;Create;True;0;0;False;0;0.76;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;3;-818.2083,531.1177;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-1186.209,515.1176;Float;False;Property;_Speed;Speed;0;0;Create;True;0;0;False;0;0;7.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;14;285.7921,755.1174;Float;True;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;96;479.8213,-913.7762;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-658.2081,531.1177;Float;True;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;95;899.4204,-1737.381;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;18;509.7915,755.1174;Float;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,1,1,1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;10;-610.208,803.1172;Float;False;False;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;1295.245,1014.517;Float;False;Property;_Color;Color;11;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-370.2079,595.1175;Float;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;5;-882.2084,755.1174;Float;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;1003.972,15.35533;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-898.2084,611.1174;Float;False;Property;_Size;Size;2;0;Create;True;0;0;False;0;0.1;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-418.2079,931.1172;Float;False;Property;_Height;Height;5;0;Create;True;0;0;False;0;0;1.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;8;-1138.208,803.1172;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;16;93.79198,979.1171;Float;False;Property;_Falloff;Falloff;7;0;Create;True;0;0;False;0;0.02;0.018;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;762.3329,187.9624;Half;False;True;2;Half;ASEMaterialInspector;0;0;StandardSpecular;Custom/Liquid;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;42;0;41;0
WireConnection;43;0;42;0
WireConnection;43;1;41;4
WireConnection;45;0;43;0
WireConnection;47;0;45;0
WireConnection;51;0;45;0
WireConnection;56;0;47;0
WireConnection;55;0;49;0
WireConnection;52;0;49;0
WireConnection;57;1;55;0
WireConnection;57;5;50;0
WireConnection;60;0;51;0
WireConnection;60;1;53;0
WireConnection;59;1;52;0
WireConnection;59;5;50;0
WireConnection;62;0;56;0
WireConnection;62;1;54;0
WireConnection;70;0;63;0
WireConnection;64;0;59;0
WireConnection;64;1;57;0
WireConnection;67;0;60;0
WireConnection;67;1;58;0
WireConnection;66;0;62;0
WireConnection;66;1;61;0
WireConnection;74;0;64;0
WireConnection;73;0;65;0
WireConnection;71;0;67;0
WireConnection;75;0;68;0
WireConnection;77;1;70;0
WireConnection;72;0;66;0
WireConnection;79;0;78;0
WireConnection;80;0;72;0
WireConnection;80;1;77;1
WireConnection;83;0;73;0
WireConnection;83;1;75;0
WireConnection;83;2;71;0
WireConnection;81;0;74;0
WireConnection;81;1;76;0
WireConnection;85;0;79;0
WireConnection;85;1;81;0
WireConnection;84;0;83;0
WireConnection;84;1;82;0
WireConnection;84;2;80;0
WireConnection;86;0;71;0
WireConnection;93;0;84;0
WireConnection;90;0;85;0
WireConnection;88;0;86;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;2;0;1;0
WireConnection;94;0;92;0
WireConnection;94;1;87;0
WireConnection;94;2;80;0
WireConnection;12;0;13;0
WireConnection;3;0;2;0
WireConnection;14;0;11;0
WireConnection;14;1;16;0
WireConnection;96;0;91;0
WireConnection;96;1;89;0
WireConnection;96;2;80;0
WireConnection;4;0;5;0
WireConnection;4;1;3;0
WireConnection;4;2;6;0
WireConnection;95;0;93;0
WireConnection;95;1;90;0
WireConnection;95;2;88;0
WireConnection;18;0;14;0
WireConnection;10;0;5;0
WireConnection;9;0;4;0
WireConnection;9;1;10;0
WireConnection;5;0;7;0
WireConnection;5;1;8;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;0;0;95;0
WireConnection;0;1;64;0
WireConnection;0;3;94;0
WireConnection;0;4;96;0
ASEEND*/
//CHKSM=958A180DC3C9E49944F4A8F9B8DF77793062911C