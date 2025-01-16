#########################################################################
#                                                                       #
#    Generic executor script to execute Sqoop Scripts                   #
#									#
#    Input Parameter Value Details					#
#    1. Three input parameters for Truncate & Load processes		#
#       A. Job Name							#
#       B. Table Name							#
#       C. Script Directory						#
#    2. Five input parameters for Incremental Load processes		#
#       A. Job Name			                                #
#       B. Table Name                                                   #
#       C. Script Directory                                            #
#       D. Parm File Name				#
#                                                                       #
#########################################################################
#!/bin/bash

#Source the environment file
source /opt/mapr/generic/env_var/env_var.env

echo " " | tee -a "$LOGFP/$LOGFN"
echo "$1 job started" | tee -a "$LOGFP/$LOGFN"

#Input Parameter Validation
if [ $# == 3 ]; then
   echo "Acceptable parameters, Script will start execution after validation" | tee -a "$LOGFP/$LOGFN"
else
   if [ $# == 4 ]; then
      echo "Acceptable parameters, Script will start execution after date validation" | tee -a "$LOGFP/$LOGFN"
   else
      echo "Missing parameters, Retry with correct parameters" | tee -a "$LOGFP/$LOGFN"
      echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
      echo " " | tee -a "$LOGFP/$LOGFN"
      exit 1
   fi
fi

echo "Log file details: $LOGFP/$LOGFN" | tee -a "$LOGFP/$LOGFN"

#Start & End Date Validation 
if [ $# == 4 ]; then

   START=`grep start_dttm /opt/mapr/generic/parm/dt_ctrl/$4|cut -d '~' -f2`
   END=`grep end_dttm /opt/mapr/generic/parm/dt_ctrl/$4|cut -d '~' -f2`

   STS=$(echo $START | sed 's/_/ /g')
   ETS=$(echo $END | sed 's/_/ /g')

   echo "Start_TS value: $STS" | tee -a "$LOGFP/$LOGFN"
   echo "End_TS value: $ETS" | tee -a "$LOGFP/$LOGFN"

   D1=$(date -d "$(echo $STS | sed 's/-//;s/-//;s/-/ /')" +%s 2> /dev/null)
   D2=$(date -d "$(echo $ETS | sed 's/-//;s/-//;s/-/ /')" +%s 2> /dev/null)

   if [ -n "$D1" ]; then
      echo "Start_TS is valid" | tee -a "$LOGFP/$LOGFN"
      if [ -n "$D2" ]; then
         echo "End_TS is valid" | tee -a "$LOGFP/$LOGFN"
      else
         echo "End_TS is invalid timestamp" | tee -a "$LOGFP/$LOGFN"
         echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
         echo " " | tee -a "$LOGFP/$LOGFN"
         exit 1
      fi
   else
      echo "Start_TS is invalid timestamp" | tee -a "$LOGFP/$LOGFN"
      echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
      echo " " | tee -a "$LOGFP/$LOGFN"
      exit 1
   fi

   if [ -n "$D1" -a -n "$D2" -a ${D1:-0} -gt ${D2:-0} ]; then
      echo "Start_TS > End_TS, Validation failed" | tee -a "$LOGFP/$LOGFN"
      echo "Job $1 failed with errors" | tee -a "$LOGFP/$LOGFN"
      echo " " | tee -a "$LOGFP/$LOGFN"
      exit 1
   else
      echo "Start_TS < End_TS, Validation completed successfully" | tee -a "$LOGFP/$LOGFN"
   fi
fi

#Source the Sqoop file to use
source /opt/mapr/projects/opt/scripts/$3/sqoop/$1.sh

echo "Sqoop file details: /opt/mapr/projects/opt/scripts/$3/sqoop/$1.sh" | tee -a "$LOGFP/$LOGFN"

#Trunc & Load Function Execution
if [ $# == 3 ]; then
   echo "Truncate & Load function will start execution" | tee -a "$LOGFP/$LOGFN"
   #fn_delete_sqoop_folder "$2" "$LOGFP/$LOGFN"
   fn_execute_sqoop_export "$2" "$LOGFP/$LOGFN"
fi

#Inc Load Function Execution
if [ $# == 4 ]; then
   echo "Incremental Load function will start execution" | tee -a "$LOGFP/$LOGFN"
   #fn_delete_sqoop_folder "$2" "$LOGFP/$LOGFN" "$STS" "$ETS"
   fn_execute_sqoop_export "$2" "$LOGFP/$LOGFN" "$STS" "$ETS"
fi

echo "Job $1 completed successfully" | tee -a "$LOGFP/$LOGFN"
echo " " | tee -a "$LOGFP/$LOGFN"

#########################################################################
#                                                                       #
#    End Of Script                                                      #
#                                                                       #
#########################################################################
