# - - - - Test nuovo utente - - - -
/*
CALL RegistraUtente("aaa", "bbb", "abababab", "abababab@aaa.com", false); # utente si registra alla piattaforma
SELECT * FROM Utente;
CALL NuovaFattura(161, 4444999988887777, "2024-12-31", 999, "Ultimate"); # utente vuole sottoscrivere un abbonamento
SELECT * FROM CartaDiCredito;
SELECT * FROM Fattura;
CALL AggiornaAbbonamento(161, 4444999988887777);
SELECT * FROM Fattura;
SELECT * FROM Utente;
*/


# - - - - Test nuovo film - - - -
/*
CALL NuovoArtista("att", "ore", 7, "attore");
CALL NuovoArtista("reg", "ista", 17, "regista");
SELECT * FROM Artista;
CALL NuovoFilm("titolo", 120, "desc", "2019-01-01", "Russia", "Russo, Inglese", "Russo, Inglese", "Crime", 81, 82);
SELECT * FROM Artista;
SELECT * FROM Film;
SELECT * FROM Produzione;
CALL NuovoContenuto(51, 1, 1);
SELECT * FROM Contenuto;
SELECT * FROM Offerta;
CALL NuovaRecensione(19, 51, 50);
CALL NuovaRecensione(16, 51, 5);
SELECT * FROM Recensione;
SELECT * FROM Film;
*/


# - - - - Test visualizzazione - - - -
/*
CALL VisualizzaContenuto (3, 6, 001, "telefono"); # tutti gli utenti visualizzano un contenuto con bitrate = 25000
CALL VisualizzaContenuto (8, 6, 001, "telefono"); # tutti gli utenti si connettono dall'Italia
CALL VisualizzaContenuto (13, 6, 001, "telefono");
CALL VisualizzaContenuto (16, 6, 001, "telefono"); 
CALL VisualizzaContenuto (18, 6, 001, "telefono");
CALL VisualizzaContenuto (23, 6, 001, "telefono");
CALL VisualizzaContenuto (28, 6, 001, "telefono");
CALL VisualizzaContenuto (33, 6, 001, "telefono");
CALL VisualizzaContenuto (38, 6, 001, "telefono");
CALL VisualizzaContenuto (43, 6, 001, "telefono");
SELECT * FROM Visualizzazione;
SELECT * FROM Connessione;
SELECT * FROM Server;
CALL FineVisualizzazione (3, 6, 001); # connesso al server Italia
CALL FineVisualizzazione (18, 6, 001); # connesso al server Spagna
SELECT * FROM Visualizzazione;
SELECT * FROM Connessione;
SELECT * FROM Server;
SELECT SLEEP(2); # attende 2 secondi
CALL SpostaUtenti(); # l'utente connesso al server con ping più elevato viene spostato in uno più adeguato
SELECT * FROM Visualizzazione;
SELECT * FROM Connessione;
SELECT * FROM Server;
*/


# - - - - Test download - - - -
/*	
CALL ScaricaContenuto(16, 6);
SELECT * FROM Download;
CALL EliminaDownload(16, 6);
SELECT * FROM Download;
*/


# - - - - Test chaching - - - -
/* 
CALL VisualizzaContenuto (19, 1, 001, "telefono");  # l'utente vede 3 film con genere Drammatico
CALL FineVisualizzazione (19, 1, 001);
SELECT SLEEP(1);
CALL VisualizzaContenuto (19, 7, 001, "telefono");
CALL FineVisualizzazione (19, 7, 001);
SELECT SLEEP(1);
CALL VisualizzaContenuto (19, 13, 001, "telefono");
CALL FineVisualizzazione (19, 13, 001);
SELECT * FROM Visualizzazione;
SELECT * FROM Possesso; # prima del caching
CALL CachingContenuti(19);
SELECT * FROM Possesso; # dopo il caching, è stato aggiunto un film del genere preferito dell'utente nel server più vicino
*/


# - - - -  Test analytics - - - - 
/*	
CALL VisualizzaContenuto (3, 6, 001, "telefono");
CALL VisualizzaContenuto (8, 6, 001, "telefono"); 
CALL VisualizzaContenuto (13, 6, 001, "telefono");
CALL VisualizzaContenuto (16, 6, 001, "telefono"); 
CALL VisualizzaContenuto (23, 7, 001, "telefono");
CALL VisualizzaContenuto (28, 7, 001, "telefono");
CALL VisualizzaContenuto (33, 7, 001, "telefono");
CALL FineVisualizzazione (3, 6, 001); 
CALL FineVisualizzazione (8, 6, 001);
CALL FineVisualizzazione (13, 6, 001); 
CALL FineVisualizzazione (16, 6, 001);
CALL FineVisualizzazione (23, 7, 001);
CALL FineVisualizzazione (28, 7, 001);
CALL FineVisualizzazione (33, 7, 001);
CALL Classifiche(); # stila due classifiche: 1. contenuti più visti per area geografica 2. contenuti più visti per abbonamento
CALL BilanciamentoCarico(3, 60); 
# per ogni paese, suggerisce di spostare i 3 contenuti più visti nei server con ping <= 60 (server destinazione), 
# in caso di parimerito nelle visualizzazioni, suggerisce più contenuti.
*/







 
 

	
    


