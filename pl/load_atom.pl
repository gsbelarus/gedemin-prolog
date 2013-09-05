% load_atom(+Source, +Text)
load_atom(Source, Text) :-
    atom(Source), atom(Text),
    % library(memfile)
    atom_to_memory_file(Text, Handle),
    open_memory_file(Handle, read, Stream),
    %
    load_files(Source, [silent(true), stream(Stream)]),
    !.

% pl_run(+Codes)
pl_run(Codes) :-
    term_to_atom(Term, Codes),
    call(Term).

% pl_run(+CodesIn, -CodesOut, -Return)
pl_run(CodesIn, CodesOut, "true") :-
    catch( term_to_atom(Term, CodesIn), _, fail ),
    catch( call( Term ), _, fail ),
    term_to_atom(Term, Atom),
    atom_codes(Atom, CodesOut).
pl_run(_, "", "false").

