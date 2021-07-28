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
  System.SysUtils;

type
  IModelLoader = interface
  ['{7A50E87B-4AC0-4C2B-B399-4C8332878460}']
  end;

  TModel = class
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
begin
//    _AModelLoader.

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
