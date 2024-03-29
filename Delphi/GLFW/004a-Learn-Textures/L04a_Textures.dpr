program L04a_Textures;

uses
  System.StartUpCopy,
  System.SysUtils,
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math.Vectors,
  Neslib.Glfw3 in '..\Glfw\Neslib.Glfw3.pas',
  uShader in 'uShader.pas',
  uTextures in 'uTextures.pas',
  uImageHandler in 'uImageHandler.pas';

const
  VERTICES: array [0..31] of single = (
    // positions          // colors           // texture coords
     0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0,   // top right
     0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0,   // bottom left
    -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0    // top left
  );

const
 INDICES: array [0..5] of integer = (  // note that we start from 0!
    0, 1, 3,   // first triangle
    1, 2, 3    // second triangle
  );

const
  VERTEX_SHADER =
    '#version 330 core'#10+
    'layout (location = 0) in vec3 aPos;'#10+
    'layout (location = 1) in vec3 aColor;'#10+
    'out vec3 ourColor;'#10+
    'void main()'#10+
    '{'#10+
    '  gl_Position = vec4(aPos, 1.0);'#10+
    '  ourColor = aColor;'#10+
    '}'#10;

const
  FRAGMENT_SHADER =
    '#version 330 core'#10+
    'out vec4 FragColor;'#10+
    'in vec3 ourColor;'#10+
    'void main()'#10+
    '{'#10+
    '  FragColor = vec4(ourColor, 1.0);'#10+
    '}';


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
    EBO: GLuint;
  texture: GLuint;
  AShader: IShader;
  Width, Height: Integer;
  info: TImageInfo;
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
  //O 1 aqui � qtd de buffers a ser gerada.
  glGenBuffers(1, @VBO);
  //o tipo do VBO � GL_ARRAY_BUFFER. Aqui define-se que o buffer � um VBO mesmo
  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  //carrega os v�rtices no VBO
  glBufferData(GL_ARRAY_BUFFER, SizeOf(VERTICES), @VERTICES, GL_STATIC_DRAW);

  glGenBuffers(1, @EBO);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, SizeOf(INDICES), @INDICES, GL_STATIC_DRAW);


  /////////////////////////
  AShader := TShader.Create('3.3.shader.vs', '3.3.shader.fs');

  glGenTextures(1, @texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  // set the texture wrapping/filtering options (on the currently bound texture object)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // load and generate the texture

  info := carregarBitmap('container.bmp');
  glTexImage2d(GL_TEXTURE_2D, 0, GL_RGB, info.width, info.height, 0, GL_RGB, GL_UNSIGNED_BYTE, info.pdata);
  glGenerateMipmap(GL_TEXTURE_2D);
  FreeMem(info.pdata);


  //vincula um vertice a variavel 0 do shader
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(Single), pointer(0));
  glEnableVertexAttribArray(0);

  // color attribute
  glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(Single), pointer(3 * sizeof(Single)));
  glEnableVertexAttribArray(1);

  //texture coordinate
  glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(Single), pointer(6 * sizeof(Single)));
  glEnableVertexAttribArray(2);

  while (glfwWindowShouldClose(Window) = 0) do
  begin
    glfwGetFramebufferSize(Window, @Width, @Height);

    glViewport(0, 0, Width, Height);

    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    AShader.Use();

    glBindTexture(GL_TEXTURE_2D, texture);
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil);

    glfwSwapBuffers(Window);
    glfwPollEvents;
  end;

  glfwDestroyWindow(Window);
  glfwTerminate;
end;

begin
  Run;
end.
