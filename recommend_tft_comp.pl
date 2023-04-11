:- include('import_csv.pl').
:- include('recommender_system.pl').

% the app that recommends a tft comp given the users' inputs
recommend :-
    init,
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
    readln(Format, _, _, [39, 45, 95], lowercase),
    nl,
    writeln('-------------------------------------------------------------------------------'),
    nl,
    writeln('Here are you team comp recommendations!'),
    nl,
    % writeln(Difficulty),writeln(RollType),writeln(Units),writeln(Items),
    % write(SilverAugments),write(GoldAugments),write(PrismaticAugments),write(HeroAugments),
    findTeam(Teams, Difficulty, RollType, Items, Units, SilverAugments, GoldAugments, PrismaticAugments, HeroAugments),
    writeTeams(Teams, Format).

% displays teams using given format
writeTeams(Teams, [brief]) :- brief_display(Teams).

brief_display([]).
brief_display([Team | Teams]) :- 
    writeln('-------------------------------------------------------------------------------'),
    nl,
    write('Units: '), data(Team, units, Units), write(Units),
    nl,
    write('Carousel Priority: '), data(Team, carousel_priority, Items), write(Items),
    nl,
    brief_display(Teams).

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