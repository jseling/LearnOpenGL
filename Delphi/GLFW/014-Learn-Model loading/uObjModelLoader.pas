unit uObjModelLoader;

interface

uses
  uObjModel,
  uModel,
  uMesh,
  System.Math,
  System.Math.Vectors,
  Winapi.Windows,
  System.SysUtils,
  System.Generics.Collections;

type
  TObjModelLoader = class(TInterfacedObject, IModelLoader)
  private
    FModel: TObjModel;
    FVertices: TList<TVertex>;
    FIndices: TList<Integer>;

    function AddVertex(_AVertex: TVertex): Integer;
    function GetVertexIndex(_AVertex: TVertex): Integer;
    function AddUniqueVertex(_AVertex: TVertex): Integer;
    procedure AddVertexIndice(_AIndice: Integer);
    procedure LoadVertices();
  public
    constructor Create(const _AFileName: String);
    destructor Destroy; override;
    function Vertices(idx: Integer): TVertex;
    function VerticesCount: Integer;

    function Indices(idx: Integer): Integer;
    function IndicesCount: Integer;
  end;

implementation

{ TObjModelLoader }

function TObjModelLoader.AddUniqueVertex(_AVertex: TVertex): Integer;
var
  AIndice: Integer;
begin
  AIndice := GetVertexIndex(_AVertex);
  if AIndice < 0 then
    AIndice := AddVertex(_AVertex);

  result := AIndice;
end;

function TObjModelLoader.AddVertex(_AVertex: TVertex): integer;
begin
  result := FVertices.Add(_AVertex);
end;

procedure TObjModelLoader.AddVertexIndice(_AIndice: Integer);
begin
  FIndices.Add(_AIndice);
end;

constructor TObjModelLoader.Create(const _AFileName: String);
begin
  FModel := TObjModel.Create(_AFileName);

  FVertices := TList<TVertex>.Create;
  FVertices.Capacity := FModel.VertCount;

  FIndices := TList<Integer>.Create;
  FIndices.Capacity := FModel.FaceCount * 3;

  LoadVertices();
end;

destructor TObjModelLoader.Destroy;
begin
  FVertices.Free;
  FIndices.Free;
  FModel.Free;
  inherited;
end;

function TObjModelLoader.GetVertexIndex(_AVertex: TVertex): Integer;
var
  i :integer;
const
  EPSILON = 0.0001; //floatpoint comparison tolerance
begin
  result := -1;
  for i := 0 to FVertices.Count -1 do
  begin
    if FVertices[i].Position.EqualsTo(_AVertex.Position, EPSILON) and
       FVertices[i].Normal.EqualsTo(_AVertex.Normal, EPSILON) and
       FVertices[i].TexCoords.EqualsTo(_AVertex.TexCoords, EPSILON) then
    begin
      result := i;
      break;
    end;
  end;
end;

function TObjModelLoader.Indices(idx: Integer): Integer;
begin
  result := FIndices[idx];
end;

function TObjModelLoader.IndicesCount: Integer;
begin
  result := FIndices.Count;
end;

procedure TObjModelLoader.LoadVertices;
var
  i, j: integer;
  AVertex: TVertex;
  AFaceVertex: TFaceVertex;
  AFace: TFace;
  AVertexIndice: Integer;
begin
  OutputDebugString(PWideChar('Loading TObjModelLoader. Total faces: ' + IntToStr(FModel.FaceCount)));
  for i:=0 to FModel.FaceCount -1 do
  begin
    AFace := FModel.Face(i);
    for j := 0 to Length(AFace.Vertices) -1 do
    begin
      AFaceVertex := AFace.Vertices[j];

      AVertex.Position := FModel.Vert(AFaceVertex.IDPosition);
      AVertex.Normal := FModel.VertNormal(AFaceVertex.IDNormal);
      AVertex.TexCoords := FModel.VertTexture(AFaceVertex.IDUV);

      AVertexIndice := AddUniqueVertex(AVertex);
      AddVertexIndice(AVertexIndice)
    end;
  end;
  OutputDebugString(PWideChar('Loading TObjModelLoader complete.'));
end;

function TObjModelLoader.Vertices(idx: Integer): TVertex;
begin
  result := FVertices[idx];
end;

function TObjModelLoader.VerticesCount: Integer;
begin
  result := FVertices.Count;
end;

end.
