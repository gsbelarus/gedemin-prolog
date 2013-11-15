% load_atom(+Source, +Text)
load_atom(Source, Text) :-
    ( atom(Source), File = Source
    ; string(Source), string_to_atom(Source, File)
    ; atom_codes(File, Source)
    ),
    ( atom(Text), Content = Text
    ; string(Text), string_to_atom(Text, Content)
    ; atom_codes(Content, Text)
    ),
    % library(memfile)
    atom_to_memory_file(Content, Handle),
    open_memory_file(Handle, read, Stream),
    %
    load_files(File, [silent(true), stream(Stream)]),
    close(Stream),
    % library(memfile)
    free_memory_file(Handle),
    %
    !.

% pl_run(+Atom)
pl_run(Atom) :-
    atom(Atom),
    term_to_atom(Term, Atom),
    Term,
    !.

% pl_run(+StringIn, -StringOut, -Return)
pl_run(StringIn, StringOut, "true") :-
    catch( term_to_atom(Term, StringIn), _, fail ),
    catch( Term, _, fail ),
    term_to_atom(Term, Atom),
    string_to_atom(StringOut, Atom),
    !.
pl_run(_, "", "false") :-
    !.

% pl_assert(+Goal)
pl_assert(Goal) :-
    assertz(Goal),
    !.

ps(1) :-
    set_prolog_stack(local, min_free(131072)),
    set_prolog_stack(global, min_free(65536)),
    set_prolog_stack(trail, min_free(65536)),
    !.
