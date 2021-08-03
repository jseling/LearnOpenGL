unit uModel;

interface

uses
  Winapi.OpenGL,
  Winapi.OpenGLExt,
  System.Math,
  System.Math.Vectors,
  System.Types,
  uShader,
  uMesh,
  System.SysUtils, Winapi.Windows;

type
  IModelLoader = interface
  ['{ACC66B9B-4CB7-41C6-A9AB-F66BE3FA259A}']
    function Vertices(idx: Integer): TVertex;
    function VerticesCount: Integer;
    function Indices(idx: Integer): Integer;
    function IndicesCount: Integer;
  end;

  IModel = interface
  ['{934551D5-C606-467D-9AB5-2673BBB84574}']
    procedure Draw(_AShader: IShader);
  end;

  TModel = class(TInterfacedObject, IModel)
  private
    FMeshes: array of TMesh;
  public
    constructor Create(_AModelLoader: IModelLoader);
    destructor Destroy; override;
    procedure Draw(_AShader: IShader);
  end;

implementation

{ TModel }

constructor TModel.Create(_AModelLoader: IModelLoader);
var
  AVertices: array of TVertex;
  AIndices: array of GLuint;
  i: integer;
  AMesh: TMesh;
  ATexture: TTexture;
begin
  OutputDebugString(PWideChar('Loading TModel...'));

  SetLength(AVertices, _AModelLoader.VerticesCount);
  SetLength(AIndices, _AModelLoader.IndicesCount);

  for i := 0 to _AModelLoader.VerticesCount -1 do
  begin
    AVertices[i] := _AModelLoader.Vertices(i);
  end;

  for i := 0 to _AModelLoader.IndicesCount -1 do
  begin
    AIndices[i] := _AModelLoader.Indices(i);
  end;

  ATexture.ID := 1;
  ATexture.TexType := 'diffuse';

  OutputDebugString(PWideChar('Loading TModel complete.'));

  AMesh := TMesh.Create(AVertices, AIndices, [ATexture]);

  SetLength(FMeshes, 1);
  FMeshes[0] := AMesh;
end;

destructor TModel.Destroy;
var
  i: integer;
begin
  for i := 0 to Length(FMeshes) -1 do
    FMeshes[i].Free;

  inherited;
end;

procedure TModel.Draw(_AShader: IShader);
var
  i: integer;
begin
  for i := 0 to Length(FMeshes) -1 do
    FMeshes[i].Draw(_AShader);
end;

end.
