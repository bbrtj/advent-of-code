unit Day5;

{$mode objfpc}{$H+}{$J-}

interface

uses SysUtils, Classes, Math, GContainers;

function RunPart(Part: Integer; InputData: TStringList): String;

type
	TNumber = Int64;

	TRange = class
		Lower: TNumber;
		Upper: TNumber;

		constructor Create(const aLower, aUpper: TNumber);
	end;

	TRangeList = specialize TCustomObjectList<TRange>;

	TMapping = class
	strict private
		FRangeFrom: TRange;
		FBaseTo: TNumber;

	public
		constructor Create(aLower, aUpper, MapTo: TNumber);
		destructor Destroy; override;

		function TryMap(var Value: TNumber): Boolean;
		function TryMapRange(Range: TRange; RangesMapped, RangesUnmapped: TRangeList): Boolean;
	end;

	TMappingList = specialize TCustomObjectList<TMapping>;
	TNumberList = specialize TCustomList<TNumber>;

	TAlmanacMap = class
	strict private
		FMappings: TMappingList;

	public
		constructor Create();
		destructor Destroy; override;

		procedure AddMapping(MapTo, MapFrom, MapLength: TNumber);
		function MapNumber(Value: TNumber): TNumber;
		procedure MapRanges(Range: TRange; RangeList: TRangeList);
	end;

	TAlmanacMapList = specialize TCustomObjectList<TAlmanacMap>;

implementation

procedure ParseInput(InputData: TStringList; var Numbers: TNumberList; var Maps: TAlmanacMapList);
var
	lLine: String;
	lSplit: TStringArray;
	lLastMap: TAlmanacMap;
	i: Integer;
begin
	for lLine in InputData do begin
		if Length(lLine) = 0 then
			continue;

		if lLine.StartsWith('seeds:') then begin
			lSplit := copy(lLine, 8).Split([' ']);
			for i := Low(lSplit) to High(lSplit) do
				Numbers.Add(StrToInt64(lSplit[i]));
		end

		else if lLine[1] in ['0' .. '9'] then begin
			lSplit := lLine.Split([' ']);
			lLastMap.AddMapping(
				StrToInt64(lSplit[0]),
				StrToInt64(lSplit[1]),
				StrToInt64(lSplit[2])
			);
		end

		else begin
			lLastMap := TAlmanacMap.Create;
			Maps.Add(lLastMap);
		end;
	end;
end;

function PartOne(Numbers: TNumberList; Maps: TAlmanacMapList): TNumber;
var
	lMap: TAlmanacMap;
	lNumbers: TNumberList;
	lNewNumbers: TNumberList;
	i: Integer;
begin
	lNumbers := TNumberList.Create;
	lNewNumbers := TNumberList.Create;

	lNumbers.AddList(Numbers);

	for lMap in Maps do begin
		for i := 0 to lNumbers.Count - 1 do
			lNewNumbers.Add(lMap.MapNumber(lNumbers[i]));

		lNumbers.Assign(lNewNumbers);
		lNewNumbers.Clear;
	end;

	lNewNumbers.Free;

	result := lNumbers[0];
	for i := 0 to lNumbers.Count - 1 do
		result := Min(result, lNumbers[i]);

	lNumbers.Free;
end;

function PartTwo(Numbers: TNumberList; Maps: TAlmanacMapList): TNumber;
var
	lMap: TAlmanacMap;
	lRanges: TRangeList;
	lNewRanges: TRangeList;
	i: Integer;
begin
	lRanges := TRangeList.Create(False);
	lNewRanges := TRangeList.Create(False);

	for i := 0 to (Numbers.Count div 2) - 1 do begin
		lRanges.Add(TRange.Create(
			Numbers[i * 2],
			Numbers[i * 2] + Numbers[i * 2 + 1] - 1)
		);
	end;

	for lMap in Maps do begin
		for i := 0 to lRanges.Count - 1 do begin
			lMap.MapRanges(lRanges[i], lNewRanges);
		end;

		lRanges.Assign(lNewRanges);
		lNewRanges.Clear;
	end;

	lNewRanges.Free;

	result := lRanges[0].Lower;
	for i := 0 to lRanges.Count - 1 do
		result := Min(result, lRanges[i].Lower);

	lRanges.FreeObjects := True;
	lRanges.Free;
end;

function RunPart(Part: Integer; InputData: TStringList): String;
var
	lNumbers: TNumberList;
	lMaps: TAlmanacMapList;
begin
	lNumbers := TNumberList.Create;
	lMaps := TAlmanacMapList.Create;
	ParseInput(InputData, lNumbers, lMaps);

	case Part of
		1: result := IntToStr(PartOne(lNumbers, lMaps));
		2: result := IntToStr(PartTwo(lNumbers, lMaps));
		else
			result := 'No such part number!';
	end;

	lNumbers.Free;
	lMaps.Free;
end;

constructor TRange.Create(const aLower, aUpper: TNumber);
begin
	self.Lower := aLower;
	self.Upper := aUpper;
end;

constructor TMapping.Create(aLower, aUpper, MapTo: TNumber);
begin
	FRangeFrom := TRange.Create(aLower, aUpper);
	FBaseTo := MapTo;
end;

destructor TMapping.Destroy;
begin
	FRangeFrom.Free;
	inherited;
end;

function TMapping.TryMap(var Value: TNumber): Boolean;
begin
	result := (Value >= FRangeFrom.Lower) and (Value <= FRangeFrom.Upper);
	if result then
		Value := FBaseTo + (Value - FRangeFrom.Lower);
end;

function TMapping.TryMapRange(Range: TRange; RangesMapped, RangesUnmapped: TRangeList): Boolean;
begin
	result := (Range.Lower <= FRangeFrom.Upper) and (Range.Upper >= FRangeFrom.Lower);
	if not result then exit;

	if Range.Lower < FRangeFrom.Lower then begin
		RangesUnmapped.Add(TRange.Create(Range.Lower, FRangeFrom.Lower - 1));

		Range.Lower := FRangeFrom.Lower;
	end;

	if Range.Upper > FRangeFrom.Upper then begin
		RangesUnmapped.Add(TRange.Create(FRangeFrom.Upper + 1, Range.Upper));

		Range.Upper := FRangeFrom.Upper;
	end;

	Range.Lower := FBaseTo + (Range.Lower - FRangeFrom.Lower);
	Range.Upper := FBaseTo + (Range.Upper - FRangeFrom.Lower);
	RangesMapped.Add(Range);
end;

constructor TAlmanacMap.Create();
begin
	FMappings := TMappingList.Create;
end;

destructor TAlmanacMap.Destroy;
begin
	FMappings.Free;
end;

procedure TAlmanacMap.AddMapping(MapTo, MapFrom, MapLength: TNumber);
begin
	FMappings.Add(TMapping.Create(MapFrom, MapFrom + MapLength - 1, MapTo));
end;

function TAlmanacMap.MapNumber(Value: TNumber): TNumber;
var
	i: Integer;
begin
	result := Value;
	for i := 0 to FMappings.Count - 1 do begin
		if FMappings[i].TryMap(result) then exit;
	end;
end;

procedure TAlmanacMap.MapRanges(Range: TRange; RangeList: TRangeList);
var
	lRanges: TRangeList;
	lNewRanges: TRangeList;
	i, j: Integer;
begin
	lRanges := TRangeList.Create(False);
	lNewRanges := TRangeList.Create(False);
	lRanges.Add(Range);

	for i := 0 to FMappings.Count - 1 do begin
		for j := 0 to lRanges.Count - 1 do begin
			if not FMappings[i].TryMapRange(lRanges[j], RangeList, lNewRanges) then
				lNewRanges.Add(lRanges[j]);
		end;

		lRanges.Assign(lNewRanges);
		lNewRanges.Clear;
	end;

	RangeList.AddList(lRanges);
	lRanges.Free;
	lNewRanges.Free;
end;

end.

