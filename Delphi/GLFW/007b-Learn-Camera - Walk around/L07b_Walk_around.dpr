program L07b_Walk_around;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas',
  uShader in 'uShader.pas',
  uTextures in 'uTextures.pas';

//  uImageHandler in 'uImageHandler.pas';

const
  VERTICES: array [0..179] of single = (
    -0.5, -0.5, -0.5,  0.0, 0.0,
     0.5, -0.5, -0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 0.0,

    -0.5, -0.5,  0.5,  0.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,

    -0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5,  0.5,  1.0, 0.0,

     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,

    -0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0, 1.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,

    -0.5,  0.5, -0.5,  0.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0, 1.0
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

procedure Run;
var
  Window: PGLFWwindow;
  VBO: GLuint;
  VAO: GLuint;
  texture1, texture2: GLuint;
  AShader: IShader;
  Width, Height: Integer;
  info: TImageInfo;

  model, view, proj: TMatrix3D;
  i: integer;
  APos: array [0..2] of Single;
  angle: single;

  cameraPos,
  cameraFront,
  cameraUp: TPoint3D;

  cameraSpeed : single;

  procedure ProcessInput(wdw: PGLFWwindow);
  begin
    if (glfwGetKey(wdw, GLFW_KEY_ESCAPE) = GLFW_PRESS) then
        glfwSetWindowShouldClose(wdw, GLFW_TRUE);


    cameraSpeed := 0.05;
    if (glfwGetKey(wdw, GLFW_KEY_W) = GLFW_PRESS) then
    begin
       cameraPos := cameraPos + (cameraSpeed * cameraFront);
    end;

    if (glfwGetKey(wdw, GLFW_KEY_S) = GLFW_PRESS) then
    begin
       cameraPos := cameraPos - (cameraSpeed * cameraFront);
    end;

    if (glfwGetKey(wdw, GLFW_KEY_A) = GLFW_PRESS) then
    begin
       cameraPos := cameraPos - (cameraFront.CrossProduct(cameraUp).Normalize * cameraSpeed);
    end;

    if (glfwGetKey(wdw, GLFW_KEY_D) = GLFW_PRESS) then
    begin
       cameraPos := cameraPos + (cameraFront.CrossProduct(cameraUp).Normalize * cameraSpeed);
    end;
  end;
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
//  glfwSwapInterval(1);

  // NOTE: OpenGL error checks have been omitted for brevity

  InitOpenGLext;

  glGenVertexArrays(1, @VAO);
  glBindVertexArray(VAO);

  //Gera um buffer e vincula ele a uma ID armazenada dentro da variavel VBO.
  //O 1 aqui é qtd de buffers a ser gerada.
  glGenBuffers(1, @VBO);
  //o tipo do VBO é GL_ARRAY_BUFFER. Aqui define-se que o buffer é um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  //carrega os vértices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(VERTICES), @VERTICES, GL_STATIC_DRAW);

  /////////////////////////
  AShader := TShader.Create('3.3.shader.vs', '3.3.shader.fs');

//texture 1
  glGenTextures(1, @texture1);
  glBindTexture(GL_TEXTURE_2D, texture1);
  
  // set the texture wrapping/filtering options (on the currently bound texture object)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load and generate the texture

  info := LoadTexture('container.bmp');
  glTexImage2d(GL_TEXTURE_2D, 0, GL_RGB, info.width, info.height, 0, GL_RGB, GL_UNSIGNED_BYTE, info.pdata);
  glGenerateMipmap(GL_TEXTURE_2D);
  FreeMem(info.pdata);

//texture 2
  glGenTextures(1, @texture2);
  glBindTexture(GL_TEXTURE_2D, texture2);
  
  // set the texture wrapping/filtering options (on the currently bound texture object)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load and generate the texture

  info := LoadTexture('awesomeface.tga');
  glTexImage2d(GL_TEXTURE_2D, 0, GL_RGBA, info.width, info.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, info.pdata);
  glGenerateMipmap(GL_TEXTURE_2D);
  FreeMem(info.pdata);

  AShader.Use();
  AShader.SetUniform1i('texture2', 1);

  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(Single), pointer(0));
  glEnableVertexAttribArray(0);

  //texture coordinate
  glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(Single), pointer(3 * sizeof(Single)));
  glEnableVertexAttribArray(1);


  glActiveTexture(GL_TEXTURE0);
  glBindTexture(GL_TEXTURE_2D, texture1);
  glActiveTexture(GL_TEXTURE1);
  glBindTexture(GL_TEXTURE_2D, texture2);

  AShader.Use();

  proj := TMatrix3D.Identity;
  proj := proj * TMatrix3D.CreatePerspectiveFovRH(DegToRad(45), 800/600, 0.1, 100);
  AShader.SetUniformMatrix4fv('projection', proj);

  cameraPos := TPoint3D.Create(0.0, 0.0,  3.0);
  cameraFront := TPoint3D.Create(0.0, 0.0, -1.0);
  cameraUp := TPoint3D.Create(0.0, 1.0,  0.0);

  glEnable(GL_DEPTH_TEST);
  while (glfwWindowShouldClose(Window) = 0) do
  begin
    ProcessInput(Window);
    view := TMatrix3D.CreateLookAtRH(cameraPos, cameraPos + cameraFront, cameraUp);
    AShader.SetUniformMatrix4fv('view', view);

    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    glBindVertexArray(VAO);


    for i:=0 to High(CUBE_POSITIONS) do
    begin
      APos[0] := CUBE_POSITIONS[i][0];
      APos[1] := CUBE_POSITIONS[i][1];
      APos[2] := CUBE_POSITIONS[i][2];

      angle := 20 * i;
      model := TMatrix3D.CreateRotation(TPoint3d.Create(1.0, 0.3, 0.5),  DegToRad(angle));
      model := model * TMatrix3D.CreateTranslation(TPoint3D.Create(APos[0], APos[1], APos[2]));
      AShader.SetUniformMatrix4fv('model', model);

      glDrawArrays(GL_TRIANGLES, 0, 36);
    end;

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
