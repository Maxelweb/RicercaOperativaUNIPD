# ==============================
#		  Modello AMPL
#	qCloud - Ricerca operativa
#		Mariano Sciacco
#			(2019)
# ==============================




# Insiemi del modello

set I ordered; # tipi di server 
set J ordered; # nodi hardware

param Peso{I} # Peso del server
param Costo{I} # Costo di un singolo server

param Risorse{J}; # Punti risorsa nodo
param Posizione{J}; # Posizione nodo
param Virtual{J}; # Virtualizzazione presente o meno

param CostoWattMese; # Costo mensile W
param MaxEccessoServer; # Massimo eccesso server

param Richieste{I} # Server richiesti all'azienda