// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Gradient of transparent"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_Emission("Emission", 2D) = "white" {}
		_AO("AO", 2D) = "white" {}
		_AlbedoColor("Albedo Color", Color) = (1,1,1,0)
		_EmissionLevel("Emission Level", Range( 0 , 1)) = 0
		_AOlevel("AO level", Range( 0 , 1)) = 0.81
		_StartPoint("StartPoint", Range( -10 , 10)) = 0.81
		_Under("Under", Range( 0 , 1)) = 0
		_Distribution("Distribution", Range( 0.1 , 10)) = 1
		_Metallic("Metallic", 2D) = "white" {}
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_Min("Min", Range( 0 , 1)) = 0
		_Nmlevel("Nm level", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZTest LEqual
		Blend SrcAlpha OneMinusSrcAlpha
		BlendOp Add
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float _Nmlevel;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform float4 _AlbedoColor;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _EmissionLevel;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform float _Smoothness;
		uniform float _AOlevel;
		uniform sampler2D _AO;
		uniform float4 _AO_ST;
		uniform float _StartPoint;
		uniform float _Distribution;
		uniform float _Min;
		uniform float _Under;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 Normal58 = ( _Nmlevel * UnpackNormal( tex2D( _Normal, uv_Normal ) ) );
			o.Normal = Normal58;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo62 = ( _AlbedoColor * tex2D( _Albedo, uv_Albedo ) );
			o.Albedo = Albedo62.rgb;
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float4 Emission61 = ( _EmissionLevel * tex2D( _Emission, uv_Emission ) );
			o.Emission = Emission61.rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 Metallic60 = tex2D( _Metallic, uv_Metallic );
			o.Metallic = Metallic60.r;
			o.Smoothness = _Smoothness;
			float2 uv_AO = i.uv_texcoord * _AO_ST.xy + _AO_ST.zw;
			float4 AO59 = ( _AOlevel * tex2D( _AO, uv_AO ) );
			o.Occlusion = AO59.r;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float temp_output_44_0 = saturate( ( ( ase_vertex3Pos.x + _StartPoint ) / _Distribution ) );
			float clampResult36 = clamp( temp_output_44_0 , _Min , _Under );
			o.Alpha = ( 1.0 - clampResult36 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16201
1921;1;1918;1016;2458.057;891.0359;1.3;False;False
Node;AmplifyShaderEditor.RangedFloatNode;31;-1473.573,924.6121;Float;False;Property;_StartPoint;StartPoint;9;0;Create;True;0;0;False;0;0.81;0.09;-10;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;15;-1428.821,644.3315;Float;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;20;-2091.495,-1096.641;Float;False;1431.36;1565.672;Textures;19;65;69;62;67;58;68;63;55;64;66;59;51;61;53;52;54;57;56;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1227.77,1071.472;Float;False;Property;_Distribution;Distribution;11;0;Create;True;0;0;False;0;1;0.1;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;-1009.375,652.3394;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1452.518,-390.8658;Float;False;Property;_EmissionLevel;Emission Level;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-1475.557,-873.3765;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;695619efb9b5a174086d4ca3d602c7a0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;63;-1474.318,-677.7059;Float;False;Property;_Nmlevel;Nm level;15;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;54;-1463.248,-309.7389;Float;True;Property;_Emission;Emission;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;64;-1460.751,-594.3024;Float;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;None;5688037424cf68b4f9b1f82c9f1fdae2;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;-1509.795,-85.69241;Float;False;Property;_AOlevel;AO level;8;0;Create;True;0;0;False;0;0.81;0.81;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;41;-779.5245,878.0197;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;65;-1403.366,-1042.537;Float;False;Property;_AlbedoColor;Albedo Color;5;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;53;-1479.63,27.64544;Float;True;Property;_AO;AO;4;0;Create;True;0;0;False;0;None;44bfaa91f4b452c47a3d375ade9572ae;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1170.333,-404.6501;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-1130.782,-918.7586;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;56;-1421.913,216.624;Float;True;Property;_Metallic;Metallic;12;0;Create;True;0;0;False;0;None;aa894e3580fdd334a885997d81b382b9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;44;-477.6791,833.1309;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1175.729,-658.5413;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-499.344,352.0335;Float;False;Property;_Min;Min;14;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-669.1583,587.5769;Float;False;Property;_Under;Under;10;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1197.61,-43.47662;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-1003.457,-515.3835;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;36;-254.0285,479.4365;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-1030.331,-75.82475;Float;False;AO;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-995.8887,-725.9076;Float;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1037.897,148.652;Float;False;Metallic;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-995.0889,-930.2191;Float;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-213.3528,328.9635;Float;False;Property;_Smoothness;Smoothness;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-271.6415,5.819962;Float;False;59;AO;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-161.6936,1167.266;Float;False;Property;_Float0;Float 0;2;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;-282.5273,-499.4319;Float;False;62;Albedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;45;12.20728,426.0847;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-321.2914,-390.1552;Float;False;58;Normal;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;40;-313.0427,849.2966;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-283.4468,149.9919;Float;False;60;Metallic;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;25;-393.9469,-288.1078;Float;False;61;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-1996.722,-692.3419;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1;149.4714,1236.681;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;247.3152,55.96408;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Gradient of transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;3;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;1;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;15;1
WireConnection;32;1;31;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;55;0;52;0
WireConnection;55;1;54;0
WireConnection;67;0;65;0
WireConnection;67;1;69;0
WireConnection;44;0;41;0
WireConnection;66;0;63;0
WireConnection;66;1;64;0
WireConnection;57;0;51;0
WireConnection;57;1;53;0
WireConnection;61;0;55;0
WireConnection;36;0;44;0
WireConnection;36;1;50;0
WireConnection;36;2;37;0
WireConnection;59;0;57;0
WireConnection;58;0;66;0
WireConnection;60;0;56;0
WireConnection;62;0;67;0
WireConnection;45;0;36;0
WireConnection;40;0;44;0
WireConnection;1;1;4;0
WireConnection;0;0;10;0
WireConnection;0;1;17;0
WireConnection;0;2;25;0
WireConnection;0;3;26;0
WireConnection;0;4;49;0
WireConnection;0;5;46;0
WireConnection;0;9;45;0
ASEEND*/
//CHKSM=020ABAA00F870CCE545A78CF6166CDAFE2D81E03