codeunit 50100 "Object Reservation Mgmt. TAL"
{
    procedure ReleaseField(var ReservedField: Record "Reserved Field TAL")
    begin
        ReservedField.DeleteAll();
    end;

    procedure ReleaseObject(var ReservedObject: Record "Reserved Object TAL")
    var
        ReservedField: Record "Reserved Field TAL";
    begin
        if ReservedObject.FindSet() then
            repeat
                ReservedField.SetRange("Object Type", ReservedObject."Object Type");
                ReservedField.SetRange("Object ID", ReservedObject."Object ID");
                ReleaseField(ReservedField);
            until ReservedObject.Next() = 0;
        ReservedObject.DeleteAll();
    end;

    procedure ReserveJournal(var ObjectReservationJnlLine: Record ObjectReservationJnlLineTAL)
    var
        ReservedObject: Record "Reserved Object TAL";
    begin
        if ObjectReservationJnlLine.FindSet() then begin
            repeat
                ReservedObject.Init();
                ReservedObject.TransferFields(ObjectReservationJnlLine);
                ReservedObject.Insert();
            until ObjectReservationJnlLine.Next() = 0;
            ReserveFields(ObjectReservationJnlLine."Project Code");
            ObjectReservationJnlLine.DeleteAll();
            Message(ObjectsReservedLbl);
        end else
            Error(NothingToReserveLbl);
    end;


    local procedure ReserveFields(BatchName: Code[20])
    var
        ReservedField: Record "Reserved Field TAL";
        FieldReservationJnlLine: Record FieldReservationJnlLineTAL;
    begin
        FieldReservationJnlLine.SetRange("Project Code", BatchName);
        if FieldReservationJnlLine.FindSet() then
            repeat
                ReservedField.Init();
                ReservedField.TransferFields(FieldReservationJnlLine);
                ReservedField.Insert();
            until FieldReservationJnlLine.Next() = 0;
        FieldReservationJnlLine.DeleteAll();
    end;

    procedure SetName(BatchName: Code[20]; var ObjectReservJnlLine: Record ObjectReservationJnlLineTAL)
    begin
        ObjectReservJnlLine.FilterGroup := 2;
        ObjectReservJnlLine.SetRange("Project Code", BatchName);
        ObjectReservJnlLine.FilterGroup := 0;
        if ObjectReservJnlLine.FindSet() then;
    end;

    procedure IsIdValid(Id: Integer): Boolean
    begin
        if (Id <= 0) or (Id > 74999999) then
            Error(IdNotValidErr);
        exit(true);
    end;

    procedure ValidateObjectID(ObjectType: Enum "Object Type TAL"; ObjectID: Integer)
    begin
        if not CheckObjectIDAvailability(ObjectType, ObjectID) then
            Error(ObjectIdNotAvailableLbl, ObjectID);
    end;

    procedure ValidateObjectName(ObjectType: Enum "Object Type TAL"; ObjectName: Text[30])
    begin
        if not CheckObjectNameAvailability(ObjectType, ObjectName) then
            Error(ObjectNameNotAvailableLbl, ObjectName);

    end;

    procedure SuggestObjects(ObjectsArray: array[12] of Integer; StartId: Integer; EndId: Integer): Integer
    var
        Counter: Integer;
        maxValue: Integer;
    begin
        maxValue := 0;
        for Counter := 1 to System.ArrayLen(ObjectsArray) do
            if ObjectsArray[Counter] > maxValue then
                maxValue := ObjectsArray[Counter];

        if not CheckObjectRangeAvailability(maxValue, StartId, EndId) then
            Error(CouldnotSuggestErr)
        else
            exit(StartingIDtoReserve);
    end;

    local procedure CheckObjectRangeAvailability(ObjectCount: Integer; StartId: Integer; EndId: Integer): Boolean
    var
        counter: Integer;
        counter1: Integer;
        ObjectAvailable: Boolean;
    begin
        for counter := StartId to (EndId - ObjectCount) do begin
            for counter1 := counter to (counter + ObjectCount) do begin
                ObjectAvailable := CheckObjectAvailability(counter1);
                if not ObjectAvailable then begin
                    counter := counter1;
                    break;
                end;
            end;
            if ObjectAvailable then begin
                StartingIDtoReserve := counter;
                exit(true);
            end;
        end;
        exit(ObjectAvailable);
    end;

    local procedure CheckObjectAvailability(ObjectId: Integer): Boolean
    var
        ReservedObject: Record "Reserved Object TAL";
        ObjectReservationJnlLine: Record ObjectReservationJnlLineTAL;
        AllObject: Record AllObjWithCaption;

    begin
        ReservedObject.SetRange("Object ID", ObjectId);
        if not ReservedObject.IsEmpty() then
            exit(false);
        ObjectReservationJnlLine.SetRange("Object ID", ObjectId);
        if not ObjectReservationJnlLine.IsEmpty() then
            exit(false);
        AllObject.SetRange("Object ID", ObjectId);
        if not AllObject.IsEmpty() then
            exit(false);
        exit(true);
    end;

    procedure CheckObjectIDAvailability(ObjectType: Enum "Object Type TAL"; ObjectId: Integer): Boolean
    var
        ReservedObject: Record "Reserved Object TAL";
        ObjectReservationJnlLine: Record ObjectReservationJnlLineTAL;
        AllObject: Record AllObjWithCaption;

    begin
        ReservedObject.SetRange("Object Type", ObjectType);
        ReservedObject.SetRange("Object ID", ObjectId);
        if not ReservedObject.IsEmpty() then
            exit(false);
        ObjectReservationJnlLine.SetRange("Object Type", ObjectType);
        ObjectReservationJnlLine.SetRange("Object ID", ObjectId);
        if not ObjectReservationJnlLine.IsEmpty() then
            exit(false);
        AllObject.SetRange("Object Type", ObjectType);
        AllObject.SetRange("Object ID", ObjectId);
        if not AllObject.IsEmpty() then
            exit(false);

        exit(true);
    end;

    procedure CheckObjectNameAvailability(ObjectType: Enum "Object Type TAL"; ObjectName: Text[30]): Boolean
    var
        ReservedObject: Record "Reserved Object TAL";
        ObjectReservationJnlLine: Record ObjectReservationJnlLineTAL;
        AllObject: Record AllObjWithCaption;

    begin
        ReservedObject.SetRange("Object Type", ObjectType);
        ReservedObject.SetRange("Object Name", ObjectName);
        if not ReservedObject.IsEmpty() then
            exit(false);
        ObjectReservationJnlLine.SetRange("Object Name", ObjectName);
        if not ObjectReservationJnlLine.IsEmpty() then
            exit(false);
        AllObject.SetRange("Object Type", ObjectType);
        AllObject.SetRange("Object Name", ObjectName);
        if not AllObject.IsEmpty() then
            exit(false);

        exit(true);
    end;

    var
        StartingIDtoReserve: Integer;
        CouldnotSuggestErr: Label 'Could not suggest the object IDs', MaxLength = 30;
        ObjectIdNotAvailableLbl: Label 'Object Id %1 is not available', Comment = '%1 = Object Id', MaxLength = 50;
        ObjectNameNotAvailableLbl: Label 'Object Name %1 is not available', Comment = '%1 = Object Name', MaxLength = 30;
        NothingToReserveLbl: Label 'No lines to reserve', MaxLength = 30;
        ObjectsReservedLbl: Label 'Objects Reserved', MaxLength = 20;
        IdNotValidErr: Label 'ID is not valid', MaxLength = 20;

}