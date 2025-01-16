#########################################################################
#                                                                       #
#    Sqoop Script to export API_LAYER to LOG_API_S                   #
#                                                                       #
#    Parameter Details                                                  #
#    1. Table Name                                                      #
#    2. Log File Details                                                #
#                                                                       #
#########################################################################

#Function Execute Sqoop Export
function fn_execute_sqoop_export()
{
echo "Sqoop: ${HSTSQOOP}" | tee -a "$2"
echo "Username: ${HSTDBUSER}" | tee -a "$2"
echo "Password: **********" | tee -a "$2"
echo "ENVDTL: ${ENVDTL}" | tee -a "$2"

sqoop export \
-Dmapreduce.map.memory.mb=8192 \
-Dmapreduce.map.java.opts=-Xmx7200m \
-Dmapreduce.task.io.sort.mb=2400 \
--connect "${HSTSQOOP}" \
--username "${HSTDBUSER}" \
--password "${HSTDBPWD}" \
--direct \
--export-dir /projects/d4_fdbk/d4_fdbk_prc/api_layer_s \
--table STG.LOG_API_S \
--fields-terminated-by '\001' \
--input-null-string "\\\\N" \
--input-null-non-string "\\\\N"  >> $2 2>&1

if [ $? == 0 ];then
   echo "Sqoop export function executed successfully" | tee -a "$2"
else
   echo "Sqoop export function failed" | tee -a "$2"
   echo "Job failed with errors" | tee -a "$2"
   echo " " | tee -a "$2"
   exit 1
fi
}

