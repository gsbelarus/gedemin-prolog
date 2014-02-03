object gdc_dlgUserComplexDocument147020774_119619099: Tgdc_dlgUserComplexDocument
  Left = -8
  Top = -8
  Width = 1382
  Height = 744
  ActiveControl = nil
  PixelsPerInch = 96
  TextHeight = 13
  object btnAccess: TButton
    Top = 682
    TabOrder = 3
  end
  object btnNew: TButton
    Top = 682
    TabOrder = 4
  end
  object btnHelp: TButton
    Top = 682
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 268
    Top = 682
    Anchors = [akLeft, akBottom]
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 360
    Top = 682
    Anchors = [akLeft, akBottom]
    TabOrder = 2
  end
  object pnlMain: TPanel
    Width = 1366
    Height = 679
    TabOrder = 0
    object splMain: TSplitter
      Width = 1366
    end
    object usrg_Splitter1: TSplitter
      Tag = 0
      Left = 583
      Top = 302
      Width = 6
      Height = 377
      Cursor = crHSplit
      Hint = ''
      Align = alLeft
      AutoSnap = True
      Beveled = False
      Constraints.MaxHeight = 0
      Constraints.MaxWidth = 0
      Constraints.MinHeight = 0
      Constraints.MinWidth = 0
      MinSize = 30
      ParentColor = True
      ResizeStyle = rsPattern
      Visible = True
    end
    object pnlDetail: TPanel
      Left = 0
      Top = 302
      Width = 583
      Height = 377
      Align = alLeft
      Alignment = taLeftJustify
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 2
      object ibgrDetail: TgsIBGrid
        Left = 0
        Width = 583
        Height = 351
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        Expands = <>
        Conditions = <>
        MinColWidth = 6
        ColumnEditors = <>
        Aliases = <>
        Columns = <
          item
            Expanded = False
            FieldName = 'USR$ACCDATE'
            Title.Caption = 'Дата начисления'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'USR$INCLUDEDATE'
            Title.Caption = 'Дата зачисления'
            Width = 100
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$DURATION'
            Title.Caption = 'Дни'
            Width = 45
            Visible = True
            TotalType = ttSum
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$SUMMA'
            Title.Caption = 'Сумма'
            Width = 89
            Visible = True
            DisplayFormat = '#.##'
            TotalType = ttSum
          end
          item
            Expanded = False
            FieldName = 'USR$DATEBEGIN'
            Title.Caption = 'Дата начала'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'USR$DATEEND'
            Title.Caption = 'Дата окончания'
            Width = 131
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'SUMNCU'
            Title.Caption = 'sumncu'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DOCUMENTDATE'
            Title.Caption = 'Дата'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DESCRIPTION'
            Title.Caption = 'Описание'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'USR$SORTNUMBER'
            ReadOnly = False
            Title.Caption = 'Номер для сортировки'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'ID'
            Title.Caption = 'Ключ'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'PARENT'
            Title.Caption = 'Родитель'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DOCUMENTTYPEKEY'
            Title.Caption = 'Тип документа'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'TRTYPEKEY'
            Title.Caption = 'Тип транзакции'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'TRANSACTIONKEY'
            Title.Caption = 'Транзакция'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'NUMBER'
            Title.Caption = 'Номер'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'SUMCURR'
            Title.Caption = 'Сумма в валюте'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DELAYED'
            Title.Caption = 'Отложенный'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CURRKEY'
            Title.Caption = 'Валюта'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'COMPANYKEY'
            Title.Caption = 'Компания'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CREATORKEY'
            Title.Caption = 'Кто создал'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'CREATIONDATE'
            Title.Caption = 'Дата создания'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'EDITORKEY'
            Title.Caption = 'Кто исправил'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'EDITIONDATE'
            Title.Caption = 'Дата изменения'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'PRINTDATE'
            Title.Caption = 'Дата печати'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DISABLED'
            Title.Caption = 'Отключено'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'RESERVED'
            Title.Caption = 'Зарезервировано'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'DOCUMENTKEY'
            ReadOnly = True
            Title.Caption = 'Ключ документа'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'MASTERKEY'
            ReadOnly = True
            Title.Caption = 'Родитель (Начисление отпусков(позиция))'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'RESERVED1'
            ReadOnly = True
            Title.Caption = 'Зарезервировано (Начисление отпусков(позиция))'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'SUMEQ'
            Title.Caption = 'Сумма в эквиваленте'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'USR$EQRATE'
            Title.Caption = 'Курс экв.'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'AFULL'
            Title.Caption = 'Полный доступ'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'ACHAG'
            Title.Caption = 'Просмотр и редактирование'
            Width = -1
            Visible = False
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'AVIEW'
            Title.Caption = 'Только просмотр'
            Width = -1
            Visible = False
          end>
      end
      object tbdTop: TTBDock
        Width = 583
        object tbDetail: TTBToolbar
          Align = alClient
          Anchors = [akLeft, akTop, akRight, akBottom]
          DockPos = 0
          SavedAtRunTime = True
          object tbNew: TTBItem
          end
          object tbEdit: TTBItem
          end
          object tbDelete: TTBItem
          end
          object tbDuplicate: TTBItem
          end
          object tbiDetailProperties: TTBItem
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object tbCopy: TTBItem
          end
          object tbCut: TTBItem
          end
          object tbPaste: TTBItem
          end
          object TBSeparatorItem2: TTBSeparatorItem
          end
          object tbMacro: TTBItem
          end
          object usrg_TBSeparatorItem1: TTBSeparatorItem
            Tag = 0
            Blank = False
            Hint = ''
            Visible = True
          end
          object usrg_TBItem6: TTBItem
            Tag = 0
            Action = usrg_actGenerate
            AutoCheck = False
            DisplayMode = nbdmDefault
            GroupIndex = 0
            Images = nil
            InheritOptions = True
            MaskOptions = []
            Options = []
            RadioItem = False
          end
          object usrg_TBItem1: TTBItem
            Tag = 0
            Action = usrg_actGenStr
            AutoCheck = False
            DisplayMode = nbdmDefault
            GroupIndex = 0
            Images = nil
            InheritOptions = True
            MaskOptions = []
            Options = []
            RadioItem = False
          end
          object usrg_tbFeesByEmpl: TTBItem
            Tag = 0
            Action = nil
            AutoCheck = False
            Caption = 'Итоговое'
            Checked = False
            DisplayMode = nbdmDefault
            Enabled = True
            GroupIndex = 0
            HelpContext = 0
            Hint = ''
            ImageIndex = -1
            Images = nil
            InheritOptions = True
            MaskOptions = []
            Options = []
            RadioItem = False
            ShortCut = 0
            Visible = True
          end
        end
      end
      object tbdLeft: TTBDock
        Left = 0
        Width = 0
        Height = 351
      end
      object tbdRight: TTBDock
        Left = 583
        Width = 0
        Height = 351
      end
      object tbdBottom: TTBDock
        Top = 377
        Width = 583
        Height = 0
      end
    end
    object pnlMaster: TPanel
      Width = 1366
      TabOrder = 0
      object pnlHolding: TPanel
        Width = 1366
        TabOrder = 1
        object lblCompany: TLabel
          Width = 64
          Caption = 'Органзация:'
        end
        object iblkCompany: TgsIBLookupComboBox
        end
      end
      object usrg_PageControl1: TPageControl
        Tag = 0
        Left = 0
        Top = 0
        Width = 1366
        Height = 298
        Cursor = crDefault
        Hint = ''
        HelpContext = 0
        ActivePage = usrg_TabSheet1
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        Constraints.MaxHeight = 0
        Constraints.MaxWidth = 0
        Constraints.MinHeight = 0
        Constraints.MinWidth = 0
        DockSite = False
        DragCursor = crDrag
        DragKind = dkDrag
        DragMode = dmManual
        Enabled = True
        HotTrack = False
        Images = nil
        MultiLine = False
        OwnerDraw = False
        ParentBiDiMode = True
        ParentFont = True
        ParentShowHint = True
        PopupMenu = nil
        RaggedRight = False
        ScrollOpposite = False
        Style = tsTabs
        TabHeight = 0
        TabOrder = 0
        TabPosition = tpTop
        TabStop = True
        TabWidth = 0
        Visible = True
        object usrg_TabSheet1: TTabSheet
          Tag = 0
          Cursor = crDefault
          Hint = ''
          HelpContext = 0
          BorderWidth = 0
          Caption = 'Основные'
          DragMode = dmManual
          Enabled = True
          Highlighted = False
          ImageIndex = 0
          Constraints.MaxHeight = 0
          Constraints.MaxWidth = 0
          Constraints.MinHeight = 0
          Constraints.MinWidth = 0
          ParentFont = True
          ParentShowHint = True
          PopupMenu = nil
          TabVisible = True
          object usrg_GroupBox1: TGroupBox
            Tag = 0
            Left = 0
            Top = 121
            Width = 1358
            Height = 149
            Cursor = crDefault
            Hint = ''
            HelpContext = 0
            Align = alClient
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Средний заработок '
            Constraints.MaxHeight = 0
            Constraints.MaxWidth = 0
            Constraints.MinHeight = 0
            Constraints.MinWidth = 0
            DockSite = False
            DragCursor = crDrag
            DragKind = dkDrag
            DragMode = dmManual
            Enabled = True
            ParentBiDiMode = True
            ParentColor = True
            ParentCtl3D = True
            ParentFont = True
            ParentShowHint = True
            PopupMenu = nil
            TabOrder = 0
            TabStop = False
            Visible = True
            object usrat_DBEdit_USR_AVGPERIOD_Label: TLabel
              Left = 13
              Top = 44
            end
            object usrat_gsIBLookupComboBox_USR_FEEGROUPKEY_Label: TLabel
              Left = 13
              Top = 20
            end
            object usrat_DBEdit_USR_AVGSUMMA_Label: TLabel
              Left = 14
              Top = 69
            end
            object usrat_DBEdit_USR_MATSUMM_Label: TLabel
              Left = 13
              Top = 94
            end
            object usrg_chboxCoefInflation: TCheckBox
              Tag = 0
              Left = 677
              Top = 51
              Width = 225
              Height = 17
              Cursor = crDefault
              Hint = ''
              HelpContext = 0
              TabStop = True
              Action = nil
              Alignment = taRightJustify
              AllowGrayed = False
              Anchors = [akLeft, akTop]
              Caption = 'Коэ-т инфляции от ставки 1 разряда'
              Checked = True
              Constraints.MaxHeight = 0
              Constraints.MaxWidth = 0
              Constraints.MinHeight = 0
              Constraints.MinWidth = 0
              DragCursor = crDrag
              DragKind = dkDrag
              DragMode = dmManual
              Enabled = True
              ParentBiDiMode = True
              ParentColor = True
              ParentCtl3D = True
              ParentFont = True
              ParentShowHint = True
              PopupMenu = nil
              State = cbChecked
              TabOrder = 4
              Visible = False
            end
            object usrg_GroupBox2: TGroupBox
              Tag = 0
              Left = 349
              Top = 10
              Width = 289
              Height = 77
              Cursor = crDefault
              Hint = ''
              HelpContext = 0
              Align = alNone
              Anchors = [akLeft, akTop]
              Caption = 'Осовременивание'
              Constraints.MaxHeight = 0
              Constraints.MaxWidth = 0
              Constraints.MinHeight = 0
              Constraints.MinWidth = 0
              DockSite = False
              DragCursor = crDrag
              DragKind = dkDrag
              DragMode = dmManual
              Enabled = True
              ParentBiDiMode = True
              ParentColor = True
              ParentCtl3D = True
              ParentFont = True
              ParentShowHint = True
              PopupMenu = nil
              TabOrder = 5
              TabStop = False
              Visible = True
              object usrg_rbSalaryInf: TRadioButton
                Tag = 0
                Left = 12
                Top = 17
                Width = 169
                Height = 17
                Cursor = crDefault
                Hint = ''
                HelpContext = 0
                Action = nil
                Alignment = taRightJustify
                Anchors = [akLeft, akTop]
                Caption = 'От оклада'
                Checked = False
                Constraints.MaxHeight = 0
                Constraints.MaxWidth = 0
                Constraints.MinHeight = 0
                Constraints.MinWidth = 0
                DragCursor = crDrag
                DragKind = dkDrag
                DragMode = dmManual
                Enabled = True
                ParentBiDiMode = True
                ParentColor = True
                ParentCtl3D = True
                ParentFont = True
                ParentShowHint = True
                PopupMenu = nil
                TabOrder = 0
                TabStop = False
                Visible = True
              end
              object usrg_rbRateInf: TRadioButton
                Tag = 0
                Left = 12
                Top = 36
                Width = 169
                Height = 17
                Cursor = crDefault
                Hint = ''
                HelpContext = 0
                Action = nil
                Alignment = taRightJustify
                Anchors = [akLeft, akTop]
                Caption = 'От ставки 1-го разряда'
                Checked = True
                Constraints.MaxHeight = 0
                Constraints.MaxWidth = 0
                Constraints.MinHeight = 0
                Constraints.MinWidth = 0
                DragCursor = crDrag
                DragKind = dkDrag
                DragMode = dmManual
                Enabled = True
                ParentBiDiMode = True
                ParentColor = True
                ParentCtl3D = True
                ParentFont = True
                ParentShowHint = True
                PopupMenu = nil
                TabOrder = 1
                TabStop = True
                Visible = True
              end
              object usrg_rbPersCoeffInf: TRadioButton
                Tag = 0
                Left = 12
                Top = 55
                Width = 241
                Height = 17
                Cursor = crDefault
                Hint = ''
                HelpContext = 0
                Action = nil
                Alignment = taRightJustify
                Anchors = [akLeft, akTop]
                Caption = 'От персонального коэффициента'
                Checked = False
                Constraints.MaxHeight = 0
                Constraints.MaxWidth = 0
                Constraints.MinHeight = 0
                Constraints.MinWidth = 0
                DragCursor = crDrag
                DragKind = dkDrag
                DragMode = dmManual
                Enabled = True
                ParentBiDiMode = True
                ParentColor = True
                ParentCtl3D = True
                ParentFont = True
                ParentShowHint = True
                PopupMenu = nil
                TabOrder = 2
                TabStop = False
                Visible = True
              end
            end
            object usrat_DBEdit_USR_AVGPERIOD: TxDBCalculatorEdit
              Left = 243
              Top = 40
              Width = 76
              Cursor = crIBeam
              TabOrder = 1
            end
            object usrat_gsIBLookupComboBox_USR_FEEGROUPKEY: TgsIBLookupComboBox
              Left = 139
              Top = 16
              Width = 180
              ListTable = 
                'USR$WG_FEEGROUP fg LEFT JOIN USR$WG_FEEGROUP fg1 ON fg.lb > fg1.' +
                'lb AND fg.rb < fg1.rb'
              Condition = 'fg1.id = <RUID XID = 147274328 DBID = 274788016/>'
              TabOrder = 0
            end
            object usrat_DBCheckBox_USR_MODERNSALARY: TDBCheckBox
              Left = 677
              Top = 19
              Width = 106
              Caption = 'Осовременивать'
              TabOrder = 2
              Visible = False
            end
            object usrat_DBEdit_USR_AVGSUMMA: TxDBCalculatorEdit
              Left = 179
              Top = 65
              Cursor = crIBeam
              TabOrder = 3
            end
            object usrat_DBEdit_USR_MATSUMM: TxDBCalculatorEdit
              Left = 180
              Top = 92
              Cursor = crIBeam
              BiDiMode = bdLeftToRight
              ParentBiDiMode = False
              TabOrder = 6
            end
          end
          object usrg_Panel1: TPanel
            Tag = 0
            Left = 0
            Top = 0
            Width = 1358
            Height = 121
            Cursor = crDefault
            Hint = ''
            HelpContext = 0
            Align = alTop
            Alignment = taCenter
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            BevelInner = bvRaised
            BevelOuter = bvLowered
            BevelWidth = 1
            BorderWidth = 0
            BorderStyle = bsNone
            Caption = ''
            Color = clBtnFace
            Constraints.MaxHeight = 0
            Constraints.MaxWidth = 0
            Constraints.MinHeight = 0
            Constraints.MinWidth = 0
            UseDockManager = True
            DockSite = False
            DragCursor = crDrag
            DragKind = dkDrag
            DragMode = dmManual
            Enabled = True
            FullRepaint = True
            Locked = False
            ParentBiDiMode = True
            ParentColor = False
            ParentCtl3D = True
            ParentFont = True
            ParentShowHint = True
            PopupMenu = nil
            TabOrder = 1
            TabStop = False
            Visible = True
            object usrat_gsIBLookupComboBox_USR_TOTALDOCKEY_Label: TLabel
              Top = 12
            end
            object usrat_gsIBLookupComboBox_USR_EMPLKEY_Label: TLabel
              Top = 37
            end
            object usrat_gsIBLookupComboBox_USR_VACATIONTYPE_Label: TLabel
              Top = 62
            end
            object usrat_gsIBLookupComboBox_USR_FIRSTMOVEKEY_Label: TLabel
              Left = 5
              Top = 87
              Width = 76
              Caption = 'По должности:'
            end
            object usrat_xDateDBEdit_USR_DATEEND_Label: TLabel
              Left = 317
              Top = 62
            end
            object usrat_xDateDBEdit_USR_DATEBEGIN_Label: TLabel
              Left = 317
              Top = 37
            end
            object usrat_xDateDBEdit_USR_FROM_Label: TLabel
              Left = 317
              Top = 11
            end
            object usrat_DBEdit_USR_DURATION_Label: TLabel
              Left = 501
              Top = 12
            end
            object usrat_DBEdit_USR_EXTRADURATION_Label: TLabel
              Left = 501
              Top = 36
            end
            object usrat_gsIBLookupComboBox_USR_TOTALDOCKEY: TgsIBLookupComboBox
              Left = 100
              Top = 8
              Width = 180
              ListTable = 
                'usr$wg_total t LEFT JOIN GD_DOCUMENT doc ON doc.id = t.documentk' +
                'ey'
              ListField = 'usr$name'
              KeyField = 'documentkey'
              SortOrder = soAsc
              Condition = 'parent is null and doc.companykey = <companykey/>'
              gdClassName = 'TgdcUserDocument'
              SubType = '147567052_119619099'
              DropDownCount = 8
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
            end
            object usrat_gsIBLookupComboBox_USR_EMPLKEY: TgsIBLookupComboBox
              Left = 100
              Top = 33
              Width = 180
              SortOrder = soAsc
              Condition = 
                'ID in (SELECT usr$emplkey FROM usr$wg_emplworkterm term LEFT JOI' +
                'N GD_DOCUMENT doc ON doc.id = term.usr$firstmovekey WHERE usr$da' +
                'tebegin <= :dateend AND (usr$dateend >= :datebegin or usr$dateen' +
                'd is NULL) AND doc.companykey = <COMPANYKEY/>)'
              SubType = ''
              TabOrder = 1
            end
            object usrat_gsIBLookupComboBox_USR_VACATIONTYPE: TgsIBLookupComboBox
              Left = 100
              Top = 58
              Width = 180
              Condition = 'USR$TYPE <> 3'
              TabOrder = 2
            end
            object usrat_gsIBLookupComboBox_USR_FIRSTMOVEKEY: TgsIBLookupComboBox
              Left = 100
              Top = 83
              Width = 180
              Fields = 'l.POSNAME, l.DEPTNAME, l.KINDOFWORKNAME'
              ListTable = 'USR$WG_P_FMKLOOKUPSETTINGS (:emplkey, :dateend)  l'
              ListField = 'l.POSID'
              KeyField = 'l.FMK'
              Condition = ''
              gdClassName = ''
              ParentShowHint = False
              ShowHint = True
              TabOrder = 3
            end
            object usrat_DBCheckBox_USR_COMPENSATION: TDBCheckBox
              Left = 317
              Top = 87
              TabOrder = 4
            end
            object usrat_xDateDBEdit_USR_FROM: TxDateDBEdit
              Left = 411
              Top = 8
              Width = 68
              TabOrder = 5
            end
            object usrat_xDateDBEdit_USR_DATEBEGIN: TxDateDBEdit
              Left = 411
              Top = 33
              Width = 68
              TabOrder = 6
            end
            object usrat_xDateDBEdit_USR_DATEEND: TxDateDBEdit
              Left = 411
              Top = 58
              Width = 68
              TabOrder = 7
            end
            object usrat_DBEdit_USR_DURATION: TxDBCalculatorEdit
              Left = 656
              Top = 8
              Width = 60
              Cursor = crIBeam
              TabOrder = 8
            end
            object usrat_DBEdit_USR_EXTRADURATION: TxDBCalculatorEdit
              Left = 656
              Top = 33
              Width = 60
              Cursor = crArrow
              TabOrder = 9
            end
          end
        end
        object usrg_TabSheet2: TTabSheet
          Tag = 0
          Cursor = crDefault
          Hint = ''
          HelpContext = 0
          BorderWidth = 0
          Caption = 'Атрибуты'
          DragMode = dmManual
          Enabled = True
          Highlighted = False
          ImageIndex = 0
          Constraints.MaxHeight = 0
          Constraints.MaxWidth = 0
          Constraints.MinHeight = 0
          Constraints.MinWidth = 0
          ParentFont = True
          ParentShowHint = True
          PopupMenu = nil
          TabVisible = True
          object atContainer: TatContainer
            Top = 0
            Width = 1358
            Height = 270
            VertScrollBar.Position = 162
            TabOrder = 0
            object usrat_DBEdit_NUMBER_Label: TLabel
              Left = 5
              Top = -131
              Visible = False
            end
            object usrat_xDateDBEdit_DOCUMENTDATE_Label: TLabel
              Top = -154
              Visible = False
            end
            object usrat_DBEdit_USR_SORTNUMBER_Label: TLabel
              Left = 5
              Top = -109
              Visible = False
            end
            object usrat_DBEdit_USR_EQRATE_Label: TLabel
              Top = 253
            end
            object usrat_DBEdit_NUMBER: TDBEdit
              Left = 131
              Top = -134
              Width = 100
              TabOrder = 2
              Visible = False
            end
            object usrat_xDateDBEdit_DOCUMENTDATE: TxDateDBEdit
              Left = 131
              Top = -157
              Width = 100
              TabOrder = 1
              Visible = False
            end
            object usrat_DBEdit_USR_SORTNUMBER: TxDBCalculatorEdit
              Left = 131
              Top = -111
              Width = 100
              Cursor = crIBeam
              TabOrder = 0
              Visible = False
            end
            object usrat_DBEdit_USR_EQRATE: TxDBCalculatorEdit
              Top = 249
              Cursor = crIBeam
              TabOrder = 3
            end
          end
        end
      end
    end
    object usrg_pAvgSalary: TPanel
      Tag = 0
      Left = 589
      Top = 302
      Width = 777
      Height = 377
      Cursor = crDefault
      Hint = ''
      HelpContext = 0
      Align = alClient
      Alignment = taCenter
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      BevelInner = bvNone
      BevelOuter = bvNone
      BevelWidth = 1
      BorderWidth = 0
      BorderStyle = bsNone
      Caption = ''
      Color = clBtnFace
      Constraints.MaxHeight = 0
      Constraints.MaxWidth = 0
      Constraints.MinHeight = 0
      Constraints.MinWidth = 0
      UseDockManager = True
      DockSite = False
      DragCursor = crDrag
      DragKind = dkDrag
      DragMode = dmManual
      Enabled = True
      FullRepaint = True
      Locked = False
      ParentBiDiMode = True
      ParentColor = False
      ParentCtl3D = True
      ParentFont = True
      ParentShowHint = True
      PopupMenu = nil
      TabOrder = 1
      TabStop = False
      Visible = True
      object usrg_PageControl2: TPageControl
        Tag = 0
        Left = 0
        Top = 0
        Width = 777
        Height = 377
        Cursor = crDefault
        Hint = ''
        HelpContext = 0
        ActivePage = usrg_TabSheet3
        Align = alClient
        Anchors = [akLeft, akTop, akRight, akBottom]
        Constraints.MaxHeight = 0
        Constraints.MaxWidth = 0
        Constraints.MinHeight = 0
        Constraints.MinWidth = 0
        DockSite = False
        DragCursor = crDrag
        DragKind = dkDrag
        DragMode = dmManual
        Enabled = True
        HotTrack = False
        Images = nil
        MultiLine = False
        OwnerDraw = False
        ParentBiDiMode = True
        ParentFont = True
        ParentShowHint = True
        PopupMenu = nil
        RaggedRight = False
        ScrollOpposite = False
        Style = tsTabs
        TabHeight = 0
        TabOrder = 0
        TabPosition = tpTop
        TabStop = True
        TabWidth = 0
        Visible = True
        object usrg_TabSheet3: TTabSheet
          Tag = 0
          Cursor = crDefault
          Hint = ''
          HelpContext = 0
          BorderWidth = 0
          Caption = 'Расчет структуры ср. заработка'
          DragMode = dmManual
          Enabled = True
          Highlighted = False
          ImageIndex = 0
          Constraints.MaxHeight = 0
          Constraints.MaxWidth = 0
          Constraints.MinHeight = 0
          Constraints.MinWidth = 0
          ParentFont = True
          ParentShowHint = True
          PopupMenu = nil
          TabVisible = True
          object usrg_grAvgSalaryStr: TgsIBGrid
            Tag = 0
            Left = 0
            Top = 26
            Width = 769
            Height = 323
            Cursor = crDefault
            Hint = ''
            HelpContext = 0
            TabStop = True
            Align = alClient
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsNone
            Constraints.MaxHeight = 0
            Constraints.MaxWidth = 0
            Constraints.MinHeight = 0
            Constraints.MinWidth = 0
            DataSource = usrg_dsAvgSalaryStr
            DefaultDrawing = True
            DragCursor = crDrag
            DragKind = dkDrag
            DragMode = dmManual
            Enabled = True
            ImeMode = imDontCare
            ImeName = ''
            Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
            ParentBiDiMode = True
            ParentColor = False
            ParentCtl3D = True
            ParentFont = True
            ParentShowHint = True
            PopupMenu = nil
            ReadOnly = False
            TabOrder = 0
            Visible = True
            TableColor = clWindow
            SelectedColor = clHighlight
            TitleColor = clBtnFace
            RefreshType = rtCloseOpen
            Striped = True
            StripeOdd = 15201271
            StripeEven = 14084071
            InternalMenuKind = imkWithSeparator
            Expands = <
              item
                DisplayField = 'USR$DOW'
                FieldName = 'USR$HOW'
                LineCount = 1
                Options = [ceoAddField]
              end
              item
                DisplayField = 'USR$SCHEDULERDOW'
                FieldName = 'USR$SCHEDULERHOW'
                LineCount = 1
                Options = [ceoAddField]
              end
              item
                DisplayField = 'USR$NEWSALARY'
                FieldName = 'USR$OLDSALARY'
                LineCount = 1
                Options = [ceoAddField]
              end
              item
                DisplayField = 'USR$SALARY'
                FieldName = 'USR$MODERNSALARY'
                LineCount = 1
                Options = [ceoAddField]
              end>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.DisplayField = ''
            CheckBox.FieldName = ''
            CheckBox.Visible = True
            CheckBox.CheckList.Strings = (
              '')
            CheckBox.FirstColumn = False
            ScaleColumns = False
            MinColWidth = 40
            ToolBar = nil
            FinishDrawing = True
            RememberPosition = True
            SaveSettings = True
            ColumnEditors = <
              item
                Lookup.Distinct = False
                EditorStyle = cesValueList
                FieldName = 'USR$ISCHECK'
                DisplayField = 'USR$ISCHECK'
                ValueList.Strings = (
                  'Нет=0'
                  'Да=1')
                DropDownCount = 3
              end>
            Aliases = <>
            ShowFooter = False
            ShowTotals = True
            Columns = <
              item
                Expanded = False
                FieldName = 'USR$ISFULL'
                Title.Caption = 'Полный месяц'
                Width = 48
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$ISCHECK'
                Title.Caption = 'Вкл.'
                Width = 48
                Visible = True
                TotalType = ttSum
              end
              item
                Expanded = False
                FieldName = 'USR$DATE'
                Title.Caption = 'Дата'
                Width = 63
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$SALARY'
                Title.Caption = 'Зарплата'
                Width = 68
                Visible = True
                DisplayFormat = '#.##'
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$COEFF'
                Title.Caption = 'Коэф-т'
                Width = 52
                Visible = True
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$MODERNSALARY'
                Title.Caption = 'Современная зарплата'
                Width = 83
                Visible = True
                DisplayFormat = '#.##'
                TotalType = ttSum
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$DOW'
                Title.Caption = 'Дни'
                Width = 36
                Visible = True
                TotalType = ttSum
              end
              item
                Expanded = False
                FieldName = 'USR$SCHEDULERDOW'
                Title.Caption = 'Дней по гр.'
                Width = 72
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$HOW'
                Title.Caption = 'Часы'
                Width = 43
                Visible = True
                TotalType = ttSum
              end
              item
                Expanded = False
                FieldName = 'USR$SCHEDULERHOW'
                Title.Caption = 'Часов по гр.'
                Width = 76
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$DESCRIPTION'
                Title.Caption = 'Описание'
                Width = 168
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$OLDSALARY'
                Title.Caption = 'Оклад'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'USR$NEWSALARY'
                Title.Caption = 'Текущий оклад'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'ID'
                ReadOnly = True
                Title.Caption = 'Идентификатор'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'USR$DOCUMENTKEY'
                Title.Caption = 'Документ'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'Z_USR$DOCUMENTKEY_NUMBER'
                Title.Caption = 'Номер'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'Z_USR$DOCUMENTKEY_DOCUMENTDATE'
                Title.Caption = 'Дата'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'Z_USR$DOCUMENTKEY_DOC2715260478'
                Title.Caption = 'Тип документа'
                Width = -1
                Visible = False
              end>
          end
          object usrg_TBDock1: TTBDock
            Tag = 0
            Left = 0
            Top = 0
            Width = 769
            Height = 26
            Cursor = crDefault
            Hint = ''
            HelpContext = 0
            AllowDrag = True
            Background = nil
            BackgroundOnToolbars = True
            BoundLines = []
            Color = clBtnFace
            FixAlign = False
            LimitToOneRow = False
            PopupMenu = nil
            Position = dpTop
            Visible = True
            object usrg_TBToolbar1: TTBToolbar
              Tag = 0
              Left = 0
              Top = 0
              Cursor = crDefault
              HelpContext = 0
              ActivateParent = True
              Align = alNone
              Anchors = [akLeft, akTop]
              AutoResize = True
              BorderStyle = bsSingle
              Caption = 'tbDetail'
              ChevronMoveItems = True
              ChevronPriorityForNewItems = tbcpHighest
              CloseButton = False
              CloseButtonWhenDocked = False
              Color = clBtnFace
              DefaultDock = nil
              DockableTo = [dpTop, dpBottom, dpLeft, dpRight]
              DockMode = dmCannotFloatOrChangeDocks
              DockPos = 0
              DockRow = 0
              DragHandleStyle = dhSingle
              FloatingMode = fmOnTopOfParentForm
              FloatingWidth = 0
              FullSize = False
              HideWhenInactive = True
              Images = dmImages.il16x16
              LinkSubitems = nil
              MenuBar = False
              Options = []
              ParentFont = True
              ParentShowHint = False
              PopupMenu = nil
              ProcessShortCuts = False
              Resizable = True
              ShowCaption = True
              ShowHint = True
              ShrinkMode = tbsmChevron
              SmoothDrag = True
              Stretch = True
              SystemFont = True
              TabOrder = 0
              UpdateActions = True
              UseLastDock = True
              Visible = True
              SavedAtRunTime = True
              object usrg_TBItem2: TTBItem
                Tag = 0
                Action = usrg_actAvgNew
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
              object usrg_TBItem3: TTBItem
                Tag = 0
                Action = usrg_actAvgEdit
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
              object usrg_TBItem4: TTBItem
                Tag = 0
                Action = usrg_actAvgDelete
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
              object usrg_TBItem5: TTBItem
                Tag = 0
                Action = usrg_actAvgCopy
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = dmImages.il16x16
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
              object usrg_TBSeparatorItem3: TTBSeparatorItem
                Tag = 0
                Blank = False
                Hint = ''
                Visible = True
              end
              object usrg_TBItem11: TTBItem
                Tag = 0
                Action = usrg_actAvgGenerate
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
            end
          end
        end
      end
    end
  end
  object alBase: TActionList
    Left = 388
    Top = 8
    object actNew: TAction
    end
    object actHelp: TAction
    end
    object actSecurity: TAction
    end
    object actOk: TAction
    end
    object actCancel: TAction
    end
    object actNextRecord: TAction
    end
    object actPrevRecord: TAction
    end
    object actApply: TAction
    end
    object actFirstRecord: TAction
    end
    object actLastRecord: TAction
    end
    object actProperty: TAction
    end
    object actCopySettingsFromUser: TAction
    end
    object actAddToSetting: TAction
    end
    object actDocumentType: TAction
    end
    object actDistributeUserSettings: TAction
    end
    object actHistory: TAction
    end
    object actDetailNew: TAction
    end
    object actDetailEdit: TAction
    end
    object actDetailDelete: TAction
    end
    object actDetailDuplicate: TAction
    end
    object actDetailPrint: TAction
    end
    object actDetailCut: TAction
    end
    object actDetailCopy: TAction
    end
    object actDetailPaste: TAction
    end
    object actDetailMacro: TAction
    end
    object actDetailProp: TAction
    end
    object usrg_actGenStr: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'usrg_actGenStr'
      Checked = False
      Enabled = False
      HelpContext = 0
      Hint = ''
      ImageIndex = -1
      ShortCut = 0
      Visible = False
    end
    object usrg_actAvgNew: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Новый'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Новый'
      ImageIndex = 0
      ShortCut = 0
      Visible = True
    end
    object usrg_actAvgEdit: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Редактировать'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Редактировать'
      ImageIndex = 1
      ShortCut = 0
      Visible = True
    end
    object usrg_actAvgDelete: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Удалить'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Удалить'
      ImageIndex = 2
      ShortCut = 0
      Visible = True
    end
    object usrg_actGenerate: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Рассчитать'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Рассчитать'
      ImageIndex = 236
      ShortCut = 0
      Visible = True
    end
    object usrg_actAvgGenerate: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Рассчитать ср. заработок'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Рассчитать ср. заработок'
      ImageIndex = 236
      ShortCut = 0
      Visible = True
    end
    object usrg_actAvgCopy: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Копировать'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = ''
      ImageIndex = 3
      ShortCut = 0
      Visible = True
    end
  end
  object dsgdcBase: TDataSource
    Left = 421
    Top = 7
  end
  object pm_dlgG: TPopupMenu
    Left = 152
    Top = 216
    object actSecurity1: TMenuItem
    end
    object actHistory1: TMenuItem
    end
    object N1: TMenuItem
    end
    object sepFirst: TMenuItem
    end
    object actNextRecord1: TMenuItem
    end
    object actPrevRecord1: TMenuItem
    end
    object actFirstRecord1: TMenuItem
    end
    object actLastRecord1: TMenuItem
    end
    object sepSecond: TMenuItem
    end
    object actApply1: TMenuItem
    end
    object sepThird: TMenuItem
    end
    object actProperty1: TMenuItem
    end
    object actCopySettings1: TMenuItem
    end
    object nAddToSetting1: TMenuItem
    end
  end
  object ibtrCommon: TIBTransaction
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 488
    Top = 168
  end
  object dsDetail: TDataSource
    Left = 421
    Top = 38
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 905
    Top = 55
  end
  object usrg_gdcAvgSalaryStr: TgdcAttrUserDefined
    Tag = 0
    ForcedRefresh = False
    AutoCalcFields = True
    ObjectView = False
    AllowStreamedActive = False
    SubType = 'USR$WG_AVGSALARYSTR'
    MasterSource = dsgdcBase
    MasterField = 'ID'
    DetailField = 'parent'
    SubSet = 'ByParent'
    SetTable = ''
    Active = True
    CachedUpdates = False
    ReadTransaction = gdcUserDocument.ibtrInternal
    Filtered = False
    Left = 652
    Top = 256
  end
  object usrg_dsAvgSalaryStr: TDataSource
    Tag = 0
    AutoEdit = True
    DataSet = usrg_gdcAvgSalaryStr
    Enabled = True
    Left = 685
    Top = 260
  end
end
