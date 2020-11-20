page 50102 "Object Reserv. Jnl Batch TAL"
{
    Caption = 'Object Reservation Journal Batches';
    PageType = List;
    SourceTable = "ObjectReservationJnlBatchTAL";
    layout
    {

        area(content)
        {
            repeater(Group)
            {

                field("Name"; Rec."Name")
                {
                    ApplicationArea = ObjectReservationAppAreaTAL;
                    Tooltip = 'Specifies the Name.';
                }

                field("Description"; Rec."Description")
                {
                    ApplicationArea = ObjectReservationAppAreaTAL;
                    Tooltip = 'Specifies the Description.';
                }

                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = ObjectReservationAppAreaTAL;
                    Tooltip = 'Specifies the Assigned User ID".';
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Ëdit Journal")
            {
                Caption = 'Édit Journal';
                ApplicationArea = ObjectReservationAppAreaTAL;
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';
                ToolTip = 'Open a journal based on the journal batch.';
                trigger onAction()
                var
                    ObjectReservationJnlLine: Record ObjectReservationJnlLineTAL;
                begin
                    ObjectReservationJnlLine.FilterGroup := 2;
                    ObjectReservationJnlLine.SetRange("Batch Name", Rec.Name);
                    ObjectReservationJnlLine.FilterGroup := 0;
                    ObjectReservationJnlLine."Batch Name" := Rec.Name;

                    Page.Run(0, ObjectReservationJnlLine);
                end;
            }
        }
    }
    trigger OnDeleteRecord(): Boolean
    begin
        if not Confirm(StrSubstNo(ConfirmBatchDeleteLbl, Rec.Name), true) then
            exit(false);
    end;

    var
        ConfirmBatchDeleteLbl: Label 'This will delete the Object Reservation Journal Lines associated to Batch %1', Comment = '%1 = Batch Name', MaxLength = 80;

}