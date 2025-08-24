USE BD_store;
GO

-- Script pour peupler DimDate (Adaptez les ann�es de d�but et de fin)
-- V�rifiez d'abord les dates min et max dans votre staging table pour adapter la plage
DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2017-12-31';

-- Affiche la plage de dates qui sera g�n�r�e (optionnel)
PRINT 'D�but du peuplement de DimDate pour la plage : ' + CONVERT(VARCHAR, @StartDate) + ' � ' + CONVERT(VARCHAR, @EndDate);

WHILE @StartDate <= @EndDate
BEGIN
    -- V�rifie si la date existe d�j� avant d'ins�rer
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
            DATEPART(MONTH, @StartDate), -- Mois num�rique
            DATENAME(MONTH, @StartDate), -- Nom du mois
            DATEPART(QUARTER, @StartDate), -- Trimestre
            DATEPART(YEAR, @StartDate), -- Ann�e
            CASE WHEN DATENAME(WEEKDAY, @StartDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END -- Weekend
        );
        
        -- Affiche une confirmation pour chaque date ins�r�e (optionnel, peut �tre retir� pour plus de performance)
        PRINT 'Date ins�r�e : ' + CONVERT(VARCHAR, @StartDate);
    END
    -- ELSE -- Optionnel: pour voir les dates d�j� existantes
    -- BEGIN
    --     PRINT 'Date d�j� existante : ' + CONVERT(VARCHAR, @StartDate);
    -- END

    SET @StartDate = DATEADD(DAY, 1, @StartDate); -- Passe au jour suivant
END

PRINT 'Peuplement de DimDate termin�.';
GO