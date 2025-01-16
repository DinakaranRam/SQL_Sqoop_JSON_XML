#########################################################################
#                                                                       #
#    Oracle script truncate oracle table                                #
#                                                                       #
#    Input Parameter Value Details (Three input parameters)             #
#    1. Job name	                                                #
#    2. DB Table name to process			                #
#    3. Input SQL file name				                #
#    4. DB Schema                                                       #
#    5. DB                                                              #
#                                                                       #
#########################################################################
#!/usr/bin/ksh

#Source the environment file
source /opt/mapr/generic/env_var/env_var.env

echo " " | tee -a "$LOGFP/$LOGFN"
echo "$1 job started" | tee -a "$LOGFP/$LOGFN"

#Input Parameter Validation
if [ $# == 4 ] || [ $# == 5 ]; then
   echo "Acceptable parameters, Script will start execution" | tee -a "$LOGFP/$LOGFN"
else
    echo "Missing parameters, Retry with correct parameters" | tee -a "$LOGFP/$LOGFN"
    echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
    echo " " | tee -a "$LOGFP/$LOGFN"
    exit 1
fi

#Table Details
TBLNME=$2

#SQL file details
SQLFN=$3

#Database Schema
SCHEMA=$4
if [ $# == 5 ]; then
  if [ "$5" == "HST" ]; then
      DB_NAME=$HSTDBNAME
      DB_USER=$HSTDBUSER
      DB_PWD=$HSTDBPWD
      
  elif [ "$5" == "WHS" ]; then
      DB_NAME=$WHSDBNAME
      DB_USER=$WHSDBUSER
      DB_PWD=$WHSDBPWD
      
  elif [ "$5" == "ECD" ]; then
      DB_NAME=$ECD_DBNAME
      DB_USER=$ECD_DBUSER
      DB_PWD=$ECD_DBPWD
      
  elif [ "$5" == "SNI" ]; then
      DB_NAME=$SNI_DBNAME
      DB_USER=$SNI_DBUSER
      DB_PWD=$SNI_DBPWD
  else
      echo "Incorrect database selection, Retry with correct HST, WHS, ECD, or ERT" | tee -a "$LOGFP/$LOGFN"
      echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
      echo " " | tee -a "$LOGFP/$LOGFN"
      exit 1
  fi
fi

echo "SQL file details: $SQLFP/$SQLFN" | tee -a "$LOGFP/$LOGFN"
echo "Log file details: $LOGFP/$LOGFN" | tee -a "$LOGFP/$LOGFN"

#SQL Section
export ORACLE_HOME=/opt/oracle/product/12.1.0.2
export TNS_ADMIN=/opt/oracle/product/12.1.0.2/network/admin
export LD_LIBRARY_PATH=/lib:/usr/lib:$ORACLE_HOME/lib:/opt/oracle/product/12.1.0.2/bin
export PATH=$PATH:/usr/bin:/usr/sbin:$ORACLE_HOME/bin:$HOME/bin

if [ $# == 4 ]; then
	sqlplus -s ${HSTDBUSER}/${HSTDBPWD}@${HSTDBNAME} @${SQLFP}/${SQLFN} ${TBLNME} ${SCHEMA} >> $LOGFP/$LOGFN 2>&1
else
	sqlplus -s ${DB_USER}/${DB_PWD}@${DB_NAME} @${SQLFP}/${SQLFN} ${TBLNME} ${SCHEMA} >> $LOGFP/$LOGFN 2>&1
fi

#If SQL_ERROR !=0 then there was a failure in the sqlplus execution
if [ $? != 0 ]; then
   echo "SQLPLUS failed with error" | tee -a "$LOGFP/$LOGFN" 
   echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
   echo " " | tee -a "$LOGFP/$LOGFN" 
   exit 1
else
  echo "SQLPLUS completed successfully" | tee -a "$LOGFP/$LOGFN" 
fi


#########################################################################
#                                                                       #
#    End Of Script                                                      #
#                                                                       #
#########################################################################
