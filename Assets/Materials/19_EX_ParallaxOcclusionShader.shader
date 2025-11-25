Shader "Unlit/19_EX_ParallaxOcclusionShader"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _HeightTex ("Height", 2D) = "black" {}
        _HeightScale("Height Scale",float)=0
        _MinLayers("Min Layers",float)=8
        _MaxLayers("Max Layers",float)=32
        _ScrollSpeed("ScrollSpeed", Vector) =(0,0,0,0 )
        _WaveParameter("WaveParameter",Vector)=(0,0,0,0)
         _Color("Color", Color) = (1, 0, 0, 1)


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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDirTS:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ParallaxShallow;
            sampler2D _HeightTex;
            float4 _HeightTex_ST;
            float _HeightScale;
            float _MinLayers;
            float _MaxLayers;
            float4 _ScrollSpeed;
            float4 _WaveParameter;
            fixed4 _Color;

             float random(float2 fact)
            {
                return frac(sin(dot(float2(fact.x,fact.y),float2(12.9898,78.233)))*43758.5453);

            }

            float randomVec(float2 fact)
            {
                float2 angle=float2(
                    dot(fact,fixed2(127.1,311.7)),
                    dot(fact,fixed2(269.5,183.3))
                );
                return frac(sin(angle)*43758.5453123)*2-1;
            }

            float ValueNoise(float density,float2 uv)
            {
                float2 uvFloor=floor(uv*density);
                float2 uvFrac=frac(uv*density);

                float v00=random((uvFloor+float2(0,0))/density);
                float v01=random((uvFloor+float2(0,1))/density);
                float v10=random((uvFloor+float2(1,0))/density);
                float v11=random((uvFloor+float2(1,1))/density);
                
                fixed2 u=uvFrac*uvFrac*(3-2*uvFrac);
                float v0010=lerp(v00,v10,u.x);
                float v0111=lerp(v01,v11,u.x);

                return lerp(v0010,v0111,u.y);
            }

            float PerlinNoise(float density,float2 uv)
            {

                float2 uvFloor=floor(uv*density);
                float2 uvFrac=frac(uv*density);

                float v00=randomVec(uvFloor+float2(0,0));
                float v01=randomVec(uvFloor+float2(0,1));
                float v10=randomVec(uvFloor+float2(1,0));
                float v11=randomVec(uvFloor+float2(1,1));

                float c00=dot(v00,uvFrac-fixed2(0,0));
                float c01=dot(v01,uvFrac-fixed2(0,1));
                float c10=dot(v10,uvFrac-fixed2(1,0));
                float c11=dot(v11,uvFrac-fixed2(1,1));

                fixed2 u=uvFrac*uvFrac*(3-2*uvFrac);

                float v0010=lerp(c00,c10,u.x);
                float v0111=lerp(c01,c11,u.x);

                return lerp(v0010,v0111,u.y)/2+0.5;
            }

            float FractalSumNoise(float density,float2 uv)
            {
                float fn;
                fn=PerlinNoise(density*1,uv)*1.0/2;
                fn+=PerlinNoise(density*2,uv)*1.0/4;
                fn+=PerlinNoise(density*8,uv)*1.0/8;
                fn+=PerlinNoise(density*16,uv)*1.0/16;

                return fn;

            }

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =TRANSFORM_TEX(v.uv, _MainTex);
                //ワールド空間の視線ベクトル
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;
                //タンジェント空間の基底ベクトルをワールド空間へ
                float3 t = normalize(mul(
                    (float3x3)unity_ObjectToWorld, v.tangent.xyz));
                float3 n = normalize(mul(
                    (float3x3)unity_ObjectToWorld, v.normal));                
                float3 b = cross(n, t) *
                    v.tangent.w * unity_WorldTransformParams.w;

                float3x3 tbn = float3x3(t,b,n);
                //視線ベクトルをタンジェント空間へ
                o.viewDirTS= mul(tbn,viewDirWS);

                return o;
            }
            float2 ParallaxOcclusionMapping(float2 uv,float3 viewDirTS)
            {

                float3 v = normalize(viewDirTS);
                //斜めから見るほどレイヤー数を増やす
                float ndotv = abs(v.z);
                float numLayers = lerp(_MaxLayers,_MinLayers,ndotv);
                float layerDepth = 1.0/numLayers;

                //UV上で移動する方向とスケール
                float2 P = v.xy/max(v.z,0.0001)*_HeightScale;
                float2 deltaTexCoord = P/numLayers;

                float2 curTexCoord = uv;
                float curLayerDepth = 0.0;
                float curHeight=tex2D(_HeightTex,curTexCoord).r;

                //手前から億へサンプルして高さとの交点を探す
                [loop]
                for(int i = 0; i < (int)_MaxLayers; i++)
                {
                    if(curLayerDepth > curHeight){ break; }
                    curTexCoord -= deltaTexCoord;
                    curLayerDepth += layerDepth;
                    curHeight = tex2D(_HeightTex,curTexCoord).r;
                }
                 //1ステップ前との間で線形補間して制度を上げる
                float2 preTexCood = curTexCoord + deltaTexCoord;
                float preLayerDepth = curLayerDepth - layerDepth;
                float preHeight = tex2D(_HeightTex,preTexCood).r;

                float heightDiff = preHeight - preLayerDepth;
                float curDiff = curHeight - curLayerDepth;
                float weight = heightDiff/(heightDiff - curDiff + 1e-5);
                float2 finalTexCoord = lerp(curTexCoord,preTexCood,saturate(weight));
                return finalTexCoord;
            }

            float2 WaveOffset(float2 uv, float time, float speed, float amplitude, float frequency)
            {
                float2 center = float2(0.5, 0.5);
                float2 dir = uv - center;
        
                float dist = length(dir);

                
                //float noise = PerlinNoise(8, uv * 4 + time * 0.2);
                float wave = sin(dist * frequency + time * speed);//+noise*0.2

                return uv + normalize(dir) * wave * amplitude;
            }

            
            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewDirTS=i.viewDirTS;
               

                
                float2 noiseScroll=FractalSumNoise(1,i.uv*_ScrollSpeed.xy *sin(_Time.y));
                //noiseScroll=normalize(dir) *wave*2;
                i.uv+=noiseScroll;
                float2 waveUV=WaveOffset(i.uv,_Time.y,_WaveParameter.x,_WaveParameter.y,_WaveParameter.z);


                //i.uv.xy+=noiseScroll;
                
                float2 uvPOM = ParallaxOcclusionMapping(waveUV, viewDirTS);
                //uvPOM = clamp(uvPOM, 0.0, 1.0);

                fixed4 finalTex=tex2D(_MainTex,uvPOM);
                fixed4 randomColor=_Color;
                finalTex*=_Color;
                return finalTex;

                // //高さ
                // float3 viewDirTS=normalize(-i.viewDirTS);
                // float2 mainUV=i.uv*_MainTex_ST.xy+_MainTex_ST.zw;
                // float2 heightUV=i.uv*_HeightTex_ST.xy+_HeightTex_ST.zw;
                // //高さマップのr値を参照して高さの情報を取得
                // float height=tex2D(_HeightTex,heightUV).r;

                // //浅い場所と深い場所でoffsetの計算
                // float2 shallowOffset=viewDirTS.xy*_ParallaxShallow;
                // float2 deepOffset=viewDirTS.xy*height*_ParallaxDeep;

                // //高さ情報に応じてoffsetを使い分ける
                // float2 uv=mainUV+lerp(shallowOffset,deepOffset,height);
                
                // // apply fog
                //return tex2D(_MainTex,uv);
            }


            ENDCG
        }

        
    }
}
