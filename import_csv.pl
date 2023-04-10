:- use_module(library(csv)).
:- use_module(library(lists)).
:- use_module(library(persistency)).

:- persistent data(team:atom, key:atom, value:atom).

init :-
    working_directory(_, 'data'),
    csv_read_file('teams.csv', Rows, [arity(7), skip_header('Team Name')]), 
    load_rows(Rows).

load_rows([]).
load_rows([Row|Rows]) :-
    % load data
    Row = row(Name, Description, RollType, Difficulty, Rank, Units, CarouselPriority),
    % add data to kb
    assert(data(Name, description, Description)),
    assert(data(Name, roll_type, RollType)),
    assert(data(Name, difficulty, Difficulty)),
    assert(data(Name, rank, Rank)),
    assert_list(Name, units, Units),
    assert_list(Name, carousel_priority, CarouselPriority),
    load_rows(Rows).

assert_list(Name, Key, Value) :-
    atomic_list_concat(List, ', ', Value),
    assert(data(Name, Key, List)).