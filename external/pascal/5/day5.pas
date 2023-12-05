unit Day5;

{$mode objfpc}{$H+}{$J-}
{$modeswitch advancedrecords}

interface

uses SysUtils, Classes, FGL, Math, Character;

function RunPart(vPart: Integer; vInput: TStringList): String;

type
	TNumber = Int64;

	TRange = record
		Lower: TNumber;
		Upper: TNumber;

		class operator = (const vR1, vR2: TRange): Boolean;
	end;

	TRangeList = specialize TFPGList<TRange>;

	TMapping = class
	strict private
		FRangeFrom: TRange;
		FBaseTo: TNumber;

	public
		constructor Create(const vRange: TRange; vTo: TNumber);

		function TryMap(var vValue: TNumber): Boolean;
		function TryMapRange(vRange: TRange; vRangesMapped, vRangesUnmapped: TRangeList): Boolean;
	end;

	TMappingList = specialize TFPGObjectList<TMapping>;
	TNumberList = specialize TFPGList<TNumber>;

	TAlmanacMap = class
	strict private
		FMappings: TMappingList;

	public
		constructor Create();
		destructor Destroy; override;

		procedure AddMapping(vTo, vFrom, vLength: TNumber);
		function MapNumber(vValue: TNumber): TNumber;
		function MapRanges(vRange: TRange): TRangeList;
	end;

	TAlmanacMapList = specialize TFPGObjectList<TAlmanacMap>;

implementation

procedure ParseInput(vInput: TStringList; vNumbers: TNumberList; vMaps: TAlmanacMapList);
var
	vLine: String;
	vStringPart: String;
	vSplit: TStringArray;
	vLastMap: TAlmanacMap;
begin
	for vLine in vInput do begin
		if Length(vLine) = 0 then
			continue;

		if vLine.StartsWith('seeds:') then begin
			vSplit := copy(vLine, 8).Split([' ']);
			for vStringPart in vSplit do
				vNumbers.Add(StrToInt64(vStringPart));
		end

		else if IsNumber(vLine[1]) then begin
			vSplit := vLine.Split([' ']);
			vLastMap.AddMapping(
				StrToInt64(vSplit[0]),
				StrToInt64(vSplit[1]),
				StrToInt64(vSplit[2])
			);
		end

		else begin
			vLastMap := TAlmanacMap.Create;
			vMaps.Add(vLastMap);
		end;
	end;
end;

function PartOne(vNumbers: TNumberList; vMaps: TAlmanacMapList): TNumber;
var
	vNumber: TNumber;
	vNewNumbers: TNumberList;
	vMap: TAlmanacMap;
begin
	vNewNumbers := TNumberList.Create;

	for vMap in vMaps do begin
		for vNumber in vNumbers do
			vNewNumbers.Add(vMap.MapNumber(vNumber));

		vNumbers.Clear;
		vNumbers.AddList(vNewNumbers);
		vNewNumbers.Clear;
	end;

	vNewNumbers.Free;

	result := vNumbers[0];
	for vNumber in vNumbers do
		result := Min(result, vNumber);
end;

function PartTwo(vNumbers: TNumberList; vMaps: TAlmanacMapList): TNumber;
var
	vRange: TRange;
	vRanges: TRangeList;
	vNewRanges: TRangeList;
	vTmpRanges: TRangeList;
	vInd: Integer;
	vMap: TAlmanacMap;
begin
	vRanges := TRangeList.Create;
	vNewRanges := TRangeList.Create;

	for vInd := 0 to (vNumbers.Count div 2) - 1 do begin
		vRange.Lower := vNumbers[vInd * 2];
		vRange.Upper := vRange.Lower + vNumbers[vInd * 2 + 1] - 1;
		vRanges.Add(vRange);
	end;

	for vMap in vMaps do begin
		for vRange in vRanges do begin
			vTmpRanges := vMap.MapRanges(vRange);
			vNewRanges.AddList(vTmpRanges);
			vTmpRanges.Free;
		end;

		vRanges.Clear;
		vRanges.AddList(vNewRanges);
		vNewRanges.Clear;
	end;

	vNewRanges.Free;

	result := vRanges[0].Lower;
	for vRange in vRanges do
		result := Min(result, vRange.Lower);

	vRanges.Free;
end;

function RunPart(vPart: Integer; vInput: TStringList): String;
var
	vNumbers: TNumberList;
	vMaps: TAlmanacMapList;
begin
	vNumbers := TNumberList.Create;
	vMaps := TAlmanacMapList.Create;
	ParseInput(vInput, vNumbers, vMaps);

	case vPart of
		1: result := IntToStr(PartOne(vNumbers, vMaps));
		2: result := IntToStr(PartTwo(vNumbers, vMaps));
		else
			result := 'No such part number!';
	end;

	vNumbers.Free;
	vMaps.Free;
end;

class operator TRange.= (const vR1, vR2: TRange): Boolean;
begin
	result := (vR1.Lower = vR2.Lower) and (vR1.Upper = vR2.Upper);
end;

constructor TMapping.Create(const vRange: TRange; vTo: TNumber);
begin
	FRangeFrom := vRange;
	FBaseTo := vTo;
end;

function TMapping.TryMap(var vValue: TNumber): Boolean;
begin
	result := (vValue >= FRangeFrom.Lower) and (vValue <= FRangeFrom.Upper);
	if result then
		vValue := FBaseTo + (vValue - FRangeFrom.Lower);
end;

function TMapping.TryMapRange(vRange: TRange; vRangesMapped, vRangesUnmapped: TRangeList): Boolean;
var
	vNewRange: TRange;
begin
	result := (vRange.Lower <= FRangeFrom.Upper) and (vRange.Upper >= FRangeFrom.Lower);
	if not result then exit;

	if vRange.Lower < FRangeFrom.Lower then begin
		vNewRange.Lower := vRange.Lower;
		vNewRange.Upper := FRangeFrom.Lower - 1;
		vRangesUnmapped.Add(vNewRange);

		vRange.Lower := FRangeFrom.Lower;
	end;

	if vRange.Upper > FRangeFrom.Upper then begin
		vNewRange.Upper := vRange.Upper;
		vNewRange.Lower := FRangeFrom.Upper + 1;
		vRangesUnmapped.Add(vNewRange);

		vRange.Upper := FRangeFrom.Upper;
	end;

	vNewRange.Lower := FBaseTo + (vRange.Lower - FRangeFrom.Lower);
	vNewRange.Upper := FBaseTo + (vRange.Upper - FRangeFrom.Lower);
	vRangesMapped.Add(vNewRange);
end;

constructor TAlmanacMap.Create();
begin
	FMappings := TMappingList.Create;
end;

destructor TAlmanacMap.Destroy;
begin
	FMappings.Free;
end;

procedure TAlmanacMap.AddMapping(vTo, vFrom, vLength: TNumber);
var
	vRange: TRange;
begin
	vRange.Lower := vFrom;
	vRange.Upper := vFrom + vLength - 1;

	FMappings.Add(TMapping.Create(vRange, vTo));
end;

function TAlmanacMap.MapNumber(vValue: TNumber): TNumber;
var
	vMapping: TMapping;
begin
	result := vValue;
	for vMapping in FMappings do begin
		if vMapping.TryMap(result) then exit;
	end;
end;

function TAlmanacMap.MapRanges(vRange: TRange): TRangeList;
var
	vMapping: TMapping;
	vRanges: TRangeList;
	vNewRanges: TRangeList;
begin
	result := TRangeList.Create;
	vRanges := TRangeList.Create;
	vNewRanges := TRangeList.Create;
	vRanges.Add(vRange);

	for vMapping in FMappings do begin
		for vRange in vRanges do begin
			if not vMapping.TryMapRange(vRange, result, vNewRanges) then
				vNewRanges.Add(vRange);
		end;

		vRanges.Clear;
		vRanges.AddList(vNewRanges);
		vNewRanges.Clear;
	end;

	result.AddList(vRanges);
	vRanges.Free;
	vNewRanges.Free;
end;

end.

