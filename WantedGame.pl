%PROJECT NAME: WANTED - A game of deduction
%TEAM NAME: ENGELSKA PARKEN
%TEAM MEMBERS: Ioanna Dimadi, Niklas Wietreck, Andrew Owen Ssembatya

%necessary predicates
:- use_module(library(random)).
:-dynamic murderer/3, person/4, tries/1.

%Attributes
age_gender([oldman,oldwoman,youngman,youngwoman]).
color([blue,brown,green,yellow]).
weapon([gun,knife,poison]).

%game start
start:-
    clear_database,
	  number_of_posibilities(_),
    intro,
    get_murderer(X,Y,Z),
    assert(murderer(X,Y,Z)),
    ask_user_input.

%Ask for user imput
ask_user_input:-
	nl,
	write('Type n. to generate new person or g. to guess (press h. for help):'),
	read(Value),
	action(Value).


%User Actions
action(n):-
	check_if_finished,
	write('You are out of persons Mr/Mrs.Holmes!! You have to make a guess now.'),
	nl,make_guess.

action(n):-
	list_people,
	get_person.

action(g):-
	list_people,
	make_guess.

action(r):-
	restart.

action(h):-
	help.

action(_):-
	write('!!Please enter Correct key!!'),nl,
	ask_user_input.


%show the murderer

show_murderer:-
   murderer(X,Y,Z),
   write('The murderer was a '),
   write(X), write(' dressed in '),
   write(Y), write(' with a '),
   write(Z).

%murderer stored in secret

get_murderer(X,Y,Z):-
	find_random_gender(X),
	find_random_color(Y),
	find_random_weapon(Z).

%get list count
	get_list_count(List,Count):-
	length(List,Count).

%Attribute Randomisations
%Finding Random Gender
	find_random_gender(X):-
	count_agegender(Count),
	N is Count + 1,
	random(1, N, R),
	get_gender_from_list(R,X).

get_gender_from_list(R,X):-
	age_gender(Y),
	find_element(R,Y,X).

%Finding Random color
find_random_color(X):-
	count_color(Count),
	N is Count + 1,
	random(1,N, R),
	get_color_from_list(R,X).

get_color_from_list(R,X):-
	color(Y),
	find_element(R,Y,X).

%Finding Random weapon
find_random_weapon(X):-
	count_weapon(Count),
	N is Count + 1,
	random(1,N, R),
	get_weapon_from_list(R,X).

get_weapon_from_list(R,X):-
	weapon(Y),
	find_element(R,Y,X).


%find element base case
	find_element(1,[X|_],X).

find_element(N,[_|Rest],Z):-
	N > 1,
	N1 is N -1,

find_element(N1, Rest, Z).

%get person clause
get_person:-
    find_person(X,Y,Z, Category),
	  no_duplicates(X,Y,Z,Category),
	  assert(person(X,Y,Z,Category)),nl,
 	  write('SELECTED PERSON: '),write(X),write(' '),
	  write(Y),write(' '),
	  write(Z),write(' is '),
	  write(Category),
	  nl,nl,
	  write('################################################'),nl,nl,
	  ask_user_input.


find_person(X,Y,Z, Category):-
	find_random_gender(X),
	find_random_color(Y),
	find_random_weapon(Z),
	not_murderer(X,Y,Z),
	compare(X,Y,Z,Category).

%make guess clause
make_guess:-
	nl,
	guess_agegender(X),
	guess_color(Y),
	guess_weapon(Z),
	check_if_murderer(X,Y,Z).

%make attribute guesses

guess_agegender(X):-
	write('Guess the gender and age. i.e. oldwoman. '),
	read(X),
	is_agegender_valid(X),!.

guess_agegender(_):-
	write('The AGE_GENDER you entered DOES NOT exist. Guess Again!!'),nl,nl,nl,
	guess_agegender(_).

guess_color(Y):-
	write('Guess the color. i.e. blue.'),
	read(Y),
	is_color_valid(Y),!.

guess_color(_):-
	write('The COLOR you entered DOES NOT exist. Guess Again!!'),nl,nl,nl,
	guess_color(_).

guess_weapon(Z):-
	write('Guess the weapon. i.e. knife.'),
	read(Z),
	is_weapon_valid(Z),!.

guess_weapon(_):-
	write('The WEAPON you entered DOES NOT exist. Guess Again!!'),nl,nl,nl,
	guess_weapon(_).

%check if input is valid

is_agegender_valid(Age_gender):-
	age_gender(List),
	check_if_value_exists(Age_gender, List).

is_color_valid(Color):-
	color(List),
	check_if_value_exists(Color, List).

is_weapon_valid(Weapon):-
	weapon(List),
	check_if_value_exists(Weapon, List).

%check if value exists in list

check_if_value_exists(Value, [Value|_]).

check_if_value_exists(Value, [_|Rest]):-
	 check_if_value_exists(Value, Rest).


%check for duplicate persons
no_duplicates(X,Y,Z,Category):-
	check(X,Y,Z,Category),
	get_person.

no_duplicates(_,_,_,_).

check(X,Y,Z,Category):-
	person(X,Y,Z,Category).

%compare person with murderer/ get persons category
compare(X,Y,Z,'Innocent'):-
	murderer(A,B,C),
	X \== A,
	Y \== B,
	Z \== C.

compare(X,Y,Z,'Suspect'):-
	murderer(A,B,C),
	(X = A;
	Y = B;
	Z = C),!.


%Check that Person isnt a murderer
not_murderer(X,Y,Z):-
	murderer(X,Y,Z),
	get_person.

not_murderer(_,_,_).

check_if_murderer(X,Y,Z):-
	murderer(X,Y,Z),
	write('Congratulations. You Win. '),
	count_tries(N),
	write('Your deduction required '),write(N),write(' persons!'),!,
	nl,
	user_restart.

check_if_murderer(_,_,_):-
	write('You Lose.'),
	nl,nl,show_murderer,nl,
	user_restart.

%show list of people
list_people:-
	findall((Gender,Color,Weapon), person(Gender,Color,Weapon,'Suspect'),Suspect_list),
	nl,
	write('SUSPECTS'),nl,
	printlist(Suspect_list),
	nl,nl,
	findall((Gender,Color,Weapon), person(Gender,Color,Weapon,'Innocent'),Innocent_list),
	nl,
	write('INNOCENTS'),nl,
	printlist(Innocent_list),nl.

%printing lists
printlist([]).

printlist([X|List]) :-
      write(X),nl,
      printlist(List).

%counting number of tries list
count_tries(X) :-
    findall(N, person(N,_,_,_), List),
    length(List, X).

%program restart
restart:-
	start.

%User restarts the game
user_restart:-
  nl,
  write('Do you want to play it again? Press r to restart!'),
  read(Value),
  action(Value).

%clearing program database
clear_database:-
  retractall(person(_,_,_,_)),
  retractall(murderer(_,_,_)),
  retractall(tries(_)).

%Game intro
intro:-
	tries(N),
	nl,
	write('WELCOME to Brixton Mr/Mrs.Sherlock Holmes.'),nl,
	write('A crime has been committed and we need your help finding '),nl,
	write('out who the culprit is.'),nl,
	write('We have '), write(N), write(' people we can link to the Murderer.'),nl,
	write('We have faith in you Mr/Mrs. Holmes.'),nl,nl.

%Game help
help:-
    tries(N),
	nl,
	write('HELP:'),nl,
	write('******actions******'),nl,
	write('-(n.) -> Request a new person!'),nl,
	write('-(g.) -> Make a guess!'),nl,
	write('-(r.) -> Restart the game!'),nl,
	write('-(h.) -> Ask your help!'),nl,
	nl,
	write('******rules********'),nl,
	write('1. The murderer has 3 different attributes: Age-gender, Color, Weapon'),nl,
	write('2. Innocents have no matching attribute with the murderer!'), nl,
	write('3. Suspects have at least 1 matching attribute with the murderer!'), nl,
	write('4. All persons are unique and are only shown once!'),nl,
	write('5. The actual murderer will NEVER appear as a suspect or innocent!'),nl,
	write('6. A list of suspects and innocents will always be shown to support your investigation!'),nl,
	write('7. The game will end after the last person appears!'),nl,
	write('8. You will have only '), write(N), write(' chances to guess the murderer'),nl,nl,
	ask_user_input.

%Calculate number of possibilities
number_of_posibilities(Number):-
    count_agegender(X),
    count_color(Y),
    count_weapon(Z),
    Number is (X * Y * Z - 1),
	  assert(tries(Number)).

%count variables

count_agegender(Count):-
   age_gender(List),
   get_list_count(List,Count).

count_color(Count):-
   color(List),
   get_list_count(List,Count).

count_weapon(Count):-
   weapon(List),
   get_list_count(List,Count).

%check if users tries are finished and game is done
check_if_finished :-
	tries(Count),
	count_tries(Tries),
	Count =:= Tries.
