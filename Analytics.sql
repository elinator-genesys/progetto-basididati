#  - - - - - - - - - - - - - - - - - - - -
# - - - - Analytics 1: classifiche - - - -
#  - - - - - - - - - - - - - - - - - - - - 

DROP PROCEDURE IF EXISTS Classifiche;

DELIMITER $$
CREATE PROCEDURE Classifiche()
BEGIN
	DECLARE ordine_aree_geografiche VARCHAR(255) DEFAULT 'italia Spagna Francia Germania Cina India Giappone Russia USA Canada Argentina Brasile Marocco Sudafrica Egitto Nigeria';
    DECLARE ordine_abbonamenti VARCHAR(255) DEFAULT 'basic premium pro deluxe ultimate';
    
	# classifica dei contenuti più visti divisi per Area Geografica
    
    SELECT AG.NomePaese, RANK() OVER (
									  PARTITION BY AG.NomePaese 
									  ORDER BY COUNT(*) DESC ) as Posizione, V.ID_Contenuto, COUNT(*) as Visualizzazioni
	FROM (Connessione C NATURAL JOIN Visualizzazione V) INNER JOIN AreaGeografica AG ON AG.IndirizzoIP = C.IndirizzoIP
	WHERE TimestampInizio > CURRENT_DATE - INTERVAL 5 YEAR AND C.TimestampFine IS NOT NULL
	GROUP BY AG.NomePaese, V.ID_Contenuto
	ORDER BY INSTR(ordine_aree_geografiche, AG.NomePaese), Visualizzazioni DESC;
    
    # classifica dei contenuti più visti divisi per Abbonamento
    
    SELECT U.NomeAbbonamento, RANK() OVER (
									       PARTITION BY U.NomeAbbonamento 
									       ORDER BY COUNT(*) DESC ) as Posizione, V.ID_Contenuto, COUNT(*) as Visualizzazioni
	FROM Visualizzazione V INNER JOIN Utente U ON V.ID_Utente = U.ID
	WHERE TimestampInizio > CURRENT_DATE - INTERVAL 5 YEAR AND NomeAbbonamento IS NOT NULL
	GROUP BY U.NomeAbbonamento, V.ID_Contenuto
	ORDER BY INSTR(ordine_abbonamenti, NomeAbbonamento), Visualizzazioni DESC;
	
END $$

# - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Analytics 2: bilanciamento del carico - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS BilanciamentoCarico;

DELIMITER $$
CREATE PROCEDURE BilanciamentoCarico(IN N INT, MaxPing INT)
BEGIN
	WITH RankContenutiPerPaese AS (
		SELECT AG.NomePaese, AG.IndirizzoIP, RANK() OVER (
														  PARTITION BY AG.NomePaese 
										                  ORDER BY COUNT(*) DESC ) as Posizione, V.ID_Contenuto, COUNT(*) as Visualizzazioni
		FROM (Connessione C NATURAL JOIN Visualizzazione V) INNER JOIN AreaGeografica AG ON AG.IndirizzoIP = C.IndirizzoIP
		WHERE TimestampInizio > CURRENT_DATE - INTERVAL 5 YEAR AND C.TimestampFine IS NOT NULL
		GROUP BY AG.NomePaese, AG.IndirizzoIP, V.ID_Contenuto
		ORDER BY Visualizzazioni DESC )
        
    SELECT NomePaese, ID_Contenuto, Visualizzazioni, C.ID_Server as ServerSuggerito, Ping
	FROM RankContenutiPerPaese RK INNER JOIN Copertura C ON RK.IndirizzoIP = C.IP_AreaGeografica
	WHERE Posizione <= N AND Ping <= MaxPing;
	
END $$
	










