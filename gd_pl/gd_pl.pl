% swipl.exe -f none -s gd_pl -g gd_pl,halt
% swipl.exe -f none -x gd_pl_state.dat

%
:- volatile gd_pl_path/1, gd_pl/0, lib/0, usr/0, fsp/0, flg/0, gd/0.
%
:- set_prolog_flag(double_quotes, string).

%
gd_pl_path( library('d:/shared/golden/Gedemin/swipl_min/library/') ).
gd_pl_path( bin('d:/shared/golden/Gedemin/swipl_min/bin/') ).
gd_pl_path( usr('d:/shared/golden/Gedemin/swipl_min/usr/') ).

%
gd_pl:- lib, usr, fsp, flg, gd.

%
lib :-
    gd_pl_path( library(PathLibrary) ),
    working_directory(_, PathLibrary),
    make_library_index(PathLibrary),
    use_module([
            aggregate,
            apply,
            arithmetic,
            backcomp,
            broadcast,
            debug,
            error,
            listing,
            lists,
            memfile,
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
fsp :-
   retractall(file_search_path(_, _)).
%
flg :-
    % silent if the flag is not known
    set_prolog_flag(user_flags, silent),
    % disables atom garbage collection
    set_prolog_flag(agc_margin, 0),
    % disables colored output
    set_prolog_flag(color_term, false),
    % debugging mode off
    set_prolog_flag(debug, false),
    % do not start the tracer after an error is detected
    set_prolog_flag(debug_on_error, false),
    % neither garbage collection, nor stack shifts will take place,
    % even not on explicit request
    set_prolog_flag(gc, false),
    % last-call optimisation is enabled
    set_prolog_flag(last_call_optimisation, true),
    % do not generate code that can be debugged
    set_prolog_flag(generate_debug_info, false),
    % suppress error messages
    set_prolog_flag(report_error, false),
    % no checking stream type
    set_prolog_flag(stream_type_check, false),
    % garbage collections and stack-shifts
    % will not be reported on the terminal
    set_prolog_flag(trace_gc, false),
    % messages of type informational and banner are suppressed
    set_prolog_flag(verbose, silent).
%
gd :-
    gd_pl_path( bin(PathBin) ),
    working_directory(_, PathBin),
    qsave_program('gd_pl_state.dat',
            [goal(true),
            init_file(none),
            class(runtime),
            autoload(true),
            map(gd_pl_map),
            stand_alone(false),
            foreign(no_save)]).
