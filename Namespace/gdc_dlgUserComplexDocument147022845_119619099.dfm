object gdc_dlgUserComplexDocument147022845_119619099: Tgdc_dlgUserComplexDocument
  Left = -5
  Top = 99
  ActiveControl = nil
  WindowState = wsNormal
  PixelsPerInch = 96
  TextHeight = 13
  object btnAccess: TButton
    TabOrder = 3
  end
  object btnNew: TButton
    TabOrder = 4
  end
  object btnHelp: TButton
    TabOrder = 5
  end
  object btnOK: TButton
    TabOrder = 1
  end
  object btnCancel: TButton
    TabOrder = 2
  end
  object pnlMain: TPanel
    TabOrder = 0
    object splMain: TSplitter
    end
    object usrg_Splitter1: TSplitter
      Tag = 0
      Left = 541
      Top = 294
      Width = 6
      Height = 385
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
      Width = 541
      Align = alLeft
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 1
      object ibgrDetail: TgsIBGrid
        Left = 0
        Width = 541
        Height = 359
        Expands = <>
        Conditions = <>
        ColumnEditors = <>
        Aliases = <>
        Columns = <
          item
            Expanded = False
            FieldName = 'USR$INCLUDEDATE'
            Title.Caption = 'Месяц зачисления'
            Width = 108
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$PERCENT'
            Title.Caption = '%'
            Width = 36
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$DOI'
            Title.Caption = 'Дни'
            Width = 48
            Visible = True
            TotalType = ttSum
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$HOI'
            Title.Caption = 'Часы'
            Width = 48
            Visible = True
            TotalType = ttSum
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'USR$SUMMA'
            Title.Caption = 'Сумма'
            Width = 72
            Visible = True
            TotalType = ttSum
          end
          item
            Expanded = False
            FieldName = 'USR$DATEBEGIN'
            Title.Caption = 'Дата начала'
            Width = 84
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'USR$DATEEND'
            Title.Caption = 'Дата окончания'
            Width = 108
            Visible = True
          end
          item
            Alignment = taRightJustify
            Expanded = False
            FieldName = 'SUMNCU'
            Title.Caption = 'Начислено'
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
            Title.Caption = 'Родитель (05.Начисление болничных(позиция))'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'RESERVED1'
            ReadOnly = True
            Title.Caption = 'Зарезервировано (05.Начисление болничных(позиция))'
            Width = -1
            Visible = False
          end
          item
            Expanded = False
            FieldName = 'USR$ACCDATE'
            Title.Caption = 'Месяц начисления'
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
        Width = 541
        object tbDetail: TTBToolbar
          DockPos = 1
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
          object usrg_TBItem2: TTBItem
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
            Action = usrg_actStrGen
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
        Width = 0
        Height = 359
      end
      object tbdRight: TTBDock
        Left = 541
        Width = 0
        Height = 359
      end
      object tbdBottom: TTBDock
        Top = 385
        Width = 541
        Height = 0
      end
    end
    object pnlMaster: TPanel
      Constraints.MinHeight = 215
      TabOrder = 0
      object pnlHolding: TPanel
        Width = 1366
        TabOrder = 1
        object lblCompany: TLabel
        end
        object iblkCompany: TgsIBLookupComboBox
        end
      end
      object usrg_PageControl1: TPageControl
        Tag = 0
        Left = 0
        Top = 0
        Width = 1366
        Height = 290
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
            Top = 128
            Width = 1358
            Height = 134
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
            TabOrder = 1
            TabStop = False
            Visible = True
            object usrat_DBEdit_USR_AVGPERIOD_Label: TLabel
              Left = 7
              Top = 44
              Width = 119
              Caption = 'Период формирования:'
            end
            object usrat_gsIBLookupComboBox_USR_FEEGROUPKEY_Label: TLabel
              Left = 7
              Top = 20
            end
            object usrat_DBEdit_USR_AVGSUMMA_Label: TLabel
              Left = 373
              Top = 20
            end
            object usrat_DBEdit_USR_AVGPERIOD: TxDBCalculatorEdit
              Left = 143
              Top = 40
              Width = 100
              Cursor = crIBeam
              TabOrder = 1
            end
            object usrat_gsIBLookupComboBox_USR_FEEGROUPKEY: TgsIBLookupComboBox
              Left = 143
              Top = 16
              Width = 212
              ListTable = 
                'USR$WG_FEEGROUP fg LEFT JOIN USR$WG_FEEGROUP fg1 ON fg.lb > fg1.' +
                'lb AND fg.rb < fg1.rb'
              Condition = 'fg1.id = <RUID XID = 147274328 DBID = 274788016/>'
              TabOrder = 0
            end
            object usrat_DBEdit_USR_AVGSUMMA: TxDBCalculatorEdit
              Left = 467
              Top = 16
              Width = 93
              Cursor = crIBeam
              TabOrder = 4
            end
            object usrat_DBCheckBox_USR_BYSTAFFSALARY: TDBCheckBox
              Left = 375
              Top = 56
              Width = 161
              TabOrder = 2
              Visible = False
            end
            object usrat_DBCheckBox_USR_CALCBYHOUR: TDBCheckBox
              Left = 375
              Top = 73
              Width = 114
              TabOrder = 3
              ValueChecked = '1'
              ValueUnchecked = '0'
              Visible = False
            end
            object usrat_DBCheckBox_USR_CALCBYBUDGET: TDBCheckBox
              Left = 8
              Top = 86
              Hint = '50% от БМП'
              Caption = '50% от БПМ'
              ReadOnly = False
            end
            object usrat_DBCheckBox_USR_THIRDMETHOD: TDBCheckBox
              Left = 8
              Top = 67
              Width = 117
              Caption = 'Расчёт от ставки'
              ReadOnly = True
            end
            object usrat_DBCheckBox_USR_REFERENCE: TDBCheckBox
              Left = 143
              Top = 77
              TabOrder = 7
            end
          end
          object usrg_Panel1: TPanel
            Tag = 0
            Left = 0
            Top = 0
            Width = 1358
            Height = 128
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
            TabOrder = 0
            TabStop = False
            Visible = True
            object usrg_Label1: TLabel
              Tag = 0
              Left = 7
              Top = 80
              Width = 66
              Height = 13
              Cursor = crDefault
              Hint = ''
              Align = alNone
              Alignment = taLeftJustify
              Anchors = [akLeft, akTop]
              AutoSize = True
              Caption = 'Тип расчета:'
              Constraints.MaxHeight = 0
              Constraints.MaxWidth = 0
              Constraints.MinHeight = 0
              Constraints.MinWidth = 0
              DragCursor = crDrag
              DragKind = dkDrag
              DragMode = dmManual
              Enabled = True
              FocusControl = nil
              ParentBiDiMode = True
              ParentColor = True
              ParentFont = True
              ParentShowHint = True
              PopupMenu = nil
              ShowAccelChar = True
              Transparent = True
              Layout = tlTop
              Visible = True
              WordWrap = False
            end
            object usrat_gsIBLookupComboBox_USR_EMPLKEY_Label: TLabel
              Left = 7
              Top = 35
            end
            object usrat_xDateDBEdit_USR_FROM_Label: TLabel
              Left = 317
              Top = 12
            end
            object usrat_gsIBLookupComboBox_USR_ILLTYPEKEY_Label: TLabel
              Left = 7
              Top = 58
            end
            object usrat_xDateDBEdit_USR_DATEEND_Label: TLabel
              Left = 317
              Top = 58
            end
            object usrat_xDateDBEdit_USR_DATEBEGIN_Label: TLabel
              Left = 317
              Top = 35
            end
            object usrat_gsIBLookupComboBox_USR_TOTALDOCKEY_Label: TLabel
              Left = 7
              Top = 12
            end
            object usrat_DBEdit_USR_PERCENT_Label: TLabel
              Left = 317
              Top = 81
              Width = 91
              Caption = 'Процент пособия:'
            end
            object usrat_gsIBLookupComboBox_USR_FIRSTMOVEKEY_Label: TLabel
              Left = 8
              Top = 104
              Width = 76
              Caption = 'По должности:'
            end
            object usrg_cbCalcType: TComboBox
              Tag = 0
              Left = 133
              Top = 77
              Width = 156
              Height = 21
              Cursor = crDefault
              Hint = ''
              HelpContext = 0
              TabStop = True
              Style = csDropDownList
              Anchors = [akLeft, akTop]
              Color = clWindow
              Constraints.MaxHeight = 0
              Constraints.MaxWidth = 0
              Constraints.MinHeight = 0
              Constraints.MinWidth = 0
              DragCursor = crDrag
              DragKind = dkDrag
              DragMode = dmManual
              DropDownCount = 3
              Enabled = True
              ImeMode = imDontCare
              ImeName = ''
              ItemHeight = 13
              MaxLength = 0
              ParentBiDiMode = True
              ParentColor = False
              ParentCtl3D = True
              ParentFont = True
              ParentShowHint = True
              PopupMenu = nil
              Sorted = False
              TabOrder = 3
              Text = '12 дн. 80%, ост. 100%'
              Visible = True
              Items.Strings = (
                '12 дн. 80%, ост. 100%'
                'Все дни 100%')
            end
            object usrat_gsIBLookupComboBox_USR_EMPLKEY: TgsIBLookupComboBox
              Left = 133
              Top = 31
              Width = 156
              ListTable = 
                'GD_CONTACT C JOIN GD_CONTACT CC ON CC.LB <= C.LB AND CC.RB >= C.' +
                'RB'
              SortOrder = soAsc
              Condition = 'c.contacttype = 2 AND cc.id = <COMPANYKEY/>'
              SubType = ''
              TabOrder = 1
            end
            object usrat_xDateDBEdit_USR_FROM: TxDateDBEdit
              Left = 491
              Top = 8
              Width = 68
              TabOrder = 5
            end
            object usrat_gsIBLookupComboBox_USR_ILLTYPEKEY: TgsIBLookupComboBox
              Left = 133
              Top = 54
              Width = 156
              TabOrder = 2
            end
            object usrat_xDateDBEdit_USR_DATEBEGIN: TxDateDBEdit
              Left = 491
              Top = 31
              Width = 68
              TabOrder = 6
            end
            object usrat_xDateDBEdit_USR_DATEEND: TxDateDBEdit
              Left = 491
              Top = 54
              Width = 68
              TabOrder = 7
            end
            object usrat_gsIBLookupComboBox_USR_TOTALDOCKEY: TgsIBLookupComboBox
              Left = 133
              Top = 8
              Width = 156
              ListTable = 
                'usr$wg_total t LEFT JOIN GD_DOCUMENT doc ON doc.id = t.documentk' +
                'ey'
              ListField = 'usr$name'
              KeyField = 'documentkey'
              SortOrder = soAsc
              Condition = 'parent is null and doc.companykey = <companykey/>'
              gdClassName = 'TgdcUserDocument'
              SubType = '147567052_119619099'
              ParentShowHint = False
              ShowHint = True
              TabOrder = 0
            end
            object usrat_DBEdit_USR_PERCENT: TxDBCalculatorEdit
              Left = 491
              Top = 77
              Width = 69
              Cursor = crIBeam
              TabOrder = 8
            end
            object usrat_gsIBLookupComboBox_USR_FIRSTMOVEKEY: TgsIBLookupComboBox
              Left = 133
              Top = 101
              Width = 156
              Fields = 'l.POSNAME, l.DEPTNAME, l.KINDOFWORKNAME'
              ListTable = 'USR$WG_P_FMKLOOKUPSETTINGS (:emplkey, :dateend)  l'
              ListField = 'l.POSID'
              KeyField = 'l.FMK'
              Condition = ''
              TabOrder = 4
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
            Height = 237
            VertScrollBar.Position = 103
            TabOrder = 0
            Visible = False
            object usrat_DBEdit_USR_DURATION_Label: TLabel
              Top = 113
              Visible = False
            end
            object usrat_DBEdit_USR_CALCTYPE_Label: TLabel
              Left = 29
              Top = 2
              Visible = False
            end
            object usrat_DBEdit_NUMBER_Label: TLabel
              Left = 5
              Top = -71
              Visible = False
            end
            object usrat_xDateDBEdit_DOCUMENTDATE_Label: TLabel
              Top = -95
              Visible = False
            end
            object usrat_DBEdit_USR_SORTNUMBER_Label: TLabel
              Left = 5
              Top = -42
              Visible = False
            end
            object usrat_DBEdit_USR_EQRATE_Label: TLabel
              Top = 312
            end
            object usrat_DBEdit_USR_DURATION: TxDBCalculatorEdit
              Top = 109
              Cursor = crIBeam
              TabOrder = 4
              Visible = False
            end
            object usrat_DBEdit_USR_CALCTYPE: TxDBCalculatorEdit
              Left = 157
              Top = -2
              Width = 156
              Cursor = crIBeam
              TabOrder = 3
              Visible = False
            end
            object usrat_DBEdit_NUMBER: TDBEdit
              Left = 163
              Top = -75
              Width = 101
              TabOrder = 2
              Visible = False
            end
            object usrat_xDateDBEdit_DOCUMENTDATE: TxDateDBEdit
              Left = 163
              Top = -99
              Width = 102
              TabOrder = 1
              Visible = False
            end
            object usrat_DBEdit_USR_SORTNUMBER: TxDBCalculatorEdit
              Left = 163
              Top = -42
              Cursor = crIBeam
              TabOrder = 0
              Visible = False
            end
            object usrat_DBEdit_USR_EQRATE: TxDBCalculatorEdit
              Top = 308
              Cursor = crIBeam
              TabOrder = 5
            end
          end
        end
      end
    end
    object usrg_pAvgSalary: TPanel
      Tag = 0
      Left = 547
      Top = 294
      Width = 819
      Height = 385
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
      TabOrder = 2
      TabStop = False
      Visible = True
      object usrg_PageControl2: TPageControl
        Tag = 0
        Left = 0
        Top = 0
        Width = 819
        Height = 385
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
            Width = 811
            Height = 331
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
            Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
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
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.DisplayField = 'USR$ISCHECK'
            CheckBox.FieldName = 'USR$ISCHECK'
            CheckBox.Visible = False
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
              end
              item
                Lookup.Distinct = False
                EditorStyle = cesValueList
                FieldName = 'USR$ISFULL'
                DisplayField = 'USR$ISFULL'
                ValueList.Strings = (
                  'Да=1'
                  'Нет=0')
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
                Width = 54
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$DATE'
                Title.Caption = 'Дата'
                Width = 72
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$CALCDAYS'
                Title.Caption = 'Дни расчет.'
                Width = 78
                Visible = True
                TotalType = ttSum
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$SALARY'
                Title.Caption = 'Зарплата'
                Width = 72
                Visible = True
                DisplayFormat = '#.##'
                TotalType = ttSum
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$DOW'
                Title.Caption = 'Дни работы'
                Width = 60
                Visible = True
                TotalType = ttSum
              end
              item
                Expanded = False
                FieldName = 'USR$SCHEDULERDOW'
                Title.Caption = 'Дней по графику'
                Width = 84
                Visible = True
              end
              item
                Alignment = taRightJustify
                Expanded = False
                FieldName = 'USR$HOW'
                Title.Caption = 'Часы работы'
                Width = 66
                Visible = True
                TotalType = ttSum
              end
              item
                Expanded = False
                FieldName = 'USR$SCHEDULERHOW'
                Title.Caption = 'Часов по графику'
                Width = 90
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'USR$DESCRIPTION'
                Title.Caption = 'Описание'
                Width = 144
                Visible = True
              end
              item
                Color = clWhite
                Expanded = False
                FieldName = 'USR$MODERNSALARY'
                Title.Caption = 'Современная зарплата'
                Width = -1
                Visible = False
                DisplayFormat = '#.##'
              end
              item
                Expanded = False
                FieldName = 'USR$COEFF'
                Title.Caption = 'Коэф-т'
                Width = -1
                Visible = False
              end
              item
                Expanded = False
                FieldName = 'USR$ISCHECK'
                Title.Caption = 'Вкл.'
                Width = -1
                Visible = False
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
                Title.Caption = 'Ставка'
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
            Width = 811
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
              object usrg_TBItem3: TTBItem
                Tag = 0
                Action = usrg_actAvgSalaryNew
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
                Action = usrg_actAvgSalaryEdit
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
                Action = usrg_actAvgSalaryDelete
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
              object usrg_TBItem6: TTBItem
                Tag = 0
                Action = nil
                AutoCheck = False
                Caption = 'Дубликат'
                Checked = False
                DisplayMode = nbdmDefault
                Enabled = True
                GroupIndex = 0
                HelpContext = 0
                Hint = 'Дубликат'
                ImageIndex = 3
                Images = nil
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
                ShortCut = 49237
                Visible = False
              end
              object usrg_TBSeparatorItem2: TTBSeparatorItem
                Tag = 0
                Blank = False
                Hint = ''
                Visible = True
              end
              object usrg_TBItem7: TTBItem
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
        object usrg_TabSheet4: TTabSheet
          Tag = 0
          Cursor = crDefault
          Hint = ''
          HelpContext = 0
          BorderWidth = 0
          Caption = 'Структура больничного'
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
          TabVisible = False
          object usrg_TBDock2: TTBDock
            Tag = 0
            Left = 0
            Top = 0
            Width = 811
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
            object usrg_TBToolbar2: TTBToolbar
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
              Caption = 'usrg_TBToolbar2'
              ChevronMoveItems = True
              ChevronPriorityForNewItems = tbcpHighest
              CloseButton = False
              CloseButtonWhenDocked = False
              Color = clBtnFace
              DefaultDock = nil
              DockableTo = [dpTop, dpBottom, dpLeft, dpRight]
              DockMode = dmCannotFloatOrChangeDocks
              DockPos = -1
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
              object usrg_TBItem8: TTBItem
                Tag = 0
                Action = usrg_actStrCalcOnUpdate
                AutoCheck = False
                DisplayMode = nbdmDefault
                GroupIndex = 0
                Images = dmImages.il16x16
                InheritOptions = True
                MaskOptions = []
                Options = []
                RadioItem = False
              end
            end
          end
          object usrg_grSickStr: TgsDBGrid
            Tag = 0
            Left = 0
            Top = 26
            Width = 811
            Height = 331
            Cursor = crDefault
            Hint = ''
            HelpContext = 0
            TabStop = True
            Align = alClient
            Anchors = [akLeft, akTop, akRight, akBottom]
            BorderStyle = bsSingle
            Constraints.MaxHeight = 0
            Constraints.MaxWidth = 0
            Constraints.MinHeight = 0
            Constraints.MinWidth = 0
            Ctl3D = True
            DataSource = usrg_dsSickStr
            DefaultDrawing = True
            DragCursor = crDrag
            DragKind = dkDrag
            DragMode = dmManual
            Enabled = True
            ImeMode = imDontCare
            ImeName = ''
            Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
            ParentBiDiMode = True
            ParentColor = False
            ParentCtl3D = False
            ParentFont = True
            ParentShowHint = True
            PopupMenu = nil
            ReadOnly = False
            RefreshType = rtCloseOpen
            TabOrder = 1
            Visible = True
            TableColor = clWindow
            SelectedColor = clHighlight
            TitleColor = clBtnFace
            Striped = True
            StripeOdd = 15201271
            StripeEven = 14084071
            InternalMenuKind = imkWithSeparator
            Expands = <>
            ExpandsActive = False
            ExpandsSeparate = False
            TitlesExpanding = False
            Conditions = <>
            ConditionsActive = False
            CheckBox.DisplayField = ''
            CheckBox.FieldName = ''
            CheckBox.Visible = False
            CheckBox.FirstColumn = False
            ScaleColumns = True
            MinColWidth = 40
            ToolBar = nil
            FinishDrawing = True
            RememberPosition = True
            SaveSettings = True
            ShowTotals = True
            ShowFooter = False
            Columns = <
              item
                Expanded = False
                FieldName = 'Дата'
                Width = 95
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'Рабочий день'
                Width = 86
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'Часы'
                Width = 76
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'Процент'
                Width = 534
                Visible = True
              end>
          end
        end
      end
    end
  end
  object alBase: TActionList
    Left = 548
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
    object usrg_actAvgSalaryNew: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Добавить'
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Добавить'
      ImageIndex = 0
      ShortCut = 0
      Visible = True
    end
    object usrg_actAvgSalaryEdit: TgsAction
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
    object usrg_actAvgSalaryDelete: TgsAction
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
    object usrg_actStrGen: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'usrg_actStrGen'
      Checked = False
      Enabled = False
      HelpContext = 0
      Hint = ''
      ImageIndex = -1
      ShortCut = 0
      Visible = False
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
      Caption = ''
      Checked = False
      Enabled = True
      HelpContext = 0
      Hint = 'Рассчитать ср. заработок'
      ImageIndex = 236
      ShortCut = 0
      Visible = True
    end
    object usrg_actStrCalcOnUpdate: TgsAction
      Tag = 0
      Category = 'wage'
      Caption = 'Расчитать по структуре'
      Checked = False
      Enabled = False
      HelpContext = 0
      Hint = 'Расчитать по структуре'
      ImageIndex = 236
      ShortCut = 0
      Visible = True
    end
  end
  object dsgdcBase: TDataSource
    Left = 589
    Top = 7
  end
  object pm_dlgG: TPopupMenu
    Left = 472
    Top = 8
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
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 504
    Top = 8
  end
  object dsDetail: TDataSource
    Left = 293
    Top = 342
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 441
    Top = 7
  end
  object usrg_gdcAvgSalaryStr: TgdcAttrUserDefined
    Tag = 0
    ForcedRefresh = False
    AutoCalcFields = True
    ObjectView = False
    AllowStreamedActive = False
    SubType = 'USR$WG_AVGSALARYSTR'
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'parent'
    SubSet = 'ByParent'
    SetTable = ''
    Active = True
    CachedUpdates = False
    ReadTransaction = gdcUserDocument.ibtrInternal
    Filtered = False
    Left = 644
    Top = 208
  end
  object usrg_dsAvgSalaryStr: TDataSource
    Tag = 0
    AutoEdit = True
    DataSet = usrg_gdcAvgSalaryStr
    Enabled = True
    Left = 675
    Top = 208
  end
  object usrg_dsSickStr: TDataSource
    Tag = 0
    AutoEdit = True
    Enabled = True
    Left = 769
    Top = 424
  end
end
