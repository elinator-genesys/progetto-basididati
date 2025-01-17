#  - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 1: registrazione utente - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - 

DROP PROCEDURE IF EXISTS RegistraUtente;

DELIMITER $$
CREATE PROCEDURE RegistraUtente(IN _nome VARCHAR(50), _cognome VARCHAR(50), _passw VARCHAR(16), _email VARCHAR(100), _critico BOOL)
BEGIN

	DECLARE max_id_utente INT DEFAULT 0;
    
    SET max_id_utente = (SELECT MAX(U.ID) FROM Utente U);
    
	INSERT INTO Utente (ID, Nome, Cognome, Passw, Email, Critico, NomeAbbonamento, Scadenza)
    VALUES (max_id_utente + 1, _nome, _cognome, _passw, _email, _critico, NULL, NULL);
END $$

# - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - Operazione 2: inserimento fattura - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS NuovaFattura;

DELIMITER $$
CREATE PROCEDURE NuovaFattura(IN _idutente INT, _numerocarta VARCHAR(20), _scadenzacarta DATE, _cvc INT, _abbonamento VARCHAR(10))
BEGIN
	DECLARE max_id_fattura INT DEFAULT 0;
    DECLARE importo INT DEFAULT 0;
    
    SET max_id_fattura = (SELECT MAX(F.ID) FROM Fattura F);
    
	IF (SELECT COUNT(*) FROM CartaDICredito WHERE NumeroCarta = _numerocarta) = 0
    THEN
		INSERT INTO CartaDiCredito (ID_Utente, NumeroCarta, ScadenzaCarta, CVC)
        VALUES (_idutente, _numerocarta, _scadenzacarta, _cvc);
	END IF;  

    IF _abbonamento = 'Basic' THEN 
		SET importo = 5; 
    ELSEIF _abbonamento = 'Premium' THEN 
		SET importo = 10; 
	ELSEIF _abbonamento = 'Pro' THEN 
		SET importo = 15;
	ELSEIF _abbonamento = 'Deluxe' THEN 
		SET importo = 20;
	ELSEIF _abbonamento = 'Ultimate' THEN 
		SET importo = 25;
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Abbonamento inserito non valido';
	END IF;
    
    INSERT INTO Fattura (ID, Data, DataPagamento, NumeroCarta, Importo)
    VALUES (max_id_fattura + 1, CURRENT_DATE(), NULL, _numerocarta, importo);
END $$

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 3a: sottoscrizione abbonamento - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS AggiornaAbbonamento;

DELIMITER $$
CREATE PROCEDURE AggiornaAbbonamento(IN _idutente INT, _numerocarta VARCHAR(20))
BEGIN
	DECLARE id_ultima_fattura INT;
    DECLARE nuovo_abbonamento VARCHAR(10);
    DECLARE importo INT;
    
	SELECT F.ID, F.Importo
	FROM Fattura F
	WHERE F.NumeroCarta = _numerocarta
          AND F.Data = (
						SELECT MAX(FF.Data)
                        FROM Fattura FF
                        WHERE FF.NumeroCarta = _numerocarta) INTO id_ultima_fattura , importo;
                        
	IF (
		SELECT ScadenzaCarta
		FROM CartaDiCredito
        WHERE NumeroCarta = _numerocarta ) < CURRENT_DATE THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Carta di credito scaduta';
	END IF;
	
	UPDATE Fattura F 
	SET F.DataPagamento = CURRENT_DATE()
	WHERE F.ID = id_ultima_fattura;
    
    IF importo = 5 THEN 
		SET nuovo_abbonamento = 'Basic'; 
    ELSEIF importo = 10 THEN 
		SET nuovo_abbonamento = 'Premium'; 
	ELSEIF importo = 15 THEN 
		SET nuovo_abbonamento = 'Pro';
	ELSEIF importo = 20 THEN 
		SET nuovo_abbonamento = 'Deluxe';
	ELSEIF importo = 25 THEN 
		SET nuovo_abbonamento = 'Ultimate';
	ELSE
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Importo inserito non valido';
	END IF;
    
	UPDATE Utente U 
	SET NomeAbbonamento = nuovo_abbonamento,
        Scadenza = CURRENT_DATE() + INTERVAL 1 MONTH
	WHERE U.ID = _idutente;
	
END $$

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 3b: scadenza abbonamento - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP EVENT IF EXISTS ScadenzaAbbonamento;

CREATE EVENT ScadenzaAbbonamento 
ON SCHEDULE EVERY 1 DAY
STARTS '2020-01-01 08:00:00'
DO 
	UPDATE Utente U
    SET U.NomeAbbonamento = NULL
    WHERE U.Scadenza = CURRENT_DATE;

# - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - Operazione 4: inserimento artista - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS NuovoArtista;

DELIMITER $$
CREATE PROCEDURE NuovoArtista(IN _nome VARCHAR(255), _cognome VARCHAR(255), _premi INT, _ruolo VARCHAR(10))
BEGIN
	DECLARE max_id_artista INT DEFAULT 0;
    DECLARE popolarita INT DEFAULT 0;
    
	SET max_id_artista = (SELECT MAX(A.ID) FROM Artista A);
    
    SET popolarita = _premi * 2;
    IF (popolarita > 30) 
    THEN 
		SET popolarita = 30;
	END IF;
    
    IF _ruolo = 'attore'
    THEN
		INSERT INTO Artista (ID, Nome, Cognome, Popolarita, PremiRegista, PremiAttore, Ruolo)
		VALUES (max_id_artista + 1, _nome, _cognome, popolarita, NULL, _premi, _ruolo);
	ELSEIF _ruolo = 'regista'
    THEN
		INSERT INTO Artista (ID, Nome, Cognome, Popolarita, PremiRegista, PremiAttore, Ruolo)
		VALUES (max_id_artista + 1, _nome, _cognome, popolarita, _premi, NULL, _ruolo);
	END IF;
    
END $$

#  - - - - - - - - - - - - - - - - - - - - - - 
# - - - - Operazione 5: creazione film - - - -
#  - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS NuovoFilm;

DELIMITER $$
CREATE PROCEDURE NuovoFilm(IN _titolo VARCHAR(255), _durata INT, _descrizione VARCHAR(255), _datapubb DATE, _paeseprod VARCHAR(50), _lingueaudio VARCHAR(100), _linguesott VARCHAR(100), 
						   _genere VARCHAR(50), _idatt INT, _idreg INT)
BEGIN
	DECLARE max_id_film INT DEFAULT 0;
    DECLARE pop_attore INT DEFAULT 0;
    DECLARE pop_regista INT DEFAULT 0;
    DECLARE media_pop INT DEFAULT 0;
    
    SET max_id_film = (SELECT MAX(F.ID) FROM Film F);
    
    # modifica tabella Artista
    
    IF (SELECT COUNT(*) FROM Artista A WHERE A.Ruolo = 'attore' AND A.ID = _idatt) = 0
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'ID attore non presente';
	END IF;
    
    IF (SELECT COUNT(*) FROM Artista A WHERE A.Ruolo = 'regista' AND A.ID = _idreg) = 0
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'ID regista non presente';
	END IF;
    
    UPDATE Artista A
	SET Popolarita = Popolarita + 2
	WHERE A.ID = _idatt OR A.ID = _idreg;
    
    # calcolo punteggio film
    
    SET pop_attore = (
					  SELECT A.Popolarita
                      FROM Artista A
                      WHERE A.ID = _idatt );
                      
	SET pop_regista = (
					  SELECT A.Popolarita
                      FROM Artista A
                      WHERE A.ID = _idreg );
                      
	SET media_pop = (pop_attore + pop_regista) / 2;
    
    # modifica tabella Film
	
	INSERT INTO Film (ID, PunteggioArtisti, PunteggioRecensioni, Durata, Titolo, DataPubblicazione, Descrizione, PaeseProduzione, LingueAudio, LingueSottotitoli, Genere)
    VALUES (max_id_film + 1, media_pop, NULL, _durata, _titolo, _datapubb, _descrizione, _paeseprod, _lingueaudio, _linguesott, _genere);
    
    # modifica tabella Produzione

    INSERT INTO Produzione (ID_Film, ID_Artista)
    VALUES
		(max_id_film + 1, _idatt),
        (max_id_film + 1, _idreg);
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 6a: inserimento contenuto - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - 

DROP PROCEDURE IF EXISTS NuovoContenuto;

DELIMITER $$
CREATE PROCEDURE NuovoContenuto(IN _idfilm INT, _idformatoaudio INT, _idformatovideo INT)
BEGIN

	DECLARE durata INT DEFAULT 0;
    DECLARE dimensione_bit BIGINT;
    DECLARE dimensione_GB DECIMAL(3, 3);
    DECLARE bitrate_audio INT DEFAULT 0;
    DECLARE bitrate_video INT DEFAULT 0;
    DECLARE max_id_contenuto INT DEFAULT 0;
  
    SET durata = (
				  SELECT F.Durata
				  FROM Film F
                  WHERE F.ID = _idfilm );
              
	SET bitrate_audio = (
				         SELECT FA.Bitrate
				         FROM FormatoAudio FA
                         WHERE FA.ID = _idformatoaudio );
                  
	SET bitrate_video = (
				         SELECT FV.Bitrate
				         FROM FormatoVideo FV
                         WHERE FV.ID = _idformatovideo );
             
	SET dimensione_bit = bitrate_audio * durata * 60 + bitrate_video * durata * 60;
    SET dimensione_GB = dimensione_bit / 1073741824; # 2^30
    
	SET max_id_contenuto = (SELECT MAX(C.ID) FROM Contenuto C);
    
    INSERT INTO Contenuto (ID, ID_Film, ID_FormatoAudio, ID_FormatoVideo, BitrateTotale, DataRilascio, Dimensione)
    VALUES (max_id_contenuto + 1, _idfilm, _idformatoaudio, _idformatovideo, bitrate_audio + bitrate_video, CURRENT_DATE, dimensione_GB);   
    
    IF _idformatoaudio = 1 AND _idformatovideo = 1
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
			('basic', max_id_contenuto + 1, FALSE),
            ('premium', max_id_contenuto + 1, FALSE),
            ('pro', max_id_contenuto + 1, FALSE),
            ('deluxe', max_id_contenuto + 1, TRUE),
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;
    
    IF _idformatoaudio = 1 AND _idformatovideo = 2
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
            ('premium', max_id_contenuto + 1, FALSE),
            ('pro', max_id_contenuto + 1, FALSE),
            ('deluxe', max_id_contenuto + 1, TRUE),
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;    
    
    IF _idformatoaudio = 2 AND _idformatovideo = 2
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
            ('premium', max_id_contenuto + 1, FALSE),
            ('pro', max_id_contenuto + 1, FALSE),
            ('deluxe', max_id_contenuto + 1, TRUE),
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;    
    
    IF _idformatoaudio = 2 AND _idformatovideo = 3
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
            ('pro', max_id_contenuto + 1, FALSE),
            ('deluxe', max_id_contenuto + 1, TRUE),
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;    
    
    IF _idformatoaudio = 3 AND _idformatovideo = 3
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
            ('pro', max_id_contenuto + 1, FALSE),
            ('deluxe', max_id_contenuto + 1, TRUE),
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;    
    
    IF _idformatoaudio = 3 AND _idformatovideo = 4
    THEN
		INSERT INTO Offerta (NomeAbbonamento, ID_Contenuto, Visualizzabile)
		VALUES 
            ('ultimate', max_id_contenuto + 1, TRUE);
	END IF;    
    
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 6b: modifica offerta vecchi contenuti - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP EVENT IF EXISTS EventOfferta;

CREATE EVENT EventOfferta
ON SCHEDULE EVERY 1 DAY
STARTS '2023-11-20 11:17:00'
DO
	UPDATE Offerta O
    SET Visualizzabile = TRUE
    WHERE (O.NomeAbbonamento = 'basic' OR O.NomeAbbonamento = 'premium' OR O.NomeAbbonamento = 'pro') AND O.ID_Contenuto IN (
																															SELECT C.ID
																															FROM Contenuto C 
																															WHERE C.DataRilascio = CURRENT_DATE - INTERVAL 1 MONTH );

#  - - - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - - Operazione 7: inserimento recensione - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - 

DROP PROCEDURE IF EXISTS NuovaRecensione;

DELIMITER $$
CREATE PROCEDURE NuovaRecensione(IN _idutente INT, _idfilm INT, _punteggio INT)
BEGIN
	DECLARE critico BOOL DEFAULT FALSE;
    DECLARE punteggio INT DEFAULT 0;
    DECLARE punt INT DEFAULT 0;
    DECLARE contacritici INT DEFAULT 0;
    DECLARE contautenti INT DEFAULT 0;
    DECLARE sommacritici INT DEFAULT 0;
    DECLARE sommautenti INT DEFAULT 0;
    
    DECLARE media INT DEFAULT 0;
    DECLARE sommapunteggi INT DEFAULT 0;
    
    SET punt = _punteggio;
    IF (_punteggio < 0) THEN SET punt = 0; END IF;
    IF (_punteggio > 50) THEN SET punt = 50; END IF;
    
    # Se l'utente ha già recensito quel film, si aggiorna la recensione eliminando la vecchia
    
    IF (SELECT COUNT(*) FROM Recensione R WHERE R.ID_Film = _idfilm AND R.ID_Utente = _idutente) = 1
	THEN
		DELETE FROM Recensione R
        WHERE R.ID_Film = _idfilm AND R.ID_Utente = _idutente;
	END IF;
    
    INSERT INTO Recensione(ID_Utente, ID_Film, PunteggioUtente)
    VALUES (_idutente, _idfilm, punt);
        
	# varaibili d'appoggio per la media ponderata

	SELECT COUNT(*), SUM(PunteggioUtente)
	FROM Utente U INNER JOIN Recensione R ON U.ID = R.ID_Utente
	WHERE R.ID_Film = _idfilm AND U.Critico IS TRUE INTO contacritici, sommacritici;
                        
	SELECT COUNT(*), SUM(PunteggioUtente)
	FROM Utente U INNER JOIN Recensione R ON U.ID = R.ID_Utente
	WHERE R.ID_Film = _idfilm AND U.Critico IS FALSE INTO contautenti, sommautenti;
    
    # aggiornamento punteggio delle recensioni
    
    SET sommapunteggi = sommacritici * 10 + sommautenti;
    SET media = sommapunteggi / (contacritici * 10 + contautenti);
    
    UPDATE Film F
    SET PunteggioRecensioni = media
    WHERE F.ID = _idfilm;
    
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 8a: visualizzazione contenuto - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS VisualizzaContenuto;

DELIMITER $$
CREATE PROCEDURE VisualizzaContenuto(IN _idutente INT, _idcontenuto INT, _indirizzoip INT, _dispositivo VARCHAR(50))
BEGIN
	DECLARE abb_utente VARCHAR(10) DEFAULT 'basic';
    DECLARE id_target_server INT DEFAULT 999;
    DECLARE bitrate_contenuto INT DEFAULT 0;
    
	# controllo se il contenuto è disponibile nell'Area Geografica
    
    IF (SELECT COUNT(*) FROM Restrizione R WHERE R.IP_AreaGeografica = _indirizzoip AND ID_Contenuto = _idcontenuto) > 0
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Contenuto non disponibile nel tuo paese';
	END IF;
    
    # controllo se il contenuto è disponibile nell'abbonamento dell'utente
    
    SET abb_utente = (
					  SELECT U.NomeAbbonamento
					  FROM Utente U
					  WHERE U.ID = _idutente);
    
    IF (SELECT COUNT(*) FROM Offerta O WHERE O.NomeAbbonamento = abb_utente AND O.ID_Contenuto = _idcontenuto AND O.Visualizzabile = TRUE) = 0
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Contenuto non disponibile nel tuo abbonamento';
	END IF;
    
    # calcolo il bitrate richiesto per il contenuto target
                            
	SET bitrate_contenuto = (
							 SELECT C.BitrateTotale
                             FROM Contenuto C
							 WHERE C.ID = _idcontenuto );
    
    # controllo quale server non pieno ha il contenuto desiderato, prendo quello con ping minore
    
    SET id_target_server = (
							SELECT C.ID_Server
							FROM Copertura C
							WHERE C.IP_AreaGeografica = _indirizzoip AND C.ID_Server IN (
																						 SELECT P.ID_Server
																						 FROM Possesso P
																						 WHERE P.ID_Contenuto = _idcontenuto AND C.ID_Server IN (
																																				 SELECT S.ID	
																																				 FROM Server S
																																				 WHERE S.StatoServer + bitrate_contenuto < S.CapacitaMax ))
							ORDER BY C.Ping ASC
							LIMIT 1 );
                            
	IF id_target_server = 999 OR id_target_server IS NULL
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Momentaneamente non ci sono server disponibili all''erogazione del contenuto';
	END IF;
    
	# a questo punto può iniziare la connessione e quindi la visualizzazione del contenuto
    
    INSERT INTO Connessione (ID_Utente, ID_Server, IndirizzoIP, Dispositivo, TimestampInizio, TimestampFine)
    VALUES (_idutente, id_target_server, _indirizzoip, _dispositivo, CURRENT_TIMESTAMP, NULL);
    
    INSERT INTO Visualizzazione (ID_Utente, ID_Contenuto, TimestampInizio)
    VALUES (_idutente, _idcontenuto, CURRENT_TIMESTAMP);
    
    UPDATE Server 
    SET StatoServer = StatoServer + bitrate_contenuto
    WHERE ID = id_target_server;
    
END $$

# - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 8b: fine visualizzazione - - - -
# - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS FineVisualizzazione;

DELIMITER $$
CREATE PROCEDURE FineVisualizzazione(IN _idutente INT, _idcontenuto INT, _indirizzoip INT)
BEGIN
    DECLARE bitrate_contenuto INT DEFAULT 0;
    DECLARE inizio_connessione TIMESTAMP;
    DECLARE id_target_server INT DEFAULT 999;
    
    SET inizio_connessione = (
							  SELECT C.TimestampInizio
                              FROM Connessione C
                              WHERE C.ID_Utente = _idutente
                              ORDER BY C.TimestampInizio DESC
							  LIMIT 1 );
	
    SET id_target_server = (
							SELECT C.ID_Server
                            FROM Connessione C
                            WHERE C.ID_Utente = _idutente AND C.TimestampInizio = inizio_connessione );
    
    UPDATE Connessione
    SET TimestampFine = CURRENT_TIMESTAMP
    WHERE ID_Utente = _idutente AND TimestampInizio = inizio_connessione;

	SET bitrate_contenuto = (
							 SELECT C.BitrateTotale
                             FROM Contenuto C
							 WHERE C.ID = _idcontenuto );
    
	UPDATE Server 
    SET StatoServer = StatoServer - bitrate_contenuto
    WHERE ID = id_target_server;
    
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 8c: sposta utenti su altri server - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS SpostaUtenti;

DELIMITER $$
CREATE PROCEDURE SpostaUtenti()
BEGIN
    DECLARE bitrate_contenuto_new INT DEFAULT 0;
    DECLARE disp_target VARCHAR(50);
    DECLARE id_utente_target INT DEFAULT 0;
    DECLARE id_contenuto_target INT DEFAULT 0;
    DECLARE indirizzo_ip_target INT DEFAULT 0; 
    DECLARE inizio TIMESTAMP;
    DECLARE id_server_target INT DEFAULT 999;
    
    # quando un utente libera spazio nel server X, se c'è un utente che si era connesso ad un server, 
    # con ping maggiore di X perchè X era pieno, questo utente viene spostato su X.
    
    SELECT DT.ID_Utente, DT.IndirizzoIP, DT.ID_Contenuto, DT.Dispositivo, DT.TimestampInizio, DT.ID_Server 
	FROM Copertura C INNER JOIN (
								 SELECT ID_Server, IndirizzoIP, TimestampInizio, ID_Utente, ID_Contenuto, Dispositivo
								 FROM Connessione NATURAL JOIN Visualizzazione
								 WHERE TimestampFine IS NULL ) AS DT ON C.ID_Server = DT.ID_Server AND C.IP_AreaGeografica = DT.IndirizzoIP
	WHERE C.Ping > 20
	ORDER BY C.Ping DESC, DT.TimestampInizio
	LIMIT 1 INTO id_utente_target, indirizzo_ip_target, id_contenuto_target, disp_target, inizio, id_server_target;
    
	SET bitrate_contenuto_new = (
								 SELECT C.BitrateTotale
								 FROM Contenuto C
								 WHERE C.ID = id_contenuto_target );
    
    UPDATE Server 
    SET StatoServer = StatoServer - bitrate_contenuto_new
    WHERE ID = id_server_target;
    
    UPDATE Connessione
    SET TimestampFine = CURRENT_TIMESTAMP
    WHERE ID_Utente = id_utente_target AND TimestampInizio = inizio;
    
    CALL VisualizzaContenuto(id_utente_target, id_contenuto_target, indirizzo_ip_target, disp_target);
    
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 9a: download di contenuti - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS ScaricaContenuto;

DELIMITER $$
CREATE PROCEDURE ScaricaContenuto(IN _idutente INT, _idcontenuto INT)
BEGIN
	DECLARE abbonamento VARCHAR(50);
    DECLARE contenuti_scaricabili INT;
    
    IF (
		SELECT COUNT(*)
        FROM Download D
		WHERE D.ID_Utente = _idutente AND D.ID_Contenuto = _idcontenuto ) <> 0
	THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hai già scaricato questo contenuto';
    END IF;
    
    SELECT U.NomeAbbonamento
	FROM Utente U
	WHERE U.ID = _idutente INTO abbonamento;
    
    IF abbonamento = 'basic' OR abbonamento = 'premium'
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Download contenuti non compreso nel tuo abbonamento';
	END IF;
    
    SELECT A.ContenutiScaricabili
    FROM Abbonamento A
    WHERE A.Nome = abbonamento INTO contenuti_scaricabili;
    
	IF contenuti_scaricabili = (
								SELECT COUNT(*)
                                FROM Download D
								WHERE D.ID_Utente = _idutente )
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hai raggiunto il limite massimo di contenuti scaricabili';
	END IF;
    
    INSERT INTO Download (ID_Utente, ID_Contenuto)
    VALUES
		(_idutente, _idcontenuto);
	
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 9b: elimina contenuti scaricati - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS EliminaDownload;

DELIMITER $$
CREATE PROCEDURE EliminaDownload(IN _idutente INT, _idcontenuto INT)
BEGIN
	DELETE FROM Download 
    WHERE ID_Utente = _idutente AND ID_Contenuto = _idcontenuto;
	
END $$

#  - - - - - - - - - - - - - - - - - - - - - - - -
# - - - - Operazione 10: caching contenuti - - - -
#  - - - - - - - - - - - - - - - - - - - - - - - -

DROP PROCEDURE IF EXISTS CachingContenuti;

DELIMITER $$
CREATE PROCEDURE CachingContenuti(IN _idutente INT)
BEGIN
	DECLARE ultimo_server INT;
    DECLARE genere_target VARCHAR(50);
    DECLARE abbonamento VARCHAR(10);
    DECLARE film_target VARCHAR(255);
    DECLARE contenuto_target INT;
    
    # calcolo l'ultimo server a cui si è connesso l'utente
    
    SELECT C.ID_Server
    FROM Connessione C
    WHERE ID_Utente = _idutente
	ORDER BY C.TimestampInizio DESC
    LIMIT 1 INTO ultimo_server;
    
    # calcolo il genere di film preferito dall'utente (più visualizzato)
    
    SELECT Genere
	FROM (Visualizzazione V INNER JOIN Contenuto C ON V.ID_Contenuto = C.ID) INNER JOIN Film F ON C.ID_Film = F.ID
	WHERE V.ID_Utente = _idutente
	GROUP BY Genere
	ORDER BY COUNT(*) DESC
	LIMIT 1 INTO genere_target;
    
    # calcolo l'abbonamento dell'utente
    
    SELECT U.NomeAbbonamento
    FROM Utente U
    WHERE U.ID = _idutente INTO abbonamento;
    
    # calcolo il film che l'utente vorrà vedere con più probabilità
	
    SELECT F.ID
    FROM Film F
    WHERE F.ID NOT IN (
					   SELECT F.ID
					   FROM (Visualizzazione V INNER JOIN Contenuto C ON V.ID_Contenuto = C.ID) INNER JOIN Film F ON C.ID_Film = F.ID
					   WHERE V.ID_Utente = _idutente AND F.Genere = genere_target )
		  AND F.Genere = genere_target
	ORDER BY RAND()
    LIMIT 1 INTO film_target;
    
    IF film_target IS NULL
    THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hai già visto tutti i film del tuo genere preferito';
	END IF;
      
	# ricerco il contenuto che l'utente vorrà vedere con maggiore probabilità
    
	IF abbonamento = 'basic'
    THEN
		SELECT C.ID
		FROM Contenuto C
		WHERE C.ID_Film = film_target AND ID_FormatoAudio = 1 AND ID_FormatoVideo = 1 INTO contenuto_target;
	ELSEIF abbonamento = 'premium'
    THEN
		SELECT C.ID
		FROM Contenuto C
		WHERE C.ID_Film = film_target AND ID_FormatoAudio = 2 AND ID_FormatoVideo = 2 INTO contenuto_target;
	ELSEIF abbonamento = 'pro' OR abbonamento = 'deluxe'
    THEN
		SELECT C.ID
		FROM Contenuto C
		WHERE C.ID_Film = film_target AND ID_FormatoAudio = 3 AND ID_FormatoVideo = 3 INTO contenuto_target;
	ELSEIF abbonamento = 'ultimate'
    THEN
		SELECT C.ID
		FROM Contenuto C
		WHERE C.ID_Film = film_target AND ID_FormatoAudio = 3 AND ID_FormatoVideo = 4 INTO contenuto_target;
	END IF;
    
	# inserisco nel server opportuno il contenuto che l'utente vorrà vedere 
    # con maggiore probabilità
        
    INSERT INTO Possesso (ID_Contenuto, ID_Server)
    VALUES
		(contenuto_target, ultimo_server);
	
END $$



