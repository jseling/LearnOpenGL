unit uShader;

interface

uses
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.IOUtils,
  System.SysUtils,
  System.Math.Vectors;

type
  IShader = interface
  ['{45D731CB-E274-4BC5-A430-0ED4F9970C27}']
//    property ID: GLuint;
    procedure Use();
    procedure SetUniform1i(const name: String; value: integer);
    procedure SetUniform1f(const name: String; value: single);
    procedure SetUniform3f(const name: String; v1, v2, v3: single);
    procedure SetUniformV3f(const name: String; value: TPoint3D);
    procedure SetUniformMatrix4fv(const name: String; value: TMatrix3D);
  end;


  TShader = class(TInterfacedObject, IShader)
  private
    FID: GLuint;
  public
    property ID: GLuint read FID;

    constructor Create(const vertexPath: String; const fragPath: String);

    procedure Use();
    procedure SetUniform1i(const name: String; value: integer);
    procedure SetUniform1f(const name: String; value: single);
    procedure SetUniform3f(const name: String; v1, v2, v3: single);
    procedure SetUniformV3f(const name: String; value: TPoint3D);
    procedure SetUniformMatrix4fv(const name: String; value: TMatrix3D);
  end;

implementation

{ TShader }

constructor TShader.Create(const vertexPath, fragPath: String);
var
  VertexShader: GLuint;
  FragmentShader: GLuint;
  Source: PAnsiChar;
  success: integer;
  size: integer;
  infoLog: array of PGLchar;
begin
//cria um vertex shader
  VertexShader := glCreateShader(GL_VERTEX_SHADER);

  Source := PAnsiChar(AnsiString(TFile.ReadAllText(vertexPath)));
  size := Length(Source);
  //Source := VERTEX_SHADER;

  //carrega o código fonte no shader recém criado
  glShaderSource(VertexShader, 1, @Source, @Size);
//  Assert(glGetError = GL_NO_ERROR);
  //compila o shader
  glCompileShader(VertexShader);

  glGetShaderiv(VertexShader, GL_COMPILE_STATUS, @success);
  if(success = 0) then
  begin
    glGetShaderiv(VertexShader, GL_INFO_LOG_LENGTH, @size);
    SetLength(infoLog, size);
    glGetShaderInfoLog(VertexShader, size, nil, @infoLog[0]);
    raise Exception.Create('ERROR::SHADER::VERTEX::COMPILATION_FAILED'#13#10 + AnsiString(infoLog));
  end;


  //cria um fragment shader
  FragmentShader := glCreateShader(GL_FRAGMENT_SHADER);

  Source := PAnsiChar(AnsiString(TFile.ReadAllText(fragPath)));
  size := Length(Source);
  //Source := FRAGMENT_SHADER;

  //carrega o código fonte
  glShaderSource(FragmentShader, 1, @Source, @Size);
//  Assert(glGetError = GL_NO_ERROR);
  //compila
  glCompileShader(FragmentShader);

  glGetShaderiv(FragmentShader, GL_COMPILE_STATUS, @success);
  if(success = 0) then
  begin
    glGetShaderiv(FragmentShader, GL_INFO_LOG_LENGTH, @size);
    SetLength(infoLog, size);
    glGetShaderInfoLog(FragmentShader, size, nil, @infoLog[0]);
    raise Exception.Create('ERROR::SHADER::VERTEX::COMPILATION_FAILED'#13#10 + AnsiString(infoLog));
  end;

  //cria um shader program
  //ele empacotará os shaders
  FID := glCreateProgram();
  //anexa o vertex shader ao shader program
  glAttachShader(FID, VertexShader);
  //anexa o fragment
  glAttachShader(FID, FragmentShader);
  //vincula os shaders ao programa
  glLinkProgram(FID);
//  Assert(glGetError = GL_NO_ERROR);

  glDeleteShader(VertexShader);
  glDeleteShader(FragmentShader);
end;

procedure TShader.Use;
begin
  glUseProgram(FID);
end;

procedure TShader.SetUniform1i(const name: String; value: integer);
begin
  glUniform1i(glGetUniformLocation(FID, PAnsiChar(AnsiString(name))), value);
end;

procedure TShader.SetUniform3f(const name: String; v1, v2, v3: single);
var
  ALocation: GLInt;
begin
  ALocation := glGetUniformLocation(FID, PAnsiChar(AnsiString(name)));
  glUniform3f(ALocation, v1, v2, v3);
end;

procedure TShader.SetUniformMatrix4fv(const name: String; value: TMatrix3D);
var
  ALocation: GLInt;
begin
  ALocation := glGetUniformLocation(FID, PAnsiChar(AnsiString(name)));
  glUniformMatrix4fv(ALocation, 1, GL_FALSE, @value);
end;

procedure TShader.SetUniformV3f(const name: String; value: TPoint3D);
var
  ALocation: GLInt;
begin
  ALocation := glGetUniformLocation(FID, PAnsiChar(AnsiString(name)));
  glUniform3fv(ALocation, 1, @value);
end;

procedure TShader.SetUniform1f(const name: String; value: single);
begin
  glUniform1f(glGetUniformLocation(FID, PAnsiChar(AnsiString(name))), value);
end;

end.
