using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;

namespace Data.CLM
{

    /// <summary>
    /// List of the data sources that can be used for managing cases
    /// </summary>
    public enum SupportedSources
    {
        SharePoint
        , SharePointAndSQL
        ,SQL
    }

    public class DataMethods
    {

        //TODO Sharepoint integration is not currently supported - any interaction should be down through a central SharePoint
        //class
        //Code methods where the CLM and case data is held exclusively in SharePoint
        #region SharePoint

        #region Create

        #endregion

        #region Return

        #endregion

        #region Update

        #endregion

        #region Delete

        #endregion

        #endregion

        //TODO Sharepoint integration is not currently supported - any interaction should be down through a central SharePoint
        //class
        //Code methods where the CLM data is held in SQL but the case data itself is held in SharePoint
        #region Sharepoint and SQL

        #region Create

        #endregion

        #region Return

        #endregion

        #region Update

        #endregion

        #region Delete

        #endregion

        #endregion

        //Code methods where the CLM and case data is held exclusively in SQL
        #region SQL

        #region Create

        /// <summary>
        /// Create a new entry in the CLM data table
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseId">The unique identifier for the case that the CLM data relates to</param>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to (optional)</param        /// <remarks>Cases controlled by the CLM class must have an associated ID field (integer) which will be used
        /// to link the CLM data to the case data.</remarks>
        public void CreateCLMEntryInSQL(string provider, int accountingCaseId)
        {
            CreateCLMEntryInSQL(provider, accountingCaseId, null, null, null);
        }

        /// <summary>
        /// Create a new entry in the CLM data table
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseId">The unique identifier for the case that the CLM data relates to</param>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to (optional)</param>
        /// <remarks>Cases controlled by the CLM class must have an associated ID field (integer) which will be used
        /// to link the CLM data to the case data.</remarks>
        public void CreateCLMEntryInSQL(string provider, int accountingCaseId, string organisationalUnit)
        {
            CreateCLMEntryInSQL(provider, accountingCaseId, organisationalUnit, null, null);
        }

        /// <summary>
        /// Create a new entry in the CLM data table
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseId">The unique identifier for the case that the CLM data relates to</param>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to (optional)</param>
        /// <param name="assignedPool">The work pool that the new entry will be assigned to</param>
        /// <remarks>Cases controlled by the CLM class must have an associated ID field (integer) which will be used
        /// to link the CLM data to the case data.</remarks>
        public void CreateCLMEntryInSQL(string provider, int accountingCaseId, string organisationalUnit, string assignedPool)
        {
            CreateCLMEntryInSQL(provider, accountingCaseId, organisationalUnit, assignedPool, null);
        }

        /// <summary>
        /// Create a new entry in the CLM data table
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseId">The unique identifier for the case that the CLM data relates to</param>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to (optional)</param>
        /// <param name="assignedPool">The work pool that the new entry will be assigned to</param>
        /// <param name="assignedUser">The ID of the user that the new entry will be assigned to</param>
        /// <remarks>Cases controlled by the CLM class must have an associated ID field (integer) which will be used
        /// to link the CLM data to the case data.</remarks>
        public void CreateCLMEntryInSQL(string provider, int accountingCaseId, string organisationalUnit, string assignedPool, string assignedUser)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AccountingCaseId", SqlDbType.Int);
            myParam.Value = accountingCaseId;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@AssignedPool", SqlDbType.NVarChar, 50);
            myParam.Value = assignedPool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@AssignedUser", SqlDbType.NVarChar, 10);
            myParam.Value = assignedUser;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "CreateCLMNewEntry");
            myHandler = null;
        }

        /// <summary>
        /// Create the CLM entries in the CLM data table
        /// </summary>
        /// <param name="sqlProvider">The connection string for the CLM data table (SQL)</param>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to (optional)</param>
        /// <remarks>By default, this interaction should be done within SQL at the time the case data is imported.
        /// This method should only be used where CLM data was not created at the time of importing the case data 
        /// </remarks>
        public void CreateCLMEntriesInSQL(string sqlProvider, string organisationalUnit)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, sqlProvider, "CreateCLMNewEntries");
            myHandler = null;
        }

        #endregion

        #region Return

        /// <summary>
        /// Returns a specified CLM entry and its associated case data
        /// </summary>
        /// <param name="provider">The connection string to the data source</param>
        /// <param name="accountingCaseId">The uniwue idenfitier for the CLM entry</param>
        /// <returns></returns>
        public DataTable ReturnCLMEntry(string provider, int accountingCaseId)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AccountingCaseId", SqlDbType.Int);
            myParam.Value = accountingCaseId;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMEntry ");
        }

        /// <summary>
        /// Returns the case currently assigned to the user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <returns></returns>
        /// <remarks>This methods assumes that a user will only ever be assigned one entry at a time (i.e. not one per pool
        /// and\or organisational unit</remarks>
        public DataTable ReturnAssignedCase(string provider)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, "ReturnCLMNextAssignedCase ");
        }

        /// <summary>
        /// Returns the case currently assigned to the user (but not worked) in the specified pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="pool">The pool that the work is assigned to</param>
        /// <returns></returns>
        public DataTable ReturnAssignedCase(string provider, string pool)
        {
            return ReturnAssignedCase(provider, null, pool);
        }

        /// <summary>
        /// Returns the case currently assigned to the user (but not worked) in the specified organisational unit\pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the case must relate to (optional)</param>
        /// <param name="pool">The pool that the work is assigned to</param>
        /// <returns></returns>
        public DataTable ReturnAssignedCase(string provider, string organisationalUnit, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMNextAssignedEntryByUnitAndPool"); 
        }

        //TODO add other options for viewing current users cases
        
        /// <summary>
        /// Returns all of the oustanding CLM entries
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntries(string provider)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, "ReturnCLMOutstandingEntriesAll");
        }

        /// <summary>
        /// Returns the oustanding entries for a specified organisational unit
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the entries must relate to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByUnit(string provider, string organisationalUnit)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnit");
        }

        /// <summary>
        /// Return the outstanding cases in the specified unit\pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that cases must relate to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByUnitAndPool(string provider, string organisationalUnit, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitAndPool");
        }

        /// <summary>
        /// Returns the outstanding entries in the specified pool
        /// </summary>
        /// <param name="provider">The connection string for the data sourc</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByPool(string provider, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInPool");
        }

        /// <summary>
        /// Returns the unassigned cases in the specified organisational unit
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases must relate to</param>
        /// <returns></returns>
        public DataTable ReturnUnassignedEntriesByUnit(string provider, string organisationalUnit)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOUnassignedEntriesInOrganisationalUnit");
        }

        /// <summary>
        /// Returns the unassigned cases in a specified unit\pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The origanisational unit that cases must relate to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <returns></returns>
        public DataTable ReturnUnassignedEntriesByUnitAndPool(string provider, string organisationalUnit, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMUnassignedEntriesInOrganisationalUnitAndPool");
        }

        /// <summary>
        /// Returns the unassigned cases in the specified pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="pool">The pool that cases have been assigned to</param>
        /// <returns></returns>
        public DataTable ReturnUnassignedEntriesByPool(string provider, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMUnassignedEntriesInPool");
        }

        public DataTable ReturnOutstandingEntries(string provider, string organisationalUnit, DateTime dateAssigned)
        {
            return ReturnOutstandingEntries(provider, organisationalUnit, dateAssigned, dateAssigned);
        }

        /// <summary>
        /// Returns the cases assigned to users in a specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that cases must relate to</param>
        /// <param name="dateAssignedStart">The start of the date range</param>
        /// <param name="dateAssignedEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntries(string provider, string organisationalUnit, DateTime dateAssignedStart, DateTime dateAssignedEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartOfRange", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndOfRange", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitByDateAssignedToUser");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the specified unit\pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="pool">The pool that cases have been assigned to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntries(string provider, string organisationalUnit, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitAndPool");
        }

        /// <summary>
        /// Returns the outstanding cases that were assigned to the specified unit\pool on the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases were assigned to</param>
        /// <param name="pool">The pool that the cases were assigned to</param>
        /// <param name="dateAssigned">The date that the cases were assigned</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByDateAssignedToPool(string provider, string organisationalUnit, string pool, DateTime dateAssigned)
        {
            return ReturnOutstandingEntriesByDateAssignedToPool(provider, organisationalUnit, pool, dateAssigned, dateAssigned);
        }

        /// <summary>
        /// Returns the outstanding cases that were assigned to the specified unit\pool in the specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organsiational unit that the cases were assigned to</param>
        /// <param name="pool">The pool that the cases were assigned to</param>
        /// <param name="dateAssignedToPoolStart">The start of the date range</param>
        /// <param name="dateAssignedToPoolEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByDateAssignedToPool(string provider, string organisationalUnit, string pool, DateTime dateAssignedToPoolStart, DateTime dateAssignedToPoolEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedToPoolStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedToPoolEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateAssignedToPool");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to users in the specified unit\pool on the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases were assigned to</param>
        /// <param name="pool">The pool that cases were assigned to</param>
        /// <param name="dateAssignedToUser">The date that the cases were assigned to users</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByDateAssignedToUser(string provider, string organisationalUnit, string pool, DateTime dateAssignedToUser)
        {
            return ReturnOutstandingEntriesByDateAssignedToUser(provider, organisationalUnit, pool, dateAssignedToUser, dateAssignedToUser);
        }

        /// <summary>
        /// Returns the outstanding cases assigned to users in the specified unit\pool in the specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases were assigned to</param>
        /// <param name="pool">The pool that cases were assigned to</param>
        /// <param name="startDate">The start of the date range</param>
        /// <param name="endDate">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByDateAssignedToUser(string provider, string organisationalUnit, string pool, DateTime startDate, DateTime endDate)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = startDate.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = startDate.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateAssignedToUser");
        }

        /// <summary>
        /// Returns the cases assigned to the specified unit that relate to cases with the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="dateOfCase">The date that the cases must relate to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByCaseDate(string provider, string organisationalUnit, DateTime dateOfCase)
        {
            return ReturnOutstandingEntriesByCaseDate(provider, organisationalUnit, dateOfCase, dateOfCase);
        }

        /// <summary>
        /// Returns the cases assigned to the specified unit that relate to cases in the spcified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organsiational unit that the cases must relate to</param>
        /// <param name="dateOfCaseStart">The start of the date range</param>
        /// <param name="dateofCaseEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByCaseDate(string provider, string organisationalUnit, DateTime dateOfCaseStart, DateTime dateofCaseEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateofCaseEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitByDateOfCase");
        }

        /// <summary>
        /// Returns the cases assigned to the specified unit\pool where the date of the case matches the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <param name="dateAssigned">The date that the cases must relate to</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByCaseDate(string provider, string organisationalUnit, string pool, DateTime dateAssigned)
        {
            return ReturnOutstandingEntriesByCaseDate(provider, organisationalUnit, pool, dateAssigned, dateAssigned);
        }

        /// <summary>
        /// Returns the cases assigned to the specified unit\pool where the date of the case is in the specified range
        /// </summary>
        /// <param name="provider">The connection  string for the data sourceparam>
        /// <param name="organisationalUnit">The organisational unit that the cases relate to</param>
        /// <param name="pool">The pool that the cases relate to</param>
        /// <param name="dateAssignedStart">The start of the range</param>
        /// <param name="dateAssignedEnd">The end of the range</param>
        /// <returns></returns>
        public DataTable ReturnOutstandingEntriesByCaseDate(string provider, string organisationalUnit, string pool, DateTime dateAssignedStart, DateTime dateAssignedEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMOutstandingEntriesInOrganisationalUnitAndPoolByDateOfCase");
        }

        /// <summary>
        /// Returns the cases assigned to the current user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <returns></returns>
        public DataTable ReturnMyCases(string provider)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, "ReturnCLMMyCases");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <returns></returns>
        public DataTable ReturnMyCases(string provider, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByPool");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user in the specified unit\pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <returns></returns>
        public DataTable ReturnMyCases(string provider, string organisationalUnit, string pool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByUnitAndPool");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user on the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="dateAssigned">The date that the work was assigned to the user</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByDateAssigned(string provider, DateTime dateAssigned)
        {
            return ReturnMyCasesByDateAssigned(provider, dateAssigned, dateAssigned);
        }


        /// <summary>
        /// Returns the outstanding cases assigned to the current user in the specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="dateAssignedStart">The start of the date range</param>
        /// <param name="dateAssignedEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByDateAssigned(string provider, DateTime dateAssignedStart, DateTime dateAssignedEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedStart.ToString("yyyyMMdddd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateAssignedEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByDateAssigned");
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user where the case date is on the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="dateOfCase">The date that the cases must relate to/param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, DateTime dateOfCase)
        {
            return ReturnMyCasesByCaseDate(provider, dateOfCase, dateOfCase);
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user where the case date is in the specified range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="dateOfCaseStart">The start of the date range</param>
        /// <param name="dateOfCaseEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, DateTime dateOfCaseStart, DateTime dateOfCaseEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByDateOfCase");
        }

        /// <summary>
        /// Returns the outstanding cases for the current user which are assigned to the specified unit and have the specified 
        /// case date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that cases must be assigned to</param>
        /// <param name="dateOfCase">The date that the cases must match</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, string organisationalUnit, DateTime dateOfCase)
        {
            return ReturnMyCasesByCaseDate(provider, organisationalUnit, dateOfCase, dateOfCase);        }

        /// <summary>
        /// Returns the outstanding cases for the current user which are assigned to the specified unit and are within the 
        /// specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that cases must be assigned to</param>
        /// <param name="dateOfCaseStart">The start of the date range</param>
        /// <param name="dateOfCaseEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, string organisationalUnit, DateTime dateOfCaseStart,DateTime dateOfCaseEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseEnd.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByUnitAndDateOfCase");
        }

        /// <summary>
        /// Returns outstanding cases assigned to the current user and in the specified unit\pool where the date of the case
        /// matches the specified date
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <param name="dateOfCase">The date that the cases must relate to</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, string organisationalUnit, string pool, DateTime dateOfCase)
        {
            return ReturnMyCasesByCaseDate(provider, organisationalUnit, pool, dateOfCase, dateOfCase);
        }

        /// <summary>
        /// Returns the outstanding cases assigned to the current user and in the specified unit\pool where the date of the
        /// case in in the specified date range
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The organisational unit that the cases are assigned to</param>
        /// <param name="pool">The pool that the cases are assigned to</param>
        /// <param name="dateOfCaseStart">The start of the date range</param>
        /// <param name="dateOfCaseEnd">The end of the date range</param>
        /// <returns></returns>
        public DataTable ReturnMyCasesByCaseDate(string provider, string organisationalUnit, string pool, DateTime dateOfCaseStart, DateTime dateOfCaseEnd)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = pool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@StartDate", SqlDbType.NChar, 8);
            myParam.Value = dateOfCaseStart.ToString("yyyyMMdd");
            paramArray.Add(myParam);
            myParam = new SqlParameter("@EndDate", SqlDbType.NChar, 8);
            paramArray.Add(myParam);
            return myHandler.RunStoredProcedureAndReturnSingleTable(provider, ref paramArray, "ReturnCLMMyCasesByUnitPoolAndDateOfCase");
        }

        #endregion

        #region Update

        /// <summary>
        /// Assigns the specified case to the specified pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseId">The unique identifier for the case</param>
        /// <param name="assignedPool">The pool that the case should be reassigned to</param>
        public void UpdateAssignedPool(string provider, int accountingCaseId, string assignedPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AccountingCaseId", SqlDbType.Int);
            myParam.Value = accountingCaseId;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMAssignCaseToPool");
            myHandler = null;
        }

        /// <summary>
        /// Assigns the specified cases to the specified pools
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseIds">An array of the unique identifiders for the CLm entries being assigned to the pool</param>
        /// <param name="assignedPool">The pool that the cases will be assigned to</param>
        public void UpdateAssignedPool(string provider, int[] accountingCaseIds, string assignedPool)
        {
            DataTable temp = new DataTable();
            DataColumn col = new DataColumn("AccountingCaseId", System.Type.GetType("System.int32"));
            temp.Columns.Add(col);
            foreach(int item in accountingCaseIds)
            {
                DataRow newRow = temp.NewRow();
                newRow["AccoutingCaseId"] = item;
                temp.Rows.Add(newRow);
            }
            UpdateAssignedPool(provider, ref temp, assignedPool);
            temp = null;
        }

        /// <summary>
        /// Assigns the specified cases to the specified pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseIds">A table containing the unique identifiers of the cases to be assigned to the
        /// pool</param>
        /// <param name="assignedPool">The pool that the cases will be assigned to</param>
        public void UpdateAssignedPool(string provider, ref DataTable accountingCaseIds, string assignedPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            myHandler.InsertBulkData(ref accountingCaseIds, provider, "CLMDataTemp");
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = assignedPool;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMAssignCasesToPool");
            myHandler = null;
        }

        /// <summary>
        /// Assigns the next available case to the current user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="assignedPool">The pool that work is to be assigned from</param>
        /// <param name="organisationalUnit">The work area that the pool is associated with (optional)</param>
        public void UpdateAssignNextCase(string provider, string assignedPool, string organisationalUnit)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NChar, 50);
            myParam.Value = assignedPool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(provider, "UpdateCLMAssignNextCase");
            myHandler = null;
        }

        /// <summary>
        /// Assigns the next available case to the current user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="assignedPool">The pool that work is to be assigned from</param>
        public void UpdateAssignNextCase(string provider, string assignedPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NChar, 50);
            myParam.Value = assignedPool;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(provider, "UpdateCLMAssignNextCase");
            myHandler = null;
        }

        /// <summary>
        /// Reassign a case to a specified user
        /// </summary>
        /// <param name="provider">The connection string for the data sourc</param>
        /// <param name="accountingCaseId">The unique identifier of the CLM case being reassigned</param>
        /// <param name="assignTo">The identifier of the user that the cases will be reassigned to</param>
        public void UpdateReassignCase(string provider, int accountingCaseId, string assignTo)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AccountingCaseId", SqlDbType.Int);
            myParam.Value = accountingCaseId;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@ReassignCaseTo", SqlDbType.NVarChar, 10);
            myParam.Value = assignTo;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(provider, "UpdateCLMReassignCase");
            myHandler = null;
        }

        /// <summary>
        /// Reassign the specified cases to the specified user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="casesToReassign">The unique identifiers for the cases that are to be reassigned</param>
        /// <param name="assignTo">The unique identifier of the person that the cases will be assigned to</param>
        public void UpdateReassignCase(string provider, int[] accountingCaseIds, string assignTo)
        {
            DataTable temp = new DataTable();
            DataColumn col = new DataColumn("AccountingCaseId", System.Type.GetType("System.int32"));
            temp.Columns.Add(col);
            foreach (int item in accountingCaseIds)
            {
                DataRow newRow = temp.NewRow();
                newRow["AccoutingCaseId"] = item;
                temp.Rows.Add(newRow);
            }
            UpdateReassignCase(provider, ref temp, assignTo);
            temp = null;
        }

        /// <summary>
        /// Reassign the specified cases to the specified user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="casesToReassign">The unique identifiers for the cases that are to be reassigned</param>
        /// <param name="assignTo">The unique identifier of the person that the cases will be assigned to</param>
        public void UpdateReassignCase(string provider, ref DataTable casesToReassign, string assignTo)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            myHandler.InsertBulkData(ref casesToReassign, provider, "CLMDataTemp");
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@ReassignCaseTo", SqlDbType.NVarChar, 10);
            myParam.Value = assignTo;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMReassignCasesInTemp");
            myHandler = null;
        }

        /// <summary>
        /// Reassign the outstanding cases for a specified user to another user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="originalUser">The unique identifier of the user that the cases are assigned to</param>
        /// <param name="assignTo">The unique identifier of the user that the cases will be reassigned to</param>
        public void UpdateReassignUsersCases(string provider, string originalUser, string assignTo)
        {
            UpdateReassignUsersCases(provider, originalUser, null, assignTo);
        }

        /// <summary>
        /// Reassign the outstanding cases for a specified user to another user
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="originalUser">The unique identifier of the user that the cases are assigned to</param>
        /// <param name="organisationalUnit">The organisational grouping that the cases must relate to (nullable)</param>
        /// <param name="assignTo">The unique identifier of the user that the cases will be reassigned to</param>
        public void UpdateReassignUsersCases(string provider, string originalUser, string organisationalUnit, string assignTo)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AssignedUser", SqlDbType.NVarChar, 10);
            myParam.Value = originalUser;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@AssignTo", SqlDbType.NVarChar, 10);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMReallocateUsersCaseToAnotherUser");
            myHandler = null;
        }

        /// <summary>
        /// Reassigns the outstanding cases from one pool to another
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="currentPool">The pool that the work will be taken from</param>
        /// <param name="newPool">The pool that the work will be moved to</param>
        public void UpdateReassignCasesToNewPool(string provider, string currentPool, string newPool)
        {
            UpdateReassignCasesToNewPool(provider, currentPool, null, newPool);
        }

        /// <summary>
        /// Reassigns the outstanding cases from one pool to another
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="currentPool">The pool that the work will be taken from</param>
        /// <param name="organisationalUnit">The organisational pool that the cases relate to</param>
        /// <param name="newPool">The pool that the work will be moved to</param>
        public void UpdateReassignCasesToNewPool(string provider, string currentPool, string organisationalUnit, string newPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@AssignedPool", SqlDbType.NVarChar, 50);
            myParam.Value = currentPool;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@NewPool", SqlDbType.NVarChar, 50);
            myParam.Value = newPool;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMReassignCasesToNewPool");
        }

        public void UpdateReassignCasesToNewPool(string provider, int[] accountingCaseIds, string newPool)
        {
            DataTable temp = new DataTable();
            DataColumn col = new DataColumn("AccountingCaseId", System.Type.GetType("System.int32"));
            temp.Columns.Add(col);
            foreach (int item in accountingCaseIds)
            {
                DataRow newRow = temp.NewRow();
                newRow["AccoutingCaseId"] = item;
                temp.Rows.Add(newRow);
            }
            UpdateReassignCasesToNewPool(provider, ref temp, newPool);
            temp = null;
        }

        /// <summary>
        /// Reassigns the specified cases to the specified work pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="accountingCaseIds">The cases to be reassigned</param>
        /// <param name="newPool">The pool that the cases will be reassigned to</param>
        public void UpdateReassignCasesToNewPool(string provider, ref DataTable accountingCaseIds, string newPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            myHandler.InsertBulkData(ref accountingCaseIds, provider, "CLMDataTemp");
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value = newPool;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMReassignCasesInTempToNewPool");
            myHandler = null;
        }

        /// <summary>
        /// Remove all of the unworked cases from the specified pool so that they return to the unassigned CLM cases pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The work area that the cases relate to</param>
        /// <param name="currentPool">The pool that the cases relate to</param>
        public void UpdateResetPool(string provider, string currentPool)
        {
            UpdateResetPool(provider, null, currentPool);
        }

        /// <summary>
        /// Remove all of the unworked cases from the specified pool so that they return to the unassigned CLM cases pool
        /// </summary>
        /// <param name="provider">The connection string for the data source</param>
        /// <param name="organisationalUnit">The work area that the cases relate to</param>
        /// <param name="currentPool">The pool that the cases relate to</param>
        public void UpdateResetPool(string provider, string organisationalUnit, string currentPool)
        {
            New_Wrapper.DataHandler myHandler = new New_Wrapper.DataHandler();
            List<SqlParameter> paramArray = new List<SqlParameter>();
            SqlParameter myParam = new SqlParameter("@OrganisationalUnit", SqlDbType.NVarChar, 50);
            myParam.Value = organisationalUnit;
            paramArray.Add(myParam);
            myParam = new SqlParameter("@Pool", SqlDbType.NVarChar, 50);
            myParam.Value= currentPool;
            paramArray.Add(myParam);
            myHandler.RunStoredProcedure(ref paramArray, provider, "UpdateCLMResetPool");
            myHandler = null;
        }

        #endregion

        #region Delete

        #endregion

        #endregion

    }
}
