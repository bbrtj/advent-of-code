program Solution;

{$mode objfpc}{$H+}{$J-}

uses SysUtils, Classes, Day5;

var
	vPart: Integer;
	vLine: String;
	vInput: TStringList;
begin
	vPart := StrToInt(ParamStr(1));
	vInput := TStringList.Create;

	repeat
		readln(vLine);
		vInput.Add(vLine);
	until eof;

	writeln(RunPart(vPart, vInput));
end.

