% the actual app

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

noun_phrase(L0,L4,Entity,C0,C4) :-
    proper_noun(L0,L4,Entity,C0,C4).

% Determiners (articles) are ignored in this oversimplified example.
% They do not provide any extra constraints.
det(["the" | L],L,_,C,C).
det(["a" | L],L,_,C,C).
det(["an" | L],L,_,C,C).
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
mp(["that"|L0],L2,Subject,C0,C2) :-
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


% adjectives
% roll type, rank(?)

% nouns
% traits, champions??, item priority/items

% proper nouns
proper_noun([X | L],L,X, C,C) :- prop(X, type, team_name).
proper_noun([X | L],L,X, C,C) :- prop(X, type, augment).
proper_noun([X | L],L,X, C,C) :- prop(X, type, champion).

% verbs/relations

$ relations used in "what team"
reln([includes | L],L,O1,O2, [prop(O1, *, O2) | C],C).
reln([uses | L],L,O1,O2, [prop(O1, *, O2) | C],C).

% Tests
/*
?- q(Ans).
Ask me: What is a comp that uses Lucian?
Ans = 
false.

?- q(Ans).
Ask me: What comp should I go if I start with a recurve bow?
Ans = 
false.

Some more questions:

*/