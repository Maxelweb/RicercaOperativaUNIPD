# ==============================
#		  Modello AMPL
#	qCloud - Ricerca operativa
#		Mariano Sciacco
#			(2019)
# ==============================




# Insiemi del modello

set I; # tipi di server 
set J; # nodi hardware

param Peso{I}; # Peso del server
param Costo{I}; # Costo di un singolo server

param Risorse{J}; # Punti risorsa nodo
param Posizione{J}; # Posizione nodo
param Virtual{J}; # Virtualizzazione presente o meno

param CostoWattMese > 0; # Costo mensile W
param MaxEccessoServer < 5 integer; # Massimo eccesso server

param Richieste{I}; # Server richiesti all'azienda


# Controlli

check{i in I} : Peso[i] <= 4;
check{i in I} : Peso[i] >= 0; 

check{i in I} : Costo[i] > 0;

# Controlla che le richieste non siano maggiori di quello che i nodi possono offrire 
check : sum{j in J} Risorse[j] >= sum{i in I} Peso[i]*Richieste[i]; # importante! 

