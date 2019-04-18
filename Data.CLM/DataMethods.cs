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
