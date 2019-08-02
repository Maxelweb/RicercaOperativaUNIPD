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
# importante! 
check : sum{j in J} (Risorse[j]+5*Virtual[j]) >= sum{i in I} Peso[i]*Richieste[i];  

check{j in J} : Posizione[j] in Bool and Virtual[j] in Bool;

# Variabili

var x{I, J} >= 0 integer;
var y{J} >= 0 integer;
var w binary;
var z{J} >= 0, <= MaxEccessoServer integer;
var k integer;

# Funzione obiettivo

maximize fo : 
			(sum{i in I} sum{j in J} Costo[i]*x[i,j]) 
			- CostoWattMese * (
					sum{j in J} (
						(1 - Posizione[j])*y[j]
						+
						(1-w)*(Posizione[j]*y[j])
					)
			)
			+ 20*(w)
			;
		
		
# Vincoli
		
# 1) 				
subject to PesoMassimoServer{j in J} :
				sum{i in I} (Peso[i] * x[i,j]) <= 
				(Risorse[j] + z[j] - (6)*(Posizione[j])*(w))
			;
	
# DA AGGIUNGERE			
subject to NumeroMassimoServerPerNodo{i in I} :
				sum{j in J} (x[i,j]) <= Richieste[i]
			;
			 
# 2)			 
subject to TipiServerCompatibili_1 {j in J, i in I diff NotVirt}:
				x[i,j] <= N * (Virtual[j])
			;
# 2)			
subject to TipiServerCompatibili_2 {j in J, i in NotVirt}:	
				x[i,j] <= N
			;
/*
subject to PreferenzaPerDedicati {i in I, j in J} :
				x['D',j] <= x['D',j]*(1-Virtual[j]);
			;
*/

# 3)
subject to ConsumoEnergetico{j in J} :
			y[j] = ((100+50*Virtual[j])/4) * (sum{i in I} Peso[i]*x[i,j])
			;
# 4)	
subject to EccessiNodi_1 {j in J} :
			z[j] <= MaxEccessoServer * ((Posizione[j])*(1-w)  + (1-Posizione[j]))
			;
# 4)				
subject to EccessiNodi_2 {j in J} :		
			z[j] <= MaxEccessoServer*Virtual[j]
			;
			
# DA AGGIUNGERE
subject to VenditaMinimaServizi_1 :
			sum{i in I} sum{j in J} x[i,j] = k;
			
subject to VenditaMinimaServizi_2 :
			k >= N*0.75;				

# Proporzione
			
/*
s.t. Proporzione14 :
			y[1] = y[4];
s.t. Proporzione45 :			
			y[4] = y[5];
s.t. Proporzione56 :
			y[5] = y[6];
s.t. Proporzione61 :
			y[6] = y[1];
s.t. Proporzione_ded :
			y[2] = y[3];
*/
		
		
# Incremento
		
/*
s.t. Incremento14 :
			y[1] >= y[4];
s.t. Incremento_ded :
			y[2] >= y[3];					
s.t. Incremento45 :			
			y[4] >= y[5];
s.t. Incremento56 :
			y[5] >= y[6];

				
/**/