//----------------------------------------------------------------------------
//
// Author      : Jan Horn
// Email       : jhorn@global.co.za
// Website     : http://www.sulaco.co.za
//               http://home.global.co.za/~jhorn
// Version     : 1.02
// Date        : 1 May 2001
// Changes     : 2 October - Added support for 32bit TGA files
//               28 July   - Faster BGR to RGB swapping routine
//
// Description : A unit that used with OpenGL projects to load BMP, JPG and TGA
//               files from the disk or a resource file.
// Usage       : LoadTexture(Filename, TextureName, LoadFromResource);
//
//               eg : LoadTexture('logo.jpg', LogoTex, TRUE);
//                    will load a JPG texture from the resource included
//                    with the EXE. File has to be loaded into the Resource
//                    using this format  "logo JPEG logo.jpg"
//
//----------------------------------------------------------------------------
unit uTextures;

interface

uses
  Windows, OpenGL, vcl.Graphics, Classes, vcl.imaging.JPEG, SysUtils;

type
  TImageInfo = record
    width, height: cardinal;
    pdata: pointer;
    tamanho: cardinal;
end;

function LoadTexture(Filename: String): TImageInfo;

implementation


{------------------------------------------------------------------}
{  Swap bitmap format from BGR to RGB                              }
{------------------------------------------------------------------}
procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;


{------------------------------------------------------------------}
{  Load BMP textures                                               }
{------------------------------------------------------------------}
function LoadBMPTexture(Filename: String) : TImageInfo;
var
  FileHeader: BITMAPFILEHEADER;
  InfoHeader: BITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: LongWord;
  PaletteLength: LongWord;
  ReadBytes: LongWord;
  Width, Height : Integer;
  pData : Pointer;

begin

    BitmapFile := CreateFile(PChar(Filename), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
    if (BitmapFile = INVALID_HANDLE_VALUE) then begin
      MessageBox(0, PChar('Error opening ' + Filename), PChar('BMP Unit'), MB_OK);
      Exit;
    end;

    // Get header information
    ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
    ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

    // Get palette
    PaletteLength := InfoHeader.biClrUsed;
    SetLength(Palette, PaletteLength);
    ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
    if (ReadBytes <> PaletteLength) then begin
      MessageBox(0, PChar('Error reading palette'), PChar('BMP Unit'), MB_OK);
      Exit;
    end;

    Width  := InfoHeader.biWidth;
    Height := InfoHeader.biHeight;
    BitmapLength := InfoHeader.biSizeImage;
    if BitmapLength = 0 then
      BitmapLength := Width * Height * InfoHeader.biBitCount Div 8;

    // Get the actual pixel data
    GetMem(pData, BitmapLength);
    ReadFile(BitmapFile, pData^, BitmapLength, ReadBytes, nil);
    if (ReadBytes <> BitmapLength) then begin
      MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
      Exit;
    end;
    CloseHandle(BitmapFile);


  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  SwapRGB(pData, Width*Height);

  result.width := Width;
  result.height := Height;
  result.pdata := pData;
end;


{------------------------------------------------------------------}
{  Load JPEG textures                                              }
{------------------------------------------------------------------}
function LoadJPGTexture(Filename: String): TImageInfo;
var
  Data : Array of LongWord;
  W, Width : Integer;
  H, Height : Integer;
  BMP : TBitmap;
  JPG : TJPEGImage;
  C : LongWord;
  Line : ^LongWord;
begin
  JPG:=TJPEGImage.Create;

  try
    JPG.LoadFromFile(Filename);
  except
    MessageBox(0, PChar('Couldn''t load JPG - "'+ Filename +'"'), PChar('BMP Unit'), MB_OK);
    Exit;
  end;


  // Create Bitmap
  BMP:=TBitmap.Create;
  BMP.pixelformat:=pf32bit;
  BMP.width:=JPG.width;
  BMP.height:=JPG.height;
  BMP.canvas.draw(0,0,JPG);        // Copy the JPEG onto the Bitmap

  //  BMP.SaveToFile('D:\test.bmp');
  Width :=BMP.Width;
  Height :=BMP.Height;
  SetLength(Data, Width*Height);

  For H:=0 to Height-1 do
  Begin
    Line :=BMP.scanline[Height-H-1];   // flip JPEG
    For W:=0 to Width-1 do
    Begin
      c:=Line^ and $FFFFFF; // Need to do a color swap
      Data[W+(H*Width)] :=(((c and $FF) shl 16)+(c shr 16)+(c and $FF00)) or $FF000000;  // 4 channel.
//        Data[W+(H*Width)] := $FF000000;
      inc(Line);
    End;
  End;

  BMP.free;
  JPG.free;

  result.width := Width;
  result.height := Height;
  result.pdata := addr(Data[0]);
end;


{------------------------------------------------------------------}
{  Loads 24 and 32bpp (alpha channel) TGA textures                 }
{------------------------------------------------------------------}
function LoadTGATexture(Filename: String): TImageInfo;
var
  TGAHeader : packed record   // Header type for TGA images
    FileType     : Byte;
    ColorMapType : Byte;
    ImageType    : Byte;
    ColorMapSpec : Array[0..4] of Byte;
    OrigX  : Array [0..1] of Byte;
    OrigY  : Array [0..1] of Byte;
    Width  : Array [0..1] of Byte;
    Height : Array [0..1] of Byte;
    BPP    : Byte;
    ImageInfo : Byte;
  end;
  TGAFile   : File;
  bytesRead : Integer;
  image     : Pointer;    {or PRGBTRIPLE}
  Width, Height : Integer;
  ColorDepth    : Integer;
  ImageSize     : Integer;
  I : Integer;
  Front: ^Byte;
  Back: ^Byte;
  Temp: Byte;
begin
  if FileExists(Filename) then
  begin
    AssignFile(TGAFile, Filename);
    Reset(TGAFile, 1);

    // Read in the bitmap file header
    BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));

  end
  else
  begin
    MessageBox(0, PChar('File not found  - ' + Filename), PChar('TGA Texture'), MB_OK);
    Exit;
  end;



  // Only support uncompressed images
  if (TGAHeader.ImageType <> 2) then  { TGA_RGB }
  begin

    CloseFile(tgaFile);
    MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Compressed TGA files not supported.'), PChar('TGA File Error'), MB_OK);
    Exit;
  end;

  // Don't support colormapped files
  if TGAHeader.ColorMapType <> 0 then
  begin

    CloseFile(TGAFile);
    MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Colormapped TGA files not supported.'), PChar('TGA File Error'), MB_OK);
    Exit;
  end;

  // Get the width, height, and color depth
  Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
  Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
  ColorDepth := TGAHeader.BPP;
  ImageSize  := Width*Height*(ColorDepth div 8);

  if ColorDepth < 24 then
  begin

    CloseFile(TGAFile);
    MessageBox(0, PChar('Couldn''t load "'+ Filename +'". Only 24 bit TGA files supported.'), PChar('TGA File Error'), MB_OK);
    Exit;
  end;

  GetMem(Image, ImageSize);


  BlockRead(TGAFile, image^, ImageSize, bytesRead);
  if bytesRead <> ImageSize then
  begin

    CloseFile(TGAFile);
    MessageBox(0, PChar('Couldn''t read file "'+ Filename +'".'), PChar('TGA File Error'), MB_OK);
    Exit;
  end;


  // TGAs are stored BGR and not RGB, so swap the R and B bytes.
  // 32 bit TGA files have alpha channel and gets loaded differently
  if TGAHeader.BPP = 24 then
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*3);
      Back := Pointer(Integer(Image) + I*3 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
  end
  else
  begin
    for I :=0 to Width * Height - 1 do
    begin
      Front := Pointer(Integer(Image) + I*4);
      Back := Pointer(Integer(Image) + I*4 + 2);
      Temp := Front^;
      Front^ := Back^;
      Back^ := Temp;
    end;
  end;
  result.width := Width;
  result.height := Height;
  result.pdata := Image;
end;


{------------------------------------------------------------------}
{  Determines file type and sends to correct function              }
{------------------------------------------------------------------}
function LoadTexture(Filename: String) : TImageInfo;
begin
  if copy(Uppercase(filename), length(filename)-3, 4) = '.BMP' then
    result := LoadBMPTexture(Filename);
  if copy(Uppercase(filename), length(filename)-3, 4) = '.JPG' then
    result := LoadJPGTexture(Filename);
  if copy(Uppercase(filename), length(filename)-3, 4) = '.TGA' then
    result := LoadTGATexture(Filename);
end;


end.
