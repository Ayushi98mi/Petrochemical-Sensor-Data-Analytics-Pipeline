
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'Bronze' schema from an external CSV file. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN
    DECLARE @start_time DATETIME , @end_time DATETIME;
    BEGIN TRY
        PRINT 'Loading Bronze Layer'
        PRINT '==================================================='
        SET @start_time = GETDATE();
        PRINT '>>TRUNCATING Bronze.petrochemical_operations'
        TRUNCATE TABLE Bronze.petrochemical_operations;
        PRINT '>>INSERTING Bronze.petrochemical_operations'
        BULK INSERT Bronze.petrochemical_operations
        FROM 'C:\Users\Ayushi Bajpai\Desktop\Petrochemical process Opti& Maintenance\petrochemical_advanced_data.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT('>>LOAD DURATION:' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR)+ 'Seconds')
    END TRY
    BEGIN CATCH
    PRINT('========================================================')
    PRINT('ERROR OCCURED WHILE LOADING')
    PRINT('ERROR MESSAGE' + ERROR_MESSAGE())
    PRINT('========================================================')
    END CATCH
    PRINT ('>>LOADING IS COMPLETED');
END
