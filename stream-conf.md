# Paul Feautrier : Streaming in the Polyhedral Model: CRP and Syntol
L'opération c'est le grain, pmake par exemple (parallele make) : la compilation d'un fichier C.

Langage DF :
 * Alpha (Quinton, Mauras)
 * Lucid, Sisal
 * synchrone : Lustre, Signal

## Streamming
 programme dans une boucle infine qui consomme et produit des données.

La boucle peut être :
 * implicite : KPN, SDF, Lustre
 * explicite : CRP, OpenStream

## Communication
Différents moyens :
 * Cannaux (synchronisation explicite) :
  * FIFO (comme KNP)
  * Sliding window (Stream-It, OpenStream)
 * Mémoire partagée (synchronisation implicite)

## CRP : Communicating Regular Processes
Syntol : compilateur

http://perso.ens-lyon.fr/paul.feautrier/Html/FEAUTRIER-P.html

L'ordonnanceur suit une relation de causalité, si A dépend de B, A ne s'écutera avant la fin de B.

Ordonnancement par processus.

# Albert Cohen : Dynamic Streaming: Applications, Constructs and Challenges
Le streamming est un concept qui vient des réseaux de Khan.

Bulk Volume Parallel.

Streamig, découplage : load -> compute -> store

Bulk Synchronous Parallel

Cilk

A relax with work-stealing output: Lê et al., PPoPP 2013

Scheduling & FIFO basé sur la hardware et la cohérence de cache hardware sont plus rapide (x10).

# Lionel Morel : Runtime Monitoring of Throughput-Constrained Dataflow Programs
Rajout de la notion de débit dans Stream-It.

Monitoring pour savoir où ça bloque (ou le débit attendu est supérieur au débit réel).

Se base sur du Static DF (pas d'ajout "d'acteurs" dynamique), pour faire du partage
de ressources avec des programmes externes.

Prise de décision pour rétablire le débit (par exemple : changement de coeur).

On cherche à garantir des débits minimaux sur des environnements partagés.

# Yann Orlarey : Embedding the Faust compiler
DSL de traitement de signal (audio par exemple) en temps réel.

Proche du Lambda-Calculus (pour l'évaluation)

# Vagelis Bebelis : Boolean Parametric Data Flow
Les noeuds envois un message à d'autres noeuds sur un canal dédié pour changer leur comportement.

# Marc Pouzet
Simulink

Scale = Lustre ++

