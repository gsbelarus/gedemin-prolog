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

% pl_run(+String)
pl_run(String) :-
    term_to_atom(Term, String),
    call(Term).

% pl_run(+StringIn, -StringOut, -Return)
pl_run(StringIn, StringOut, "true") :-
    catch( term_to_atom(Term, StringIn), _, fail ),
    catch( call( Term ), _, fail ),
    term_to_atom(Term, Atom),
    string_to_atom(StringOut, Atom).
pl_run(_, "", "false").

