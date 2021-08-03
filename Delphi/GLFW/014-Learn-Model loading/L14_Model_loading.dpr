program L14_Model_loading;

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
  uCamera in 'uCamera.pas',
  uMesh in 'uMesh.pas',
  uModel in 'uModel.pas',
  uObjModel in 'uObjModel.pas',
  uObjModelLoader in 'uObjModelLoader.pas',
  uTriangulator in 'uTriangulator.pas';

const
  LIGHT_POSITIONS: array [0..3] of TPoint3D = (
    (X:  0.7; Y:  0.2; Z: 2.0),
    (X:  2.3; Y: -3.3; Z: -4.0),
    (X: -4.0; Y:  2.0; Z: -12.0),
    (X:  0.0; Y:  0.0; Z: -3.0)
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

  lightingShader: IShader;
  Width, Height: Integer;

  model, view, proj: TMatrix3D;

  deltaTime: single;
  lastFrame: single;
  currentFrame: single;

  diffuseMap, specularMap: GLuint;

  i: integer;

  AModel: IModel;
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

  //--------------------------------------

  lightingShader:= TShader.Create('colors.vs', 'colors.fs');

//  diffuseMap := createtexture('..\..\..\..\media\backpack\diffuse.bmp', GL_RGB);
//  specularMap := createtexture('..\..\..\..\media\backpack\specular.bmp', GL_RGB);
//  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\backpack\backpack.obj'));

//  diffuseMap := createtexture('..\..\..\..\media\QuaterniusMonsters\Cthulhu_Texture.bmp', GL_RGB);
//  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\QuaterniusMonsters\Cthulhu.obj'));

  diffuseMap := createtexture('..\..\..\..\media\QuaterniusRPG\Wizard_Texture.bmp', GL_RGB);
  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\QuaterniusRPG\Wizard.obj'));

//  diffuseMap := createtexture('..\..\..\..\media\newscene\Container.bmp', GL_RGB);
//  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\newscene\2quadas.obj'));

//  diffuseMap := createtexture('..\..\..\..\media\oranberry\OranBerry.bmp', GL_RGB);
//  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\oranberry\OranBerry.obj'));


//  diffuseMap := createtexture('..\..\..\..\media\capsule\capsule0.bmp', GL_RGB);
//  AModel := TModel.Create(TObjModelLoader.Create('..\..\..\..\media\capsule\capsule.obj'));


  lastFrame := 0;

  glEnable(GL_DEPTH_TEST);

  lightingShader.Use();
  lightingShader.SetUniform1i('material.diffuse',   0);
  lightingShader.SetUniform1i('material.specular',  1);
  lightingShader.SetUniform1f('material.shininess', 32.0);

  lightingShader.SetUniform3f('dirLight.direction', -0.2, -1, -0.3);
  lightingShader.SetUniform3f('dirLight.ambient',  0, 0, 0);
  lightingShader.SetUniform3f('dirLight.diffuse',  1, 1, 1);
  lightingShader.SetUniform3f('dirLight.specular', 1, 1, 1);

  lightingShader.SetUniform1f('spotLight.cutOff', Cos(DegToRad(12.5)));
  lightingShader.SetUniform1f('spotLight.outerCutOff', Cos(DegToRad(17.5)));

  lightingShader.SetUniform3f('spotLight.ambient',  0, 0, 0);
  lightingShader.SetUniform3f('spotLight.diffuse',  1, 1, 1);
  lightingShader.SetUniform3f('spotLight.specular', 1, 1, 1);

  lightingShader.SetUniform1f('spotLight.constant',  1.0);
  lightingShader.SetUniform1f('spotLight.linear',    0.09);
  lightingShader.SetUniform1f('spotLight.quadratic', 0.032);

  for i:=0 to High(LIGHT_POSITIONS) do
  begin
    lightingShader.SetUniformV3f('pointLights['+IntToStr(i)+'].position', LIGHT_POSITIONS[i]);
    lightingShader.SetUniform3f('pointLights['+IntToStr(i)+'].ambient',  0.05, 0.05, 0.05);
    lightingShader.SetUniform3f('pointLights['+IntToStr(i)+'].diffuse',  0.8, 0.8, 0.8);
    lightingShader.SetUniform3f('pointLights['+IntToStr(i)+'].specular', 1.0, 1.0, 1.0);
    lightingShader.SetUniform1f('pointLights['+IntToStr(i)+'].constant',  1.0);
    lightingShader.SetUniform1f('pointLights['+IntToStr(i)+'].linear',    0.09);
    lightingShader.SetUniform1f('pointLights['+IntToStr(i)+'].quadratic', 0.032);
  end;

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

    lightingShader.Use();
    lightingShader.SetUniformV3f('spotLight.position', ACamera.Position);
    lightingShader.SetUniformV3f('spotLight.direction', ACamera.Front);

    lightingShader.SetUniformV3f('viewPos', ACamera.Position);

    view := ACamera.GetViewMatrix();
    proj := TMatrix3D.Identity;
    proj := proj * TMatrix3D.CreatePerspectiveFovRH(DegToRad(ACamera.FOV), 800/600, 0.1, 100);
    lightingShader.SetUniformMatrix4fv('view', view);
    lightingShader.SetUniformMatrix4fv('projection', proj);

    model := TMatrix3D.Identity;
//    model := model * TMatrix3D.CreateScaling(TPoint3D.Create(0.01, 0.01, 0.01));
    lightingShader.SetUniformMatrix4fv('model', model);

    AModel.Draw(lightingShader);

  //--------------------------------------


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
