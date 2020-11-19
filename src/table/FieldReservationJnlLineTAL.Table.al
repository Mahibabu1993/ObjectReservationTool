table 50104 "FieldReservationJnlLineTAL"
{
    Caption = 'Field Reservation Journal Line';
    DataClassification = CustomerContent;
    LookupPageId = "Field Reserv. Jnl Line TAL";
    DrillDownPageId = "Field Reserv. Jnl Line TAL";

    fields
    {
        field(1; "Batch Name"; Code[20])
        {
            Caption = 'Batch Name';
            DataClassification = CustomerContent;
        }
        field(2; "Object Type"; Enum "Object Type TAL")
        {
            Caption = 'Object Type';
            DataClassification = CustomerContent;
        }
        field(3; "Object ID"; Integer)
        {
            Caption = 'Object ID';
            DataClassification = CustomerContent;
        }
        field(4; "Field ID"; Integer)
        {
            Caption = 'Field ID';
            DataClassification = CustomerContent;
        }
        field(5; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            DataClassification = CustomerContent;
        }
        field(6; "Reserved By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(7; "Reserved Date"; DateTime)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Batch Name", "Object Type", "Object ID", "Field ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Reserved By" := format(UserId);
        "Reserved Date" := CurrentDateTime;
    end;
}