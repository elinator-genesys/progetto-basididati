# - - - - - - - - - - - - - - - - - -
# - - - - TABELLA Abbonamento - - - -
# - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Abbonamento;
DELIMITER $$

CREATE TRIGGER Abbonamento
BEFORE INSERT ON Abbonamento FOR EACH ROW
BEGIN
	IF NEW.TariffaMensile < 0 OR NEW.ContenutiScaricabili < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi (Abbonamento)";
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - - - - - 
# - - - - TABELLA AreaGeografica - - - - 
#  - - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS AreaGeografica;
DELIMITER $$

CREATE TRIGGER AreaGeografica
BEFORE INSERT ON AreaGeografica FOR EACH ROW
BEGIN
	IF NEW.IndirizzoIP < 0  THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi AreaGeografica";
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - 
# - - - - TABELLA ARTISTA - - - - 
# - - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Artista;
DELIMITER $$

CREATE TRIGGER Artista
BEFORE INSERT ON Artista FOR EACH ROW
BEGIN
	IF NEW.Popolarita < 0 OR NEW.PremiAttore < 0  OR NEW.PremiRegista < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Dati inseriti non validi Artista';
	END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS ArtistaUpdate;
DELIMITER $$

CREATE TRIGGER ArtistaUpdate
AFTER UPDATE ON Artista FOR EACH ROW
BEGIN
	IF NEW.Popolarita > 50 THEN
		UPDATE Artista
        SET Popolarita = 50
        WHERE ID = NEW.ID;
	END IF;
END $$
DELIMITER ;
       
#  - - - - - - - - - - - - - - - - - - - 
# - - - - TABELLA CartaDICredito - - - -
#  - - - - - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS CartaDiCredito;
DELIMITER $$

CREATE TRIGGER CartaDiCredito
BEFORE INSERT ON CartaDiCredito FOR EACH ROW
BEGIN
	IF NEW.ScadenzaCarta < CURRENT_DATE OR NEW.CVC NOT BETWEEN 100 AND 999 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi CartaDICredito';
	END IF;
END $$
DELIMITER ;


# - - - - - - - - - - - - - - - - - -
# - - - - TABELLA Connessione - - - -
# - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Connessione;
DELIMITER $$

CREATE TRIGGER Connessione
BEFORE INSERT ON Connessione FOR EACH ROW
BEGIN
	IF NEW.ID_Utente NOT IN (SELECT U.ID FROM Utente U) OR NEW.ID_Server NOT IN (SELECT S.ID FROM Server S) OR NEW.IndirizzoIP NOT IN (SELECT AG.IndirizzoIP FROM AreaGeografica AG) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Connessione';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - - 
# - - - - TABELLA Contenuto - - - -
# - - - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Contenuto;
DELIMITER $$

CREATE TRIGGER Contenuto
BEFORE INSERT ON Contenuto FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.ID_Film NOT IN (SELECT F.ID FROM Film F) OR NEW.ID_FormatoAudio NOT IN (SELECT FA.ID FROM FormatoAudio FA) OR NEW.ID_FormatoVideo NOT IN (SELECT FV.ID FROM FormatoVideo FV) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Contenuto';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - - 
# - - - - TABELLA Copertura - - - -
# - - - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Copertura;
DELIMITER $$

CREATE TRIGGER Copertura
BEFORE INSERT ON Copertura FOR EACH ROW
BEGIN
	IF NEW.IP_AreaGeografica NOT IN (SELECT AG.IndirizzoIP FROM AreaGeografica AG) OR NEW.ID_Server NOT IN (SELECT S.ID FROM Server S) OR NEW.Ping < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Copertura';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - - -
# - - - - TABELLA Download - - - -
# - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Download;
DELIMITER $$

CREATE TRIGGER Download
BEFORE INSERT ON Download FOR EACH ROW
BEGIN
	IF NEW.ID_Utente NOT IN (SELECT U.ID FROM Utente U) OR NEW.ID_Contenuto NOT IN (SELECT C.ID FROM Contenuto C) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Download';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - -
# - - - - TABELLA Fattura - - - - 
# - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Fattura;
DELIMITER $$

CREATE TRIGGER Fattura
BEFORE INSERT ON Fattura FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.DataPagamento < NEW.Data OR NEW.Importo < 0 OR NEW.NumeroCarta NOT IN (SELECT CDC.NumeroCarta FROM CartaDiCredito CDC)THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Fattura';
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - 
# - - - - TABELLA Film - - - - 
#  - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Film;
DELIMITER $$

CREATE TRIGGER Film
BEFORE INSERT ON Film FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.Durata < 0 OR NEW.DataPubblicazione > CURRENT_DATE THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Film';
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - - - - 
# - - - - TABELLA FormatoAudio - - - - 
#  - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS FormatoAudio;
DELIMITER $$

CREATE TRIGGER FormatoAudio
BEFORE INSERT ON FormatoAudio FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.Bitrate < 0 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi FormatoAudio';
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - - - - 
# - - - - TABELLA FormatoVideo - - - - 
#  - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS FormatoVideo;
DELIMITER $$

CREATE TRIGGER FormatoVideo
BEFORE INSERT ON FormatoVideo FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.Bitrate < 0 THEN 
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi FormatoVideo';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - -
# - - - - TABELLA Offerta - - - - 
# - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Offerta;
DELIMITER $$

CREATE TRIGGER Offerta
BEFORE INSERT ON Offerta FOR EACH ROW
BEGIN
	IF NEW.NomeAbbonamento NOT IN (SELECT A.Nome FROM Abbonamento A) OR NEW.ID_Contenuto NOT IN (SELECT C.ID FROM Contenuto C) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Offerta';
	END IF;
    
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - -
# - - - - TABELLA Possesso - - - - 
#  - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Possesso;
DELIMITER $$

CREATE TRIGGER Possesso
BEFORE INSERT ON Possesso FOR EACH ROW
BEGIN
	IF NEW.ID_Server NOT IN (SELECT S.ID FROM Server S) OR NEW.ID_Contenuto NOT IN (SELECT C.ID FROM Contenuto C) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Possesso';
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - - -
# - - - - TABELLA Produzione - - - - 
#  - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Produzione;
DELIMITER $$

CREATE TRIGGER Produzione
BEFORE INSERT ON Produzione FOR EACH ROW
BEGIN
	IF NEW.ID_Film NOT IN (SELECT F.ID FROM Film F) OR (NEW.ID_Artista NOT IN (SELECT A.ID FROM Artista A )) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Produzione';
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - - -
# - - - - TABELLA Recensione - - - - 
#  - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Recensione;
DELIMITER $$

CREATE TRIGGER Recensione
BEFORE INSERT ON Recensione FOR EACH ROW
BEGIN
	IF NEW.ID_Film NOT IN (SELECT F.ID FROM Film F) OR NEW.ID_Utente NOT IN (SELECT U.ID FROM Utente U) OR NEW.PunteggioUtente < 0 OR NEW.PunteggioUtente > 50 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi Recensione";
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - - - 
# - - - - TABELLA Restrizione - - - - 
# - - - - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Restrizione;
DELIMITER $$

CREATE TRIGGER Restrizione
BEFORE INSERT ON Restrizione FOR EACH ROW
BEGIN
	IF NEW.IP_AreaGeografica NOT IN (SELECT AG.IndirizzoIP FROM AreaGeografica AG) OR NEW.ID_Contenuto NOT IN (SELECT C.ID FROM Contenuto C) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi Restrizione";
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - - 
# - - - - TABELLA Server - - - - 
#  - - - - - - - - - - - - - - - 

DROP TRIGGER IF EXISTS Server;
DELIMITER $$

CREATE TRIGGER Server
BEFORE INSERT ON Server FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR NEW.LarghezzaBanda < 0 OR NEW.CapacitaMax < 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi Server";
	END IF;
END $$
DELIMITER ;

#  - - - - - - - - - - - - - - -
# - - - - TABELLA Utente - - - - 
#  - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Utente;
DELIMITER $$

CREATE TRIGGER Utente
BEFORE INSERT ON Utente FOR EACH ROW
BEGIN
	IF NEW.ID < 0 OR LENGTH(NEW.Passw) < 8 OR NEW.Email NOT LIKE '%@%.%' THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Dati inseriti non validi Utente';
	END IF;
END $$
DELIMITER ;

# - - - - - - - - - - - - - - - - - - - -
# - - - - TABELLA Visualizzazione - - - - 
# - - - - - - - - - - - - - - - - - - - -

DROP TRIGGER IF EXISTS Visualizzazione;
DELIMITER $$

CREATE TRIGGER Visualizzazione
BEFORE INSERT ON Visualizzazione FOR EACH ROW
BEGIN
	IF NEW.ID_Utente NOT IN (SELECT U.ID FROM Utente U) OR NEW.ID_Contenuto NOT IN (SELECT C.ID FROM Contenuto C) THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Dati inseriti non validi Visualizzazione";
	END IF;
END $$
DELIMITER ;










