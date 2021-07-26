program L12b_Attenuation;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas',
  uShader in 'uShader.pas',
  uTextures in 'uTextures.pas',
  uCamera in 'uCamera.pas';

//  uImageHandler in 'uImageHandler.pas';

const
  VERTICES: array [0..287] of single = (
    // positions       // normals        // texture coords
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,
     0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 0.0,
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0,
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,

    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,
     0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 0.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,

    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,
    -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,  1.0, 1.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,  0.0, 0.0,
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,

     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0,  0.0,  0.0,  1.0, 1.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
     0.5, -0.5,  0.5,  1.0,  0.0,  0.0,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,

    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  1.0, 1.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,

    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0,
     0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  1.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0
  );

const
  CUBE_POSITIONS: array [0..9] of array [0..2] of Single = (
    ( 0.0,  0.0,  0.0),
    ( 2.0,  5.0, -15.0),
    (-1.5, -2.2, -2.5),
    (-3.8, -2.0, -12.3),
    ( 2.4, -0.4, -3.5),
    (-1.7,  3.0, -7.5),
    ( 1.3, -2.0, -2.5),
    ( 1.5,  2.0, -2.5),
    ( 1.5,  0.2, -1.5),
    (-1.3,  1.0, -1.5)
  );


var
  lastX, lastY: Single;
  firstMouse: Boolean;
  ACamera: ICamera;


procedure ErrorCallback(error: Integer; const description: PAnsiChar); cdecl;
var
  Desc: String;
begin
  Desc := String(AnsiString(description));
  raise Exception.CreateFmt('GLFW Error %d: %s', [error, Desc]);
end;

procedure KeyCallback(window: PGLFWwindow; key, scancode, action, mods: Integer); cdecl;
begin
  if (key = GLFW_KEY_ESCAPE) and (action = GLFW_PRESS) then
    glfwSetWindowShouldClose(window, GLFW_TRUE);
end;

procedure ScrollCallback(wdw: PGLFWwindow; xoffset, yoffset: Double); cdecl;
begin
  ACamera.ProcessMouseScroll(yoffset);
end;

procedure MouseCallback(wdw: PGLFWwindow; xpos, ypos: Double); cdecl;
var
  xoffset: single;
  yoffset: single;
begin
  if firstMouse then
  begin
    lastX := xpos;
    lastY := ypos;
    firstMouse := false;
  end;

  xoffset := xpos - lastX;
  yoffset := lastY - ypos; // reversed since y-coordinates range from bottom to top
  lastX := xpos;
  lastY := ypos;

  ACamera.ProcessMouseMovement(xoffset, yoffset);
end;

procedure ProcessInput(wdw: PGLFWwindow; deltaTime: Single);
begin
  if (glfwGetKey(wdw, GLFW_KEY_ESCAPE) = GLFW_PRESS) then
      glfwSetWindowShouldClose(wdw, GLFW_TRUE);

  if (glfwGetKey(wdw, GLFW_KEY_W) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmForward, deltaTime);

  if (glfwGetKey(wdw, GLFW_KEY_S) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmBackward, deltaTime);

  if (glfwGetKey(wdw, GLFW_KEY_A) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmLeft, deltaTime);

  if (glfwGetKey(wdw, GLFW_KEY_D) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmRight, deltaTime);

  if (glfwGetKey(wdw, GLFW_KEY_Q) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmDown, deltaTime);

  if (glfwGetKey(wdw, GLFW_KEY_E) = GLFW_PRESS) then
    ACamera.ProcessKeyboard(TCameraMovement.cmUp, deltaTime);
end;


function createtexture(path: String; format: GLenum): GLuint;
var
  textureID: GLuint;
  info: TImageInfo;
begin
  glGenTextures(1, @textureID);
  info := LoadTexture(path);
  try
    glBindTexture(GL_TEXTURE_2D, textureID);  
    glTexImage2d(GL_TEXTURE_2D, 0, format, info.width, info.height, 0, format, GL_UNSIGNED_BYTE, info.pdata);
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); 

    result := textureID;    
  finally 
    FreeMem(info.pdata);     
  end;
end;

procedure Run;
var
  Window: PGLFWwindow;
  cubeVAO, VBO, lightCubeVAO: GLuint;

  lightingShader,
  lightCubeShader: IShader;
  Width, Height: Integer;

  model, view, proj: TMatrix3D;

  deltaTime: single;
  lastFrame: single;
  currentFrame: single;

  diffuseMap, specularMap: GLuint;

  lightPos: TPoint3D;
//  lightColor,
  lightDifCalc,
  lightAmbCalc: TPoint3D;

  i: integer;
  APos: array [0..2] of Single;
  angle: single;  
begin
  glfwSetErrorCallback(ErrorCallback);

  //inicializa a GLFW
  if (glfwInit = 0) then
    raise Exception.Create('Unable to initialize GLFW');

  //configura a GLFW
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  //cria a janela
  Window := glfwCreateWindow(800, 600, 'LearnOpenGL', nil, nil);
  if (Window = nil) then
  begin
    glfwTerminate;
    raise Exception.Create('Failed to create GLFW window');
  end;

//  glfwSetKeyCallback(Window, KeyCallback);

  //define a janela como o contexto atual
  glfwMakeContextCurrent(Window);

  ACamera := TCamera.Create(TPoint3D.Create(0, 0, 3), TPoint3D.Create(0, 1, 0));

  glfwSetInputMode(Window, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

  lastX := 400;
  lastY := 300;
  firstMouse := True;
  glfwSetCursorPosCallback(Window, MouseCallback);

  glfwSetScrollCallback(Window, ScrollCallback);

  InitOpenGLext;

  //--------------------------------------

  glGenVertexArrays(1, @cubeVAO);
  glGenBuffers(1, @VBO);

  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(VERTICES), @VERTICES, GL_STATIC_DRAW);

  glBindVertexArray(cubeVAO);

  // position attribute
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(single), pointer(0));
  glEnableVertexAttribArray(0);
  // normal attribute
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(single), pointer(3* sizeof(Single)));
  glEnableVertexAttribArray(1);
  // texture attribute
  glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(single), pointer(6* sizeof(Single)));
  glEnableVertexAttribArray(2);

  //--------------------------------------

  // second, configure the light's VAO (VBO stays the same; the vertices are the same for the light object which is also a 3D cube)
  glGenVertexArrays(1, @lightCubeVAO);
  glBindVertexArray(lightCubeVAO);

  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  // note that we update the lamp's position attribute's stride to reflect the updated buffer data
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(single), pointer(0));
  glEnableVertexAttribArray(0);

  //--------------------------------------

  lightingShader:= TShader.Create('colors.vs', 'colors.fs');
  lightCubeShader:= TShader.Create('light_cube.vs', 'light_cube.fs');

  diffuseMap := createtexture('container2.bmp', GL_RGB);
  specularMap := createtexture('container2_specular.bmp', GL_RGB);

  lightPos := TPoint3d.Create(1.2, 1.0, 2.0);

  lastFrame := 0;

  glEnable(GL_DEPTH_TEST);
  while (glfwWindowShouldClose(Window) = 0) do
  begin
    currentFrame := glfwGetTime();
    deltaTime := currentFrame - lastFrame;
    lastFrame := currentFrame;

    ProcessInput(Window, deltaTime);

    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

//    lightColor.x := sin(glfwGetTime() * 2.0);
//    lightColor.y := sin(glfwGetTime() * 0.7);
//    lightColor.z := sin(glfwGetTime() * 1.3);
//
    lightAmbCalc := TPoint3D.Create( 0.2, 0.2, 0.2);
    lightDifCalc := TPoint3D.Create( 0.5, 0.5, 0.5);

  //--------------------------------------

    lightingShader.Use();
    lightingShader.SetUniform1i('material.diffuse', 0);
    lightingShader.SetUniform1i('material.specular', 1);
    lightingShader.SetUniform1f('material.shininess', 32.0);

    lightingShader.SetUniformV3f('light.ambient',  lightAmbCalc);
    lightingShader.SetUniformV3f('light.diffuse',  lightDifCalc); // darken diffuse light a bit
    lightingShader.SetUniform3f('light.specular', 1.0, 1.0, 1.0); 
    lightingShader.SetUniformV3f('light.position', lightPos);

    lightingShader.SetUniform1f('light.constant',  1.0);
    lightingShader.SetUniform1f('light.linear',    0.09);
    lightingShader.SetUniform1f('light.quadratic', 0.032);

    lightingShader.SetUniformV3f('viewPos', ACamera.Position);

    view := ACamera.GetViewMatrix();
    proj := TMatrix3D.Identity;
    proj := proj * TMatrix3D.CreatePerspectiveFovRH(DegToRad(ACamera.FOV), 800/600, 0.1, 100);
    lightingShader.SetUniformMatrix4fv('view', view);
    lightingShader.SetUniformMatrix4fv('projection', proj);

    // bind diffuse map
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, diffuseMap);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, specularMap);

    glBindVertexArray(cubeVAO);

    for i:=0 to High(CUBE_POSITIONS) do
    begin
      APos[0] := CUBE_POSITIONS[i][0];
      APos[1] := CUBE_POSITIONS[i][1];
      APos[2] := CUBE_POSITIONS[i][2];

      angle := 20 * i;
      model := TMatrix3D.CreateRotation(TPoint3d.Create(1.0, 0.3, 0.5),  DegToRad(angle));
      model := model * TMatrix3D.CreateTranslation(TPoint3D.Create(APos[0], APos[1], APos[2]));
      lightingShader.SetUniformMatrix4fv('model', model);

      glDrawArrays(GL_TRIANGLES, 0, 36);
    end;
  //--------------------------------------

    lightCubeShader.Use();
    lightCubeShader.SetUniformV3f('color',  TPoint3D.Create(1, 1, 1));

    lightCubeShader.SetUniformMatrix4fv('view', view);
    lightCubeShader.SetUniformMatrix4fv('projection', proj);

    model := TMatrix3D.Identity;
    model := model * TMatrix3D.CreateScaling(TPoint3D.Create(0.2, 0.2, 0.2));
    model := model * TMatrix3D.CreateTranslation(lightPos);
    lightCubeShader.SetUniformMatrix4fv('model', model);

    glBindVertexArray(lightCubeVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
  //--------------------------------------

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
