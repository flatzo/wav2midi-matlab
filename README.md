Etapes de traitement
====================

Spectrogramme multirésolution
-----------------------------

* Plusieurs FFT avec des fenêtres de taille dfférentes.
 * Les basses fréquences nécessites des fenêtres plus larges 
   pour obtenir une précision suffisante pour reconnaître la
   note du à l'aspect logarithmique des games.

Enveloppe
---------

* Savitzky-Golay
 * Smoothing
 * Smoothing + 2ième dérivée

Détections des peaks
--------------------

1. Utilisation de la seconde dérivée pour connaître le momment de l'attaque
2. Vérifier l'amplitude pour valider la note.

Suivre la note
--------------

Enregistrer la note comme terminée seulement lorsque son amplitude descends en dessous d'un certain seuil.

Ecriture de fichier midi
------------------------

Utilisation de code existant.
Source : https://github.com/kts/matlab-midi

### Amélioration 

Sortir les notes directement du spectrogramme. Plus simple gérer une seule échelle. 

Avenues abandonnées
===================

HPS (Harmonic Product Spectrum)
-------------------------------

Perte des basses fréquences encore plus prononcé. Hausse de l'écart.

Avenues à explorer
==================

Ondelettes
----------

