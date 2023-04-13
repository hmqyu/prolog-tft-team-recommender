%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        IMPORTS         %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- include('import_csv.pl').
:- include('recommender_util.pl').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%        STARTER         %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load database
setup :- init.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    RECOMMENDER QUIZ    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% shorthand for recommend ap
r :- recommend.

% the app that recommends a tft comp given the users' inputs
recommend :-
    writeln('-------------------------------------------------------------------------------'),
    writeln('----------------         Teamfight Tactics Recommender         ----------------'),
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('This app was built to help Teamfight Tactics players figure out what team comp '),
    writeln('they can make, given their current board status.'),
    writeln('A set of questions will be asked to determine the best team comps you can make.'),
    nl,
    writeln('Let\'s begin!'),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('What difficulty level are you comfortable playing at?'),
    writeln('> Easy \n> Medium \n> No Preference'),
    nl,
    readln(InputDifficulty, _, _, [39, 45, 95], lowercase),
    format_word_inputs(InputDifficulty, Difficulty),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('What roll type would you like to play?'),
    writeln('> Slow Roll \n> Default \n> No Preference'),
    nl,
    readln(InputRollType, _, _, [39, 45, 95], lowercase),
    format_word_inputs(InputRollType, RollType),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the different units you currently have. Separate them with a comma.'),
    writeln('Eg. Kai\'sa Alistar Nilah Rell.'),
    writeln('You don\'t need to list units multiple times - just once is enough!'),
    writeln('If you have none, press enter.'),
    nl,
    readln(Units, _, _, [39, 45, 95], lowercase),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the item components you currently have. Separate them with a comma.'),
    writeln('Eg. Sword Bow Rod'),
    writeln('You don\'t need to list items multiple times - just once is enough!'),
    writeln('If you have none, type \'none\' or press enter.'),
    nl,
    readln(InputItems, _, _, [39, 45, 95], lowercase),
    format_item_inputs(InputItems, Items),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the silver augment(s) you currently have. Separate them with a comma.'),
    writeln('If you have none, type \'none\' or press enter.'),
    nl,
    readln(InputSilverAugments, _, _, [39, 45, 95], lowercase),
    format_augment_inputs(InputSilverAugments, SilverAugments),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the gold augment(s) you currently have. Separate them with a comma.'),
    writeln('If you have none, type \'none\' or press enter.'),
    nl,
    readln(InputGoldAugments, _, _, [39, 45, 95], lowercase),
    format_augment_inputs(InputGoldAugments, GoldAugments),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the prismatic augment(s) you currently have. Separate them with a comma.'),
    writeln('If you have none, type \'none\' or press enter.'),
    nl,
    readln(InputPrismaticAugments, _, _, [39, 45, 95], lowercase),
    format_augment_inputs(InputPrismaticAugments, PrismaticAugments),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('List the hero augment(s) you currently have. Separate them with a comma.'),
    writeln('If you have none, type \'none\' or press enter.'),
    nl,
    readln(InputHeroAugments, _, _, [39, 45, 95], lowercase),
    format_augment_inputs(InputHeroAugments, HeroAugments),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('Your team comp recommendations are being generated.'),
    writeln('Please select the format you\'d like them to be displayed in:'),
    writeln('> Brief (Units, Carousel Priority) \n> Summary (Name, Rank, Units, Traits, Carousel Priority) \n> Detailed'),
    nl,
    readln([Format], _, _, [39, 45, 95], lowercase),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('Here are you team comp recommendations!'),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    findTeam(Teams, Difficulty, RollType, Items, Units, SilverAugments, GoldAugments, PrismaticAugments, HeroAugments),
    writeTeams(Teams, Format).

% displays teams using given format
writeTeams([], _).
writeTeams([Team | Teams], brief) :- 
    nl, brief_display(Team),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    writeTeams(Teams, brief).
writeTeams([Team | Teams], summary) :- 
    nl, summary_display(Team),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    writeTeams(Teams, summary).
writeTeams([Team | Teams], detailed) :- 
    nl, detailed_display(Team),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    writeTeams(Teams, detailed).

% print brief description of team comps
brief_display(Team) :- 
    write('Units: '), data(Team, units, Units), write(Units),
    nl,
    write('Carousel Priority: '), data(Team, carousel_priority, Items), write(Items),
    nl.

% print a summary of team comps
summary_display(Team) :- 
    write('Name: '), write(Team),
    nl,
    write('Rank: '), data(Team, rank, Rank), write(Rank),
    nl,
    write('Traits: '), print_traits(Team),
    nl,
    brief_display(Team).

% print all details about team comps
detailed_display([]).
detailed_display(Team) :- 
    summary_display(Team),
    write('Description: '), data(Team, description, Description), write(Description),
    nl,
    write('Roll Type: '), data(Team, roll_type, RollType), write(RollType),
    nl,
    write('Difficulty: '), data(Team, difficulty, Difficulty), write(Difficulty),
    nl.

% print all active traits of a team comp
print_traits(Team) :-
    find_traits_with_value(Team, 10).

% find traits with an active value of Acc
find_traits_with_value(_, 0).
find_traits_with_value(Team, Acc) :-
    Acc > 0,
    findall(Trait, (data(Team, Trait, Acc)), Traits),
    format_trait_string(Traits, Acc),
    NextAcc is Acc - 1,
    find_traits_with_value(Team, NextAcc).

% print all traits with an active value of Value
format_trait_string([], _).
format_trait_string([Trait | Traits], Value) :-
    write(Value), write('-'), write(Trait), write(' '),
    format_trait_string(Traits, Value).

% format one-word inputs appropriately
format_word_inputs(['none'], []).
format_word_inputs(Input, Output) :- atomic_list_concat(Input, ' ', Output).

% format augment names appropriately
format_augment_inputs([], []).
format_augment_inputs(['none'], []).
format_augment_inputs(Input, [Result]) :-
    remove_spaces(Input, Result).

% removes spaces in a given string
remove_spaces(Input, Result) :-
    atomic_list_concat(Input, Result).

% formats item names appropriately
format_item_inputs([], []).
format_item_inputs(['none'], []).
format_item_inputs([Input | Items], [Result | CorrectItems]) :-
    de_abbreviate(Input, Result),
    format_item_inputs(Items, CorrectItems).

% converts abbreviated item names to their proper names
de_abbreviate('sword', 'bf sword').
de_abbreviate('b.f. sword', 'bf sword').
de_abbreviate('chain', 'chain vest').
de_abbreviate('vest', 'chain vest').
de_abbreviate('belt', 'giants belt').
de_abbreviate('giant\'s belt', 'giants belt').
de_abbreviate('rod', 'needlessly large rod').
de_abbreviate('cloak', 'negatron cloak').
de_abbreviate('bow', 'recurve bow').
de_abbreviate('gloves', 'sparring gloves').
de_abbreviate('glove', 'sparring glove').
de_abbreviate('spat', 'spatula').
de_abbreviate('tear', 'tear of the goddess').


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%    NLP (UNFINISHED)    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

q(Answer) :-
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