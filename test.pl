:- include('import_csv.pl').

q(Answer) :-
    init,
    write("Ask me anything about TFT comps: "), 
    flush_output(current_output),
    readln(Question, _, _, [39, 45, 95], lowercase),
    ask(Question, Answer).

% debugging
t(Answer) :-
    init,
    ask([what, are, the, best, teams, '?'], Answer).

ask(Question, Answer) :-
    question(Question, End, Answer, Queries, []),
    member(End, [[], ['?'], ['.']]),
    query_data(Queries).

query_data([]).
query_data([Query | Queries]) :-
    call(Query),
    query_data(Queries).

question([what, are | L0], L1, Answer, C0, C1) :- noun_phrase(L0, L1, Answer, C0, C1).

% noun_phrase(L0, L4, Answer, C0, C4) :-
%     det(L0, L1, Answer, C0, C1),
%     noun(L2, L3, Answer, C2, C3),
%     mp(L3, L4, Answer, C3, C4).

noun_phrase(L0, L2, Answer, C0, C2) :-
    det(L0, L1, Answer, C0, C1),
    relation(L1, L2, Answer, C1, C2).

noun_phrase(L0, L2, Answer, C0, C2) :-
    det(L0, L1, Answer, C0, C1),
    feature(L1, L2, Answer, C1, C2).

det([the | L], L, _, C, C).
det(L,L,_,C,C).

relation(L0, L2, Answer, C0, C2) :-
    feature(L0, L1, Team, Answer, C0, C1),
    noun(L1, L2, Team, C1, C2).
relation(L, L, _, C, C).

feature([best, silver, augments, for | L], L, Team, Answer, [data(Team, silver_augments, Answer) | C], C).
feature([best, teams | L], L, Team, [data(Team, rank, s) | C], C).

noun([Answer | L], L, Answer, [data(Answer, description, _) | C], C).