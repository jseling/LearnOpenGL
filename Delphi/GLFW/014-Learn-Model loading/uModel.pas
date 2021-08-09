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
  System.SysUtils, Winapi.Windows,
  System.Generics.Collections;

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
    FMeshes: TObjectList<TMesh>;
  public
    constructor Create(_AModelLoader: IModelLoader);
    destructor Destroy; override;
    procedure Draw(_AShader: IShader);
  end;

implementation

{ TModel }

constructor TModel.Create(_AModelLoader: IModelLoader);
var
  i: integer;
  AMesh: TMesh;
  ATexture: TTexture;
begin
  FMeshes := TObjectList<TMesh>.Create;
  OutputDebugString(PWideChar('Loading TModel...'));

  AMesh := TMesh.Create(_AModelLoader.VerticesCount, _AModelLoader.IndicesCount, 1);


  for i := 0 to _AModelLoader.VerticesCount -1 do
  begin
    AMesh.Vertices[i] := _AModelLoader.Vertices(i);
  end;

  for i := 0 to _AModelLoader.IndicesCount -1 do
  begin
    AMesh.Indices[i] := _AModelLoader.Indices(i);
  end;

  AMesh.Textures[0].ID := 1;
  AMesh.Textures[0].TexType := 'diffuse';

  AMesh.SetuPMesh();

  OutputDebugString(PWideChar('Loading TModel complete.'));



  FMeshes.Add(AMesh);
end;

destructor TModel.Destroy;
begin
  FMeshes.Free;

  inherited;
end;

procedure TModel.Draw(_AShader: IShader);
var
  AMesh: TMesh;
begin
  for AMesh in FMeshes do
    AMesh.Draw(_AShader);
end;

end.
