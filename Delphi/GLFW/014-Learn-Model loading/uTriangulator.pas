
{

https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles

 3 vertices -> 1 triangle
 [0, 1, 2] -> [[0, 1, 2]]

 4 vertices -> 2 triangles
 [0, 1, 2, 3] -> [[0, 1, 2],
                  [0, 2, 3]]

 5 vertices -> 3 triangles
 [0, 1, 2, 3, 4] -> [[0, 1, 2],
                     [0, 2, 3],
                     [0, 3, 4]]

 6 vertices -> 4 triangles
 [0, 1, 2, 3, 4, 5] -> [[0, 1, 2],
                        [0, 2, 3],
                        [0, 3, 4],
                        [0, 4, 5]]

 }

unit uTriangulator;

interface

uses
  System.SysUtils;

type
  TTriangulator = class
  public
    class function Triangulate<T>(_APolygon: TArray<T>): TArray<TArray<T>>;
  end;

implementation

{ TTriangulator }

class function TTriangulator.Triangulate<T>(_APolygon: TArray<T>): TArray<TArray<T>>;
var
  i: integer;
  ALength: integer;
begin
  ALength := Length(_APolygon);
  if ALength < 3 then
    raise Exception.Create('Need a polygon with more than 2 vertices.');

  SetLength(result, ALength - 2);
  for i := 0 to ALength - 3 do
    result[i] := [_APolygon[0], _APolygon[1 + i], _APolygon[2 + i]];
end;

end.
