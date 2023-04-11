% this class is used to extract data from a csv file that is formatted a specific way
% or will automatically derive a format based on the columns, under the assumption that
% the first column represents a primary key/unique id for the row's values.
% data from the csv file will be converted into a knowledge base that the overall program can use
% to look up information about different team comps for Teamfight Tactics.

:- use_module(library(persistency)).

% represents how the csv data is stored
% team is the identifier and is the name of the team comp
% key represents the different column name (excluding name as it's used as our identifier)
% value is what is stored at the given team and key pair in the csv file
:- persistent data(team:atom, key:atom, value:atom).

%%%%%%%%%%%%%%%%%%%%%%%
%%%%   FUNCTIONS   %%%%
%%%%%%%%%%%%%%%%%%%%%%%

% init is true if the required csv files can be located and read
% and converted into the stated knowledge base
init :-
    % make a save of the current directory
    working_directory(CurrentPath, CurrentPath),
    % change working directory to the data folder in order to access the csv files
    working_directory(_, 'data'),
    % load required csv files
    load_teams,
    load_synergies,
    load_augments,
    % change working directory back to the main project folder
    % change the working directory to the parent directory
    working_directory(_, CurrentPath).

% load_teams is true if the teams.csv file can be located and read
% and converted into the stated knowledge base
load_teams :-
    % read file and store csv rows as Rows
    % file is interpreted with arity=7 or number of columns=7, and skips the header row
    csv_read_file('teams.csv', Teams, [arity(7), skip_header('Team Name')]),
    % converts each row to be stored in the knowledge base
    load_team_rows(Teams).

% load_team_rows(Rows) is true if the data can be properly parsed as described below
% and is stored in the knowledge base successfully
% OR, there are no (more) rows to be stored in the knowledge base
load_team_rows([]).
load_team_rows([Row | Rows]) :-
    % load values to be added to the knowledge base
    Row = row(Name, Description, RollType, Difficulty, Rank, Units, CarouselPriority),
    % add to knowledge base
    downcase_atom(Name, TeamName),
    remove_newline_char(Description, FixedDescription),
    assert(data(TeamName, description, FixedDescription)),
    assert(data(TeamName, roll_type, RollType)),
    assert(data(TeamName, difficulty, Difficulty)),
    assert(data(TeamName, rank, Rank)),
    assert_list(TeamName, units, Units),
    assert_list(TeamName, carousel_priority, CarouselPriority),
    % repeat for next row
    load_team_rows(Rows).

% load_synergies is true if the synergies.csv file can be located and read
% and converted into the stated knowledge base
load_synergies :-
    % read file and store csv rows as Rows
    % file is interpreted with arity=29 or number of columns=29
    csv_read_file('synergies.csv', Synergies, [arity(29)]),
    % fetches the list of traits (as traits can vary from set to set)
    Synergies = [HeaderRow | ValueRows],
    HeaderRow =.. [_ | Columns],
    % first value in columns is TeamName, which isn't a trait
    Columns = [_ | Traits],
    % converts each row with values to be stored in the knowledge base
    atomized_traits(Traits, AtomizedTraits),
    load_synergies_rows(ValueRows, AtomizedTraits).

% load_synergies_rows(Rows, Traits) is true if the data can be properly parsed
% with each trait in Traits being associated with its respective value from Rows
% for the given team composition
% OR, there are no (more) rows to be stored in the knowledge base
load_synergies_rows([], _).
load_synergies_rows([Row | Rows], Traits) :-
    % for each trait in Traits, add its respective value to the knowledge base
    Row =.. [_ | Values],
    Values = [Name | TraitValues],
    downcase_atom(Name, TeamName),
    load_traits(TeamName, Traits, TraitValues),
    % stop backtracking
    !,
    load_synergies_rows(Rows, Traits).

% load_traits(TeamName, TraitRows, TraitValueRows) is true if
% the current teamname - trait - value set can be stored in the knowledge base
% OR, there are no (more) rows to be stored in the knowledge base
load_traits(_, _, []).
load_traits(_, [], _).
load_traits(TeamName, TraitRows, TraitValueRows) :-
    TraitRows = [Trait | Traits],
    TraitValueRows = [Value | TraitValues],
    assert(data(TeamName, Trait, Value)),
    load_traits(TeamName, Traits, TraitValues).

% load_augments is true if the augments.csv file can be located and read
% and converted into the stated knowledge base
load_augments :-
    % read file and store csv rows as Rows
    % file is interpreted with arity=5 or number of columns=5, and skips the header row
    csv_read_file('augments.csv', Augments, [arity(5), skip_header('Team Name')]),
    % converts each row to be stored in the knowledge base
    load_augments_rows(Augments).

% load_team_rows(Rows) is true if the data can be properly parsed as described below
% and is stored in the knowledge base successfully
% OR, there are no (more) rows to be stored in the knowledge base
load_augments_rows([]).
load_augments_rows([Row | Rows]) :-
    % load values to be added to the knowledge base
    Row = row(Name, BestSilverAugments, BestGoldAugments, BestPrismaticAugments, BestHeroAugments),
    % add to knowledge base
    downcase_atom(Name, TeamName),
    assert_list(TeamName, silver_augments, BestSilverAugments),
    assert_list(TeamName, gold_augments, BestGoldAugments),
    assert_list(TeamName, prismatic_augments, BestPrismaticAugments),
    assert_list(TeamName, hero_augments, BestHeroAugments),
    % repeat for next row
    load_augments_rows(Rows).


%%%%%%%%%%%%%%%%%%%%%%%
%%%%%   HELPERS   %%%%%
%%%%%%%%%%%%%%%%%%%%%%%

% assert_list(Name, Key, Value) is true if the given Value can be converted to a list
% and is successfully stored in the knowledge base
% some of our keys store multiple values, so they were all added into one list value for easy access
assert_list(Name, Key, Value) :-
    % convert value to list by splitting on a given delimiter
    atomic_list_concat(List, ', ', Value),
    % add to knowledge base
    assert(data(Name, Key, List)).

% remove_newline_char(Initial, Result) is true if it finds '\n' at the end of Initial and removes it to form Result
% OR, there is no '\n' at the end of Initial, so Initial = Result
% case: there is no \n, so no deletion should occur
remove_newline_char(Initial, Initial) :-
    sub_atom(Initial, _, 1, 0, C),
    C \= '\n',
    % stop backtracking, ie. false from appearing when this or next case fails
    !.
% case: there is \n, so deletion should occur
remove_newline_char(Initial, Result) :- 
    sub_atom(Initial, _, 1, 0, '\n'), 
    sub_atom(Initial, 0, _, 1, Result).

% atomized_traits(Traits, AtomizedTraits) is true if AtomizedTraits is the same as
% Traits, except each string has been "atomized" such that the strings contain
% no special symbols, except for underscores which replace any spaces in the strings
atomized_traits(Traits, AtomizedTraits) :-
    % convert to lowercase
    maplist(downcase_atom, Traits, LowercaseTraits),
    % convert to list of chars to check for special characters and spaces
    maplist(atom_chars, LowercaseTraits, TraitsAsChars),
    % remove special characters and replace spaces with underscores
    maplist(atomize_string, TraitsAsChars, AtomizedChars),
    % convert list of chars back into atoms
    maplist(atom_chars, AtomizedTraits, AtomizedChars).

% atomize_string(Chars, AtomizedChars) is true if AtomizedChars includes all values of Chars
% except any spaces in Chars have been replaced with an underscore
% and any special characters in Chars have been removed
atomize_string([], []).
atomize_string([Initial | Chars], [Initial | AtomizedChars]) :-
    % checks that the character is alphanumeric
    code_type(Initial, alnum),
    % stop backtracking
    !,
    atomize_string(Chars, AtomizedChars).
% case: convert space to underscore
atomize_string([Initial | Chars], ['_' | AtomizedChars]) :-
    % check that the character is a space
    Initial = ' ',
    % stop backtracking
    !,
    atomize_string(Chars, AtomizedChars).
% case: removes all other special characters
atomize_string([_ | Chars], AtomizedChars) :- atomize_string(Chars, AtomizedChars).