# ==============================
#		  Modello AMPL
#	qCloud - Ricerca operativa
#		Mariano Sciacco
#			(2019)
# ==============================


# Insiemi del modello

set I; # tipi di server 
set J; # nodi hardware
set NotVirt; # insieme ausiliario che indica le macchine non virtualizzabili

# Parametri del modello

param Peso{I} integer; # Peso del server
param Costo{I}; # Costo di un singolo server

param Risorse{J} >= 0 integer; # Punti risorsa nodo
param Posizione{J} binary; # Posizione nodo
param Virtual{J} binary; # Virtualizzazione presente o meno

param Richieste{I}; # Server richiesti all'azienda

param CostoWattMese > 0; # Costo mensile Watt
param MaxEccessoServer <= 5 integer; # Massimo eccesso server
param MinVendita; # Percentuale minima di vendita

param N := sum{i in I} Richieste[i]; # Numero totale delle richieste

param BonusProporzione binary; # Attivazione proporzione carico nodi
param BonusIncremento binary; # Attivazione carico nodi per incremento


# Controlli

check{i in I} : Peso[i] >= 0 and Peso[i] <= 4; 

check{i in I} : Costo[i] > 0 and Costo[i] <= 1000.0;

# Controlla che le richieste non siano maggiori di quello che i nodi possono offrire 
# importante! 
check : sum{j in J} (Risorse[j]+5*Virtual[j]) >= sum{i in I} Peso[i]*Richieste[i];  


# Variabili

var x{I, J} >= 0 integer; # numero di server di tipo i nel nodo j
var y{J} >= 0 integer; # consumo watt nodo j
var w binary; # uso delle energie rinnovabili
var z{J} >= 0, <= MaxEccessoServer integer; # eccesso punti risorsa
var k integer; # numero degli ordini evasi

# Funzione obiettivo

maximize GuadagniMensili : 
			(sum{i in I} sum{j in J} Costo[i]*x[i,j]) 
			- CostoWattMese * (
					sum{j in J} (
						(1 - Posizione[j])*y[j]
						+
						(1-w)*(Posizione[j]*y[j])
					)
			) # Costo corrente
			+ 20*(w) # Se messo >=30 o posti tolti < 4 (invece di 6), il problema userebbe w=1
			- sum{j in J} z[j]; # Penale
			;
		
		
# Vincoli
		
# 1) 				
subject to PesoMassimoServer{j in J} :
			sum{i in I} (Peso[i] * x[i,j]) <= 
			(Risorse[j] + z[j] - (6)*(Posizione[j])*(w))
			;
			 
# 2)			 
subject to TipiServerCompatibili_1 {j in J, i in I diff NotVirt} :
			x[i,j] <= N * (Virtual[j])
			;
# 2)			
subject to TipiServerCompatibili_2 {j in J, i in NotVirt} :	
			x[i,j] <= N
			;

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
			
# 5)		
subject to NumeroMassimoServerPerNodo{i in I} :
			sum{j in J} (x[i,j]) <= Richieste[i]
			;			
			
# 6)
subject to VenditaMinimaServizi_1 :
			sum{i in I} sum{j in J} x[i,j] = k;
			
subject to VenditaMinimaServizi_2 :
			k >= N * MinVendita;				



# BONUS) Proporzione sul carico di consumo dei nodi
			
s.t. Proporzione14 :
			BonusProporzione == 1 
				==> y[1] = y[4];
s.t. Proporzione45 :
			BonusProporzione == 1 			
				==> y[4] = y[5];
s.t. Proporzione56 :
			BonusProporzione == 1 
				==> y[5] = y[6];
s.t. Proporzione61 :
			BonusProporzione == 1 
				==> y[6] = y[1];
s.t. Proporzione_ded :
			BonusProporzione == 1 
				==> y[2] = y[3];

		
# BONUS) Incremento dal piu' grande al piu' piccolo

s.t. Incremento1 :
			BonusIncremento == 1
				==> y[6] >= y[5];				
s.t. Incremento2 :			
			BonusIncremento == 1
				==> y[5] >= y[1];
s.t. Incremento3 :
			BonusIncremento == 1
				==> y[1] >= y[4];
s.t. Incremento_ded :
			BonusIncremento == 1
				==> y[3] >= y[2];				

				
/*---- EOF ----*/