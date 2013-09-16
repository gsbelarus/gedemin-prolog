%
gd_pl_path( library('d:/shared/golden/Gedemin/swipl_odbc/library/') ).
gd_pl_path( bin('d:/shared/golden/Gedemin/swipl_odbc/bin/') ).
gd_pl_path( usr('d:/shared/golden/Gedemin/swipl_odbc/usr/') ).

%
:- volatile gd_pl_path/1, flg/0, lib/0, usr/0, gd/0.

%
:- set_prolog_flag(double_quotes, string).

%
flg :-
    set_prolog_flag(autoload, false),
    set_prolog_flag(gui, false),
    set_prolog_flag(debug, false),
    set_prolog_flag(debug_on_error, false),
    set_prolog_flag(generate_debug_info, false),
    set_prolog_flag(history, 0),
    set_prolog_flag(report_error, false),
    set_prolog_flag(runtime, true),
    set_prolog_flag(stream_type_check, false),
    set_prolog_flag(user_flags, silent),
    set_prolog_flag(verbose, silent).

%
lib :-
    gd_pl_path( library(PathLibrary) ),
    working_directory(_, PathLibrary),
    make_library_index(PathLibrary),
    use_module(
            [aggregate,
            apply,
            arithmetic,
            backcomp,
            broadcast,
            debug,
            error,
            listing,
            lists,
            memfile,
            odbc,
            operators,
            option,
            ordsets,
            oset,
            pairs,
            prolog_autoload,
            prolog_codewalk,
            prolog_metainference,
            qsave,
            readutil,
            record,
            settings,
            shlib,
            sort,
            statistics,
            system
            ]),
    load_files([], [silent(false)]).
%
usr :-
    gd_pl_path( usr(PathUser) ),
    working_directory(_, PathUser),
    use_module([]),
    load_files([load_atom, date, dataset], [silent(false)]).
%
gd :-
    gd_pl_path( bin(PathBin) ),
    working_directory(_, PathBin),
    qsave_program(gd_pl_state,
            [goal(true),
            init_file(none),
            class(runtime),
            autoload(true),
            map(gd_pl_map),
            stand_alone(false),
            foreign(no_save)]).
