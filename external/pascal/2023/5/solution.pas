program Solution;

{$mode objfpc}{$H+}{$J-}

uses SysUtils, Classes, Day5;

var
	lPart: Integer;
	lLine: String;
	lInput: TStringList;
begin
	lPart := StrToInt(ParamStr(1));
	lInput := TStringList.Create;

	repeat
		readln(lLine);
		lInput.Add(lLine);
	until eof;

	write(RunPart(lPart, lInput));
end.

