xof 0303txt 0032

Material ZzzEyeThroughHostMaterial {
  1.0;1.0;1.0;1.0;;
  1.0;
  0.0;0.0;0.0;;
  0.0;0.0;0.0;;
}

Mesh ZzzEyeThroughHostMesh {
  4;
  -0.05;0.0;-0.05;,
   0.05;0.0;-0.05;,
   0.05;0.0; 0.05;,
  -0.05;0.0; 0.05;;
  2;
  3;0,1,2;,
  3;0,2,3;;
  MeshMaterialList {
    1;
    2;
    0,
    0;;
    { ZzzEyeThroughHostMaterial }
  }
  MeshTextureCoords {
    4;
    0.0;0.0;,
    1.0;0.0;,
    1.0;1.0;,
    0.0;1.0;;
  }
  MeshNormals {
    1;
    0.0;1.0;0.0;;
    2;
    3;0,0,0;,
    3;0,0,0;;
  }
}

