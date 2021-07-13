# Learn OpenGL
Tutorials from [Learn OpenGL website](https://learnopengl.com/)

Outra execução:
https://github.com/neslib/DelphiLearnOpenGL/wiki

GLFW
https://github.com/neslib/DelphiGlfw

STBImage
https://github.com/neslib/DelphiStb/tree/master/Stb

Assimp
https://github.com/BrokenGamesUG/delphi3d-engine/tree/main/Engine/assimp

## Ideias

ConfigWindow();
SceneInitialization();
SceneLoop();
Finalization();

https://community.khronos.org/t/efficiency-of-vao-with-vbo-for-every-model/70869/3
https://www.khronos.org/opengl/wiki/Vertex_Specification_Best_Practices
https://stackoverflow.com/questions/29515405/how-many-vaos-and-vbos
https://stackoverflow.com/questions/21513763/drawing-multiple-models-using-multiple-opengl-vbos/21540956

VBO?

AObject := NewObject.AddVertices(dataVertices)
			.AddIndices(dataIndices)
			.AddVertexShader('xxxx')
			.AddFragmentShader('yyyy')
			.AddTexture(imageData)
			.ConfigVertexAttrib(0)
			.ConfigVertexAttrib(1)
			.ConfigVertexAttrib(2);
			
AObject.Draw;
