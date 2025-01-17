DROP SCHEMA IF EXISTS ProgettoMeazziniTonci;
CREATE SCHEMA IF NOT EXISTS ProgettoMeazziniTonci DEFAULT CHARACTER SET UTF8;

USE ProgettoMeazziniTonci;

# - - - - CREAZIONE TABELLA Abbonamento - - - -

CREATE TABLE IF NOT EXISTS Abbonamento (
    Nome VARCHAR(10) NOT NULL,
    TariffaMensile DECIMAL(5, 2),
    ContenutiScaricabili INT,
    Caratteristiche VARCHAR(200),
    PRIMARY KEY(Nome)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA AreaGeografica - - - -

CREATE TABLE IF NOT EXISTS AreaGeografica (
    IndirizzoIP INT NOT NULL,
    NomePaese VARCHAR(50),
    PRIMARY KEY(IndirizzoIP)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Artista - - - -

CREATE TABLE IF NOT EXISTS Artista (
	ID INT NOT NULL,
    Nome VARCHAR(255),
    Cognome VARCHAR(255),
    Popolarita INT,
    PremiRegista INT,
    PremiAttore INT,
    Ruolo VARCHAR(10),
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA CartaDiCredito - - - -

CREATE TABLE IF NOT EXISTS CartaDiCredito (
    ID_Utente INT NOT NULL,
    NumeroCarta BIGINT NOT NULL,
    ScadenzaCarta DATE NOT NULL,
    CVC INT NOT NULL,
    PRIMARY KEY(NumeroCarta)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Contenuto - - - - 

CREATE TABLE IF NOT EXISTS Contenuto(
    ID INT NOT NULL,
    ID_FIlm INT NOT NULL,
    ID_FormatoVideo INT NOT NULL,
    ID_FormatoAudio INT NOT NULL,
    BitrateTotale INT NOT NULL, 
    DataRilascio DATE,
    Dimensione DECIMAL(3, 3),
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Copertura - - - -
    
CREATE TABLE IF NOT EXISTS Copertura (
    IP_AreaGeografica INT NOT NULL,
    ID_Server INT NOT NULL,
    Ping INT NOT NULL,
    PRIMARY KEY(IP_AreaGeografica, ID_Server)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Download - - - -

CREATE TABLE IF NOT EXISTS Download (
    ID_Utente INT NOT NULL,
    ID_Contenuto INT NOT NULL,
    PRIMARY KEY(ID_Utente, ID_Contenuto)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Fattura - - - -

CREATE TABLE IF NOT EXISTS Fattura (
    ID INT NOT NULL,
    Data DATE,
    DataPagamento DATE,
    NumeroCarta VARCHAR(20),
    Importo INT,
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Film - - - -

CREATE TABLE IF NOT EXISTS Film (
    ID INT NOT NULL,
    PunteggioArtisti INT,
    PunteggioRecensioni INT,
    Durata INT,
    Titolo VARCHAR(255),
    DataPubblicazione DATE,
    Descrizione VARCHAR(250),
    PaeseProduzione VARCHAR(50),
    LingueAudio VARCHAR(100),
    LingueSottotitoli VARCHAR(100),
    Genere VARCHAR(50),
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA FormatoAudio - - - -

CREATE TABLE IF NOT EXISTS FormatoAudio (
    ID INT NOT NULL,
    Nome VARCHAR(10) NOT NULL,
    Bitrate INT NOT NULL,
    Qualita VARCHAR(20) NOT NULL,
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA FormatoVideo - - - -

CREATE TABLE IF NOT EXISTS FormatoVideo (
    ID INT NOT NULL,
    Nome VARCHAR(10) NOT NULL,
    Bitrate INT NOT NULL,
    RapportoVideo VARCHAR(20) NOT NULL,
    Qualita VARCHAR(20) NOT NULL,
    Risoluzione VARCHAR(20) NOT NULL,
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Offerta - - - -
    
CREATE TABLE IF NOT EXISTS Offerta (
    NomeAbbonamento VARCHAR(15) NOT NULL,
    ID_Contenuto INT NOT NULL,
    Visualizzabile BOOL NOT NULL,
    PRIMARY KEY(NomeAbbonamento, ID_Contenuto)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Possesso - - - -

CREATE TABLE IF NOT EXISTS Possesso (
    ID_Contenuto INT NOT NULL,
    ID_Server INT NOT NULL,
    PRIMARY KEY(ID_Contenuto, ID_Server)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Produzione - - - -
    
CREATE TABLE IF NOT EXISTS Produzione (
    ID_Film INT NOT NULL,
	ID_Artista INT NOT NULL, 
    PRIMARY KEY(ID_Film, ID_Artista)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Recensione - - - -
    
CREATE TABLE IF NOT EXISTS Recensione(
    ID_Utente INT NOT NULL,
    ID_Film INT NOT NULL,
    PunteggioUtente INT NOT NULL, 
    PRIMARY KEY(ID_Utente, ID_Film)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Restrizione - - - -
    
# Per ogni area geografica contiene i contenuti NON usufuibili

CREATE TABLE IF NOT EXISTS Restrizione (
    IP_AreaGeografica INT NOT NULL,
    ID_Contenuto INT NOT NULL,
    PRIMARY KEY(IP_AreaGeografica, ID_Contenuto)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Server - - - -

CREATE TABLE IF NOT EXISTS Server (
    ID INT NOT NULL,
    AreaGeografica VARCHAR(50),
    LarghezzaBanda INT,
    CapacitaMax INT NOT NULL,
    StatoServer INT,
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Utente - - - -

CREATE TABLE IF NOT EXISTS Utente (
    ID INT NOT NULL,
    Nome VARCHAR(50),
    Cognome VARCHAR(50),
    Passw VARCHAR(16),
    Email VARCHAR(100),
    Critico BOOLEAN,
    NomeAbbonamento VARCHAR(10),
    Scadenza Date,
    PRIMARY KEY(ID)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;


# - - - - CREAZIONE TABELLA Visualizzazione - - - -

CREATE TABLE IF NOT EXISTS Visualizzazione(
    ID_Utente INT NOT NULL,
    ID_Contenuto INT NOT NULL,
    TimestampInizio TIMESTAMP, 
    PRIMARY KEY(ID_Utente, ID_Contenuto, TimestampInizio)
)ENGINE = InnoDB DEFAULT CHARSET = latin1;

# - - - - CREAZIONE TABELLA Connessione - - - -

CREATE TABLE IF NOT EXISTS Connessione (
    ID_Utente INT,
    ID_Server INT,
    IndirizzoIP INT NOT NULL,
    Dispositivo VARCHAR(50),
    TimestampInizio TIMESTAMP NOT NULL,
    TimestampFine TIMESTAMP,
    PRIMARY KEY(TimestampInizio, ID_Utente),
    FOREIGN KEY(ID_Utente) REFERENCES Utente (ID) 
)ENGINE = InnoDB DEFAULT CHARSET = latin1;























