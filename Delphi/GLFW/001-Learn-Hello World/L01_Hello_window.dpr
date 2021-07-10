program L01_Hello_window;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas';


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
//  Source: PAnsiChar;
//  Ratio: Single;
  Width, Height: Integer;
//  M, P, MVP: TMatrix3D;
begin
  glfwSetErrorCallback(ErrorCallback);
  if (glfwInit = 0) then
    raise Exception.Create('Unable to initialize GLFW');

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  Window := glfwCreateWindow(800, 600, 'LearnOpenGL', nil, nil);
  if (Window = nil) then
  begin
    glfwTerminate;
    raise Exception.Create('Failed to create GLFW window');
  end;

//  glfwSetKeyCallback(Window, KeyCallback);

  glfwMakeContextCurrent(Window);
//  glfwSwapInterval(1);

  // NOTE: OpenGL error checks have been omitted for brevity

  InitOpenGLext;

//  glGenBuffers(1, @VertexBuffer);
//  glBindBuffer(GL_ARRAY_BUFFER, VertexBuffer);
//  glBufferData(GL_ARRAY_BUFFER, SizeOf(VERTICES), @VERTICES, GL_STATIC_DRAW);
//
//  VertexShader := glCreateShader(GL_VERTEX_SHADER);
//  Source := VERTEX_SHADER;
//  glShaderSource(VertexShader, 1, @Source, nil);
//  Assert(glGetError = GL_NO_ERROR);
//  glCompileShader(VertexShader);
//
//  FragmentShader := glCreateShader(GL_FRAGMENT_SHADER);
//  Source := FRAGMENT_SHADER;
//  glShaderSource(FragmentShader, 1, @Source, nil);
//  Assert(glGetError = GL_NO_ERROR);
//  glCompileShader(FragmentShader);
//
//  ShaderProgram := glCreateProgram;
//  glAttachShader(ShaderProgram, VertexShader);
//  glAttachShader(ShaderProgram, FragmentShader);
//  glLinkProgram(ShaderProgram);
//  Assert(glGetError = GL_NO_ERROR);
//
//  MVPLocation := glGetUniformLocation(ShaderProgram, 'MVP');
//  VPosLocation := glGetAttribLocation(ShaderProgram, 'vPos');
//  VColLocation := glGetAttribLocation(ShaderProgram, 'vCol');
//
//  glEnableVertexAttribArray(VPosLocation);
//  glVertexAttribPointer(VPosLocation, 2, GL_FLOAT, GL_FALSE, SizeOf(Single) * 5,
//    nil);
//
//  glEnableVertexAttribArray(VColLocation);
//  glVertexAttribPointer(VColLocation, 3, GL_FLOAT, GL_FALSE, SizeOf(Single) * 5,
//    Pointer(SizeOf(Single) * 2));

  while (glfwWindowShouldClose(Window) = 0) do
  begin
    glfwGetFramebufferSize(Window, @Width, @Height);
//    Ratio := Width / Height;

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
//
//    M := TMatrix3D.CreateRotationZ(glfwGetTime);
//    P := TMatrix3D.CreateOrthoOffCenterLH(-Ratio, 1, Ratio, -1, 1, 1000);
//    MVP := M * P;

//    glUseProgram(ShaderProgram);
//    glUniformMatrix4fv(MVPLocation, 1, GL_FALSE, @MVP);
//    glDrawArrays(GL_TRIANGLES, 0, 3);

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
