Shader "Custom/MPK_Warp"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}

		 _AllowWarp(" Use Warp------------------------------------?", int) = 0
		 _wp12("warp p1_2",vector) = (0,0,0,0)
		 _wp34("warp p3_4",vector) = (0,0,0,0)
		 _wp56("warp p5_6",vector) = (0,0,0,0)
		 _wp78("warp p7_8",vector) = (0,0,0,0)
		 _wp910("warp p9_10",vector) = (0,0,0,0)
		 _wp1112("warp p11_12",vector) = (0,0,0,0)

	}
		SubShader
		 {
			 // No culling or depth
			 Cull Off ZWrite Off ZTest Less

			 Pass
			 {
				 CGPROGRAM
				 // Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
				 #pragma exclude_renderers gles
							 #pragma vertex vert
							 #pragma fragment frag

							 #include "UnityCG.cginc"

							 struct appdata
							 {
								 float4 vertex : POSITION;
								 float2 uv : TEXCOORD0;
							 };

							 struct v2f
							 {
								 float2 uv : TEXCOORD0;
								 float4 vertex : SV_POSITION;
							 };

							 sampler2D _MainTex;
							 float4 _MainTex_ST;

							 int _AllowWarp;
							 vector _wp12;
							 vector _wp34;
							 vector _wp56;
							 vector _wp78;
							 vector _wp910;
							 vector _wp1112;

							 float power(float x, float y)
							 {
								 float p = 1;
								 for (int i = 0; i < y; i++) {
									 p *= x;
								 }
								 return p;
							 }

							 float2 berneshtine(float2 p0, float2 p1, float2 p2, float2 p3, float t)
							 {
								 return (power(1 - t, 3) * p0) +
									 (3 * t * power(1 - t, 2) * p1) +
									 (3 * (t * t) * (1 - t) * p2) +
									 (power(t, 3) * p3);

							 }

							 v2f vert(appdata v)
							 {
								 v2f o;
								 o.vertex = UnityObjectToClipPos(v.vertex);
								 float2 uv = v.uv;

								 if (_AllowWarp == 1) {

									 //warp 4corner 12 point bezier rectangle
								 /*    p10(0,1)----p9(0.3,1)----p8(0.7,1)----p7(1,1)
										 |                                      |
									   p11(0,0.7)                            p6(1,0.7)
										 |                                      |
									   p12(0,0.3)  					        p5(1,0.3)
										 |                                      |
									   p1(0,0)-----p2(0.3,0)----p3(0.7,0)----p4(1,0)
								 */

									 float2 p1 = float2(0, 0) - _wp12.xy;
									 float2 p2 = float2(0.333333, 0) - _wp12.zw;
									 float2 p3 = float2(0.666666, 0) - _wp34.xy;
									 float2 p4 = float2(1, 0) - _wp34.zw;
									 float2 p5 = float2(1, 0.333333) - float2(_wp56.x, -_wp56.y);
									 float2 p6 = float2(1, 0.666666) + -float2(_wp56.z, -_wp56.w);
									 float2 p7 = float2(1, 1) - _wp78.xy;
									 float2 p8 = float2(0.666666, 1) - _wp78.zw;
									 float2 p9 = float2(0.333333, 1) - _wp910.xy;
									 float2 p10 = float2(0, 1) - _wp910.zw;
									 float2 p11 = float2(0, 0.666666) +float2( _wp1112.x, _wp1112.y);
									 float2 p12 = float2(0, 0.333333) +float2( _wp1112.z,_wp1112.w);

									 float2 brx = berneshtine(p1, p2, p3, p4, uv.x);
									 float2 brx2 = berneshtine(p7, p8, p9, p10, 1 - uv.x);

									 float2 bry = berneshtine(p4, p5, p6, p7, uv.y);
									 float2 bry2 = berneshtine(p10, p11, p12, p1, 1 - uv.y);

									 float2 xl = lerp(brx, brx2, uv.y);
									 float2 yl = lerp(bry, bry2, 1 - uv.x);

									 uv = lerp(xl, yl,float2( uv.x-0.5,uv.y-1) );
								 }
								 o.uv = uv;
								 return o;
							 }



							 fixed4 frag(v2f i) : SV_Target
							 {
								 fixed4 col = tex2D(_MainTex, (i.uv + _MainTex_ST.zw) * _MainTex_ST.xy);
							 // just invert the colors
							 col.rgb = col.rgb;
							 return col;
						 }
						 ENDCG
					 }
		 }
}
