# ==============================
#		  Modello AMPL
#	qCloud - Ricerca operativa
#		Mariano Sciacco
#			(2019)
# ==============================




# Insiemi del modello

set I; # tipi di server 
set J; # nodi hardware
set Bool; # insieme ausiliario per i booleani
set NotVirt; # insieme ausiliario che indica le macchine non virtualizzabili

# Parametri del modello

param Peso{I}; # Peso del server
param Costo{I}; # Costo di un singolo server

param Risorse{J}; # Punti risorsa nodo
param Posizione{J}; # Posizione nodo
param Virtual{J}; # Virtualizzazione presente o meno

param CostoWattMese > 0; # Costo mensile Watt
param MaxEccessoServer <= 5 integer; # Massimo eccesso server

param Richieste{I}; # Server richiesti all'azienda

param N := sum{i in I} Richieste[i]; # Numero totale delle richieste


# Controlli

check{i in I} : Peso[i] <= 4;
check{i in I} : Peso[i] >= 0; 

check{i in I} : Costo[i] > 0;

# Controlla che le richieste non siano maggiori di quello che i nodi possono offrire 
check : sum{j in J} Risorse[j] >= sum{i in I} Peso[i]*Richieste[i]; # importante! 

check{j in J} : Posizione[j] in Bool and Virtual[j] in Bool;

# Variabili

var x{I, J} >= 0 integer;
var y{J} >= 0 integer;
var w binary;
var z{J} >= 0, <= MaxEccessoServer integer;

# Funzione obiettivo

maximize fo : 
			(sum{i in I} sum{j in J} Costo[i]*x[i,j]) 
			- CostoWattMese * 
					(sum{j in J} (1 - Posizione[j])*(y[j]))
					+
					(1-w)*(sum{j in J} (Posizione[j]*y[j])
					)
			+ 20*(w)
			;
		
				
subject to NumeroMassimoServer{j in J} :
				sum{i in I} (Peso[i] * x[i,j]) <= 
				(Risorse[j] + z[j] - (6)*(Posizione[j])*(w))
			;
			

			 
subject to TipiServerCompatibili_1 {j in J, i in I diff NotVirt}:
					x[i,j] <= N * (Virtual[j])
			;
			
subject to TipiServerCompatibili_2 {j in J, i in NotVirt}:	
					x[i,j] <= N
			;



subject to ConsumoEnergetico{j in J} :
			y[j] = ((100+50*Virtual[j])/4) * (sum{i in I} Peso[i]*x[i,j])
			;
	
subject to EccessiNodi_1 {j in J} :
			(z[j] <= 
				MaxEccessoServer * 
					(
						(Posizione[j])*(1-w) 
						+ (1-Posizione[j])
					)
			);
			
subject to EccessiNodi_2 {j in J} :		
			z[j] <= MaxEccessoServer*Virtual[j]
			;

					
/**/