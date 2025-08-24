USE BD_store;
GO

-- Script pour peupler DimDate (Adaptez les années de début et de fin)
-- Vérifiez d'abord les dates min et max dans votre staging table pour adapter la plage
DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2017-12-31';

-- Affiche la plage de dates qui sera générée (optionnel)
PRINT 'Début du peuplement de DimDate pour la plage : ' + CONVERT(VARCHAR, @StartDate) + ' à ' + CONVERT(VARCHAR, @EndDate);

WHILE @StartDate <= @EndDate
BEGIN
    -- Vérifie si la date existe déjà avant d'insérer
    IF NOT EXISTS (SELECT 1 FROM DimDate WHERE DateKey = CONVERT(INT, CONVERT(CHAR(8), @StartDate, 112)))
    BEGIN
        INSERT INTO DimDate (
            DateKey,
            [Date],
            [Day],
            DayName,
            [Month],
            MonthName,
            [Quarter],
            [Year],
            IsWeekend
        )
        VALUES (
            CONVERT(INT, CONVERT(CHAR(8), @StartDate, 112)), -- YYYYMMDD en INT
            @StartDate, -- Date
            DATEPART(DAY, @StartDate), -- Jour du mois
            DATENAME(WEEKDAY, @StartDate), -- Nom du jour
            DATEPART(MONTH, @StartDate), -- Mois numérique
            DATENAME(MONTH, @StartDate), -- Nom du mois
            DATEPART(QUARTER, @StartDate), -- Trimestre
            DATEPART(YEAR, @StartDate), -- Année
            CASE WHEN DATENAME(WEEKDAY, @StartDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END -- Weekend
        );
        
        -- Affiche une confirmation pour chaque date insérée (optionnel, peut être retiré pour plus de performance)
        PRINT 'Date insérée : ' + CONVERT(VARCHAR, @StartDate);
    END
    -- ELSE -- Optionnel: pour voir les dates déjà existantes
    -- BEGIN
    --     PRINT 'Date déjà existante : ' + CONVERT(VARCHAR, @StartDate);
    -- END

    SET @StartDate = DATEADD(DAY, 1, @StartDate); -- Passe au jour suivant
END

PRINT 'Peuplement de DimDate terminé.';
GO