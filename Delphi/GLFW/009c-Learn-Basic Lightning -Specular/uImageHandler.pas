unit uImageHandler;

interface

uses
  Winapi.Windows;


type
  TImageInfo = record
    width, height: cardinal;
    pdata: pointer;
    tamanho: cardinal;
end;

function CarregarBitmap(Filename: String): TImageinfo;


implementation

function CarregarBitmap(Filename: String): TImageinfo;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: Cardinal;
  PaletteLength: Cardinal;
  ReadBytes: Cardinal;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;
  width, height: cardinal;
  pData: pointer;
  i: integer;
begin
  BitmapFile:= CreateFile(PChar(Filename),
    GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, 0, 0);
  ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader),
    ReadBytes, nil);
  ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader),
     ReadBytes, nil);
  Width := InfoHeader.biWidth;
  Height := InfoHeader.biHeight;
  PaletteLength := InfoHeader.biClrUsed;
  SetLength(Palette, PaletteLength);
  ReadFile(BitmapFile, Palette, PaletteLength,
    ReadBytes, nil);
  BitmapLength := InfoHeader.biSizeImage;
  //contra bug de tamanho
  if BitmapLength = 0 then
    BitmapLength := Width * Height *
    InfoHeader.biBitCount div 8;
  GetMem(pData, BitmapLength);
  ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes,
    nil);
  CloseHandle(BitmapFile);
  {$WARNINGS OFF} // desligar aviso de aumento dos
                  // operands (290)
  for I:= 0 to Width * Height - 1 do begin
    Front:= Pointer(Cardinal(pData) + I*3);
    Back:= Pointer(Cardinal(pData) + I*3 + 2);
    Temp:= Front^;
    Front^:= Back^;
    Back^:= Temp;
  end;
  {$WARNINGS ON}
  result.width:= width;
  result.height:= height;
  result.pdata:= pdata;
  result.tamanho:= bitmapLength;
end;

end.
