# Programmation Data-flow

Gautier DI FOLCO

## Introduction
Ce document vise à donner un premier aperçu de ma compréhension du sujet
ainsi que des pistes trouvées qui seront vraisemblablement suivit lors du PFE.

Le data-flow programming est décrit [1] comme un paradigme de programmation faisant
partie des paradigmes déclaratifs, par opposition aux paradigmes impératif.
On peut signaler que cette description est erronée car cela impliquerait d'avoir
un programme n'ayant aucun effet de bords, ce qui n'est pas le cas de toutes les
implémentations actuelle.

L'essence même du data-flow [1] est d'être en mesure de structurer les programmes
(le Data-flow est donc plus proche d'une famille de design patterns structurels)
en mettant en avant l'information traitée au seins des différentes partie du
programme.

Le programme est donc réduit à un ensemble de _noeuds_ qui manipulent les données
et des _arcs_ qui représentent les "_communications_" entre ces noeuds, ou plutôt
le chemin des données et les traitements successifs de celles-ci par le système.

Il existe trois sous-famille de langages de programmation data-flow : flow-based,
cell-oriented et reactive. À part l'approche cell-oriented (qui ne sera pas
traité ici car son domaine d'application est restreinte aux feuilles de calculs,
qui ne permettent pas d'avoir une conduite de projet ou de réaliser des programmes
qui passent à l'échelle) ces deux familles sont détaillés ci-dessous.

## Flow-based
### Principes
La programmation flow-based reprend cette idée de _noeuds communicants_ en ajoutant
une notion de tamporisation des communications entre les noeuds. Les
communications se font par passage de message et ce principe est partagé par
le modèle à acteurs [2] dont Erlang [3], Akka [4] et celluloid [5].

### Bénéfices
L'apport de cette approche est de permettre d'avoir une certaine asynchronicité
dans le système, qu'elle doit maîtriser, en temps (au bout d'un certain délais,
le message est supprimé) ou en nombre (quand le nombre de messages en attente
dépasse un certain nombre, les nouveaux ou les plus anciens sont supprimés).

Cette asynchronicité permet d'une part de pouvoir distribuer le déroulement du
programme, puisque l'asynchronicité sera absorbé par les latences réseaux; et
d'autre part la possibilité de faire du traitement batch à l'aide d'outils comme
hadoop [6].

## Reactive
### Principes
La programmation vise à réagir à des _événements_ en appliquant des _comportement_
sur ceux-ci. Ces événements sont deplus ordonnés par leur date de création dans
le système.

### Historique
De nombreuses implémentations ont eu lieux en Haskell [7] car, s'agissant d'un
langage de programmation fonctionnelle pure les effets de bords ne peuvent
être représentés que par transitions explicites, deplus le système de type
était assez puissant pour supporter aisément une telle logique ce qui a permit
d'avoir des implémentations fiables relativement aisément.

Cette investissement massive du monde de la programmation fonctionnelle dans le
domaine à même créer une sous-famille à part entière nommée la programmation
réactive fonctionnelle (functial reactive programming) [13].

De plus cette notion de contrôle de flux d'un programme a été repris sous le
nom d'event sourcing [8]. Ce concept a été ensuite remis au goût du jour avec
l'iintroduction du CQRS [9] (Command Query Responsability Segregation), lui-même
dérivé de Domain Driven Design [10].

Parmis ses implémentations nous pouvons citer yampa [11, 12];
reactive banana [12] et sodium [15] qui d'une part considère que la variation
temporelle est un événement à part entière (contrairement à la quasi-totalité
des autres implémentation du fait que la notion de comportement soit fortement
couplé au temps), mais qui plus est les auteurs se sont aperçuts que le coeur
de leur code sont le même au nom près [16].

### Bénéfices
Le premier avantage de l'ordre des événements est la reproductibilité des situations,
ce qui aide considérablement durant la recherche et la correction de bugs.

Deplus, comme le fait le CQRS, il est possible d'intéprêter différemment les événements,
ainsi en cas d'évolution du système, rien n'est perdu et un grand nombre de données
sont déjà présentes.

Enfin, le fait que de nombreux travaux ais été conduits en Haskell sur le sujet,
le système de type à fait que la composabilité, donc l'extensibilité et la maîtrise
de la complexité d'une application, est au premier plan.


## Conclusions
Le Data-flow tente de résoudre des problèmes de souplesse des programmes et de
passage à l'échelle en mettant le flux de traitement des données au centre de la
l'architecture logicielle.

Cette étude pourra donc se concentrer sur la nature profonde de la programmation
data-flow, en comparant les différentes approches existante.

D'autres questions comme le typage ou l'expressivité pourront également se poser
durant cette étude.

## Références
[1] http://en.wikipedia.org/wiki/Dataflow_programming
[2] Carl Hewitt. Viewing Control Structures as Patterns of Passing Messages Journal of Artificial Intelligence. June 1977.
[3] http://www.erlang.org/
[4] http://akka.io/
[5] http://celluloid.io/
[6] http://hadoop.apache.org/
[7] http://www.haskell.org/haskellwiki/Haskell
[8] http://martinfowler.com/eaaDev/EventSourcing.html
[9] http://www.infoq.com/presentations/Events-Are-Not-Just-for-Notifications
[10] Evans, Eric (2004), Domain-Driven Design — Tackling Complexity in the Heart of Software, Addison-Wesley.
[11] http://www.haskell.org/haskellwiki/Yampa
[12] http://www.haskell.org/haskellwiki/Reactive-banana
[13] Zhanyong Wan,Paul Hudak (2000),Functional reactive programming from first principles
[14] Paul Hudak, Antony Courtney, Henrik Nilsson, John Peterson (2003), Arrows, Robots, and Functional Reactive Programming
[15] http://blog.reactiveprogramming.org/
[16] http://blog.reactiveprogramming.org/?p=136
