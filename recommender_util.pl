% find recommended teams
findTeam(Teams, Difficulty, RollType, Items, Units, SilverAugments, GoldAugments, PrismaticAugments, HeroAugments) :-
    findall(Team, (
        findTeamWithDifficulty(Team, Difficulty),
        findTeamWithRollType(Team, RollType),
        hasItems(Team, Items),
        hasUnits(Team, Units),
        hasAugments(Team, silver_augments, SilverAugments),
        hasAugments(Team, gold_augments, GoldAugments),
        hasAugments(Team, prismatic_augments, PrismaticAugments),
        hasAugments(Team, hero_augments, HeroAugments)
    ), Unsorted),
    sortByRank(Unsorted, Teams).


% if no preference, return all teams
% otherwise find team with given difficulty
findTeamWithDifficulty(Team, 'no preference') :- data(Team, difficulty, _).
findTeamWithDifficulty(Team, Difficulty) :- data(Team, difficulty, Difficulty).


% if no preference, return all teams
% otherwise find team with given roll type
findTeamWithRollType(Team, 'no preference') :- data(Team, roll_type, _).
findTeamWithRollType(Team, RollType) :- data(Team, roll_type, RollType).


% check if team includes some of the given items
hasItems(Team, Items) :- 
    % Length > 3,
    data(Team, carousel_priority, PriorityItems),
    subset(Items, PriorityItems).


% check if team includes some of the given units
hasUnits(Team, Units) :- 
    data(Team, units, CompUnits),
    subset(Units, CompUnits).


% check if team includes some of the given augments
% if empty, fetch all teams
findTeamWithRollType(Team, Key, []) :- data(Team, Key, _).
hasAugments(Team, Key, Values) :- 
    data(Team, Key, Augments),
    subset(Values, Augments).


% sorts the list by their given rank
sortByRank(Unsorted, Sorted) :-
    findall(BTeam, (data(BTeam, rank, b), member(BTeam, Unsorted)), BTeams),
    findall(ATeam, (data(ATeam, rank, a), member(ATeam, Unsorted)), ATeams),
    findall(STeam, (data(STeam, rank, s), member(STeam, Unsorted)), STeams),

    append(STeams, ATeams, TempTeams),
    append(TempTeams, BTeams, Sorted).
