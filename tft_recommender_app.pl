% the actual app

:- [import_csv].

set_prolog_flag(singleton, off).

% sample data

% prolog representation of English grammar, adapted from https://www.cs.ubc.ca/~poole/cs312/2023/prolog/geography_query_string.pl

% noun_phrase(L0,L4,Ind,C0,C4) is true if
%  L0 and L4 are list of words, such that
%        L4 is an ending of L0
%        the words in L0 before L4 (written L0-L4) form a noun phrase
%  Ind is an individual that the noun phrase is referring to
% C0 is a list such that C4 is an ending of C0 and C0-C4 contains the constraints imposed by the noun phrase

% A noun phrase is a determiner followed by adjectives followed
% by a noun followed by an optional modifying phrase:
noun_phrase(L0,L4,Ind,C0,C4) :-
    det(L0,L1,Ind,C3,C4),
    adjectives(L1,L2,Ind,C2,C3),
    noun(L2,L3,Ind,C1,C2),
    omp(L3,L4,Ind,C0,C1).

% Determiners (articles) are ignored in this oversimplified example.
% They do not provide any extra constraints.
det([the | L],L,_,C,C).
det([a | L],L,_,C,C).
det([an | L],L,_,C,C).
det(L,L,_,C,C).


% adjectives(L0,L2,Ind,C0,C2) is true if 
% L0-L2 is a sequence of adjectives imposes constraints C0-C2 on Ind
adjectives(L0,L2,Ind,C0,C2) :-
    adj(L0,L1,Ind,C0,C1),
    adjectives(L1,L2,Ind,C1,C2).
adjectives(L,L,_,C,C).

% An optional modifying phrase / relative clause is either
% a relation (verb or preposition) followed by a noun_phrase or
% 'that' followed by a relation then a noun_phrase or
% nothing 
mp(L0,L2,Subject,C0,C2) :-
    reln(L0,L1,Subject,Object,C0,C1),
    aphrase(L1,L2,Object,C1,C2).
mp([that|L0],L2,Subject,C0,C2) :-
    reln(L0,L1,Subject,Object,C0,C1),
    aphrase(L1,L2,Object,C1,C2).


% An optional modifying phrase is either a modifying phrase or nothing
omp(L0,L1,E,C0,C1) :-
    mp(L0,L1,E,C0,C1).
omp(L,L,_,C,C).

% a phrase is a noun_phrase or a modifying phrase
% note that this uses 'aphrase' because 'phrase' is a static procedure in SWI Prolog
aphrase(L0, L1, E, C0,C1) :- noun_phrase(L0, L1, E,C0,C1).
aphrase(L0, L1, E,C0,C1) :- mp(L0, L1, E,C0,C1).



% dictionary 

has(X, Y) :- 
    data(X, _, Z),
    member(Y, Z).

team(X) :- data(X, A, B).
champion(X) :- 
    data(Y, units, Z),
    member(X, Z).
item(X) :- 
    data(Y, carousel_priority, Z),
    member(X, Z).

% adj(L0, L1, Ind) is true if L0-L1 
% is an adjective that is true of Ind

adj(['s','rank'|L],L,Ind,[data(Ind, rank, s)|C],C).
adj(['a','rank'|L],L,Ind,[data(Ind, rank, a)|C],C).
adj(['b','rank'|L],L,Ind,[data(Ind, rank, b)|C],C).

adj([easy | L],L,Ind, [data(Ind, difficulty, easy)|C],C).
adj([medium | L],L,Ind, [data(Ind, difficulty, medium)|C],C).
adj([hard | L],L,Ind, [data(Ind, difficulty, hard)|C],C).

adj([slow, roll | L],L,Ind, [data(Ind, rollType, slowroll)|C],C).
adj([default | L],L,Ind, [data(Ind, rollType, default)|C],C).
adj([hyper, roll | L],L,Ind, [data(Ind, rollType, hyperroll)|C],C).


noun([team | L],L, Ind, [team(Ind)|C], C).
noun([teams | L],L, Ind, [team(Ind)|C], C).

noun([comp | L],L, Ind, [team(Ind)|C], C).
noun([comps | L],L, Ind, [team(Ind)|C], C).


noun([champion | L],L, Ind, [champion(Ind)|C], C).
noun([champions | L],L, Ind, [champion(Ind)|C], C).

noun([items | L],L, Ind, [item(Ind)|C], C).
noun([items | L],L, Ind, [item(Ind)|C], C).

% team names are nouns
noun([X | L], L, Ind, [team(X)|C] ,C) :- team(X).

% champions and items are nouns
noun([X | L],L, Ind, [has(Ind, X)|C],C) :- has(Ind, X).



% reln(L0,L1,Sub,Obj,C0,C1) is true if L0-L1 is a relation on individuals Sub and Obj

% relations used in what comp has/includes ... 
reln([has | L], L, Sub, Obj, [X|C], C).

reln([includes | L], L, Sub, Obj, [has(Sub, Obj)|C], C).
reln([included | L], L, Sub, Obj, [has(Sub, Obj)|C], C).

% relations used in what units/items does _TeamComp_ use ...
reln([uses | L], L, Sub, Obj, [has(Sub, Obj)|C], C).
reln([use | L], L, Sub, Obj, [has(Sub, Obj)|C], C).
reln([used | L], L, Sub, Obj, [has(Sub, Obj)|C], C).

% relations used item prioritization queries
reln([prioritizes | L], L, Sub, Obj, [has(Sub, Obj)|C], C).
reln([prioritized | L], L, Sub, Obj, [has(Sub, Obj)|C], C).



% question(Question, QR, Ind) is true if Ind is  an answer to Question

question(['What', is | L0], L1, Ind, C0, C1) :-
    aphrase(L0, L1, Ind, C0, C1).
question(['What' | L0], L2, Ind, C0, C2) :-
    noun_phrase(L0, L1, Ind, C0, C1), 
    mp(L1, L2, Ind, C1, C2).
question(['Which' | L0], L2, Ind, C0, C2) :-
    noun_phrase(L0, L2, Ind, C0, C2), 
    mp(L1, L2, Ind, C1, C2).


% ask(Q,A) gives answer A to question Q
ask(Q,A) :-
    get_constraints_from_question(Q,A,C),
    prove_all(C).

% get_constraints_from_question(Q,A,C) is true if C is the constaints on A to infer question Q
get_constraints_from_question(Q,A,C) :-
    question(Q,End,A,C,[]),
    member(End,[[],['?'],['.']]).


% prove_all(L) is true if all elements of L can be proved from the knowledge base
prove_all([]).
prove_all([H|T]) :-
    call(H),      % built-in Prolog predicate calls an atom
    prove_all(T).


% To get the input from a line:
q(Ans) :-
    write("Ask me: "), flush_output(current_output),
    % https://www.swi-prolog.org/pldoc/doc/_SWI_/library/readln.pl
    % http://amzi.com/manuals/amzi/pro/ref_terms.htm
    % to allow dash in hero name. e.g anti-mage
    readln(Ln, _, _, [95, 45], uppercase),
    ask(Ln,Ans).

q(Ans) :-
    write("Ask me: "), flush_output(current_output), 
    read_line_to_string(user_input, St), 
    split_string(St, " -", " ,?.!-", Ln), % ignore punctuation
    ask(Ln, Ans).
q(Ans) :-
    write("No more answers\n"),
    q(Ans).
   


% Tests
/*
?- q(Ans).
Ask me: What is a comp that uses Lucian?
Ans = 
false.

?- q(Ans).
Ask me: What comp should I go if I prioritize a recurve bow?
Ans = 
false.

?- q(Ans).
Ask me: Which comps use Lucian?
Ans = 
false.

Some more questions:
What is an S tier comp that uses
What is a hyper-roll comp that prioritizes recurve bow?
What champions are use in the 
*/