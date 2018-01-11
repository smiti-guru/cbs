#!/bin/ksh
############################################################################
#                                                                          #
# Name:   epm_acdates_run_mstr.sh                                          #
#                                                                          #
# Description: First step of GPI run process to calculate the dates        #
#              for the GPI Run based on the key date ( run_dt )            #
#                                                                          #
#                                                                          #
############################################################################
# Date        By         Modification                                      #
# __________  __________ ________________________________________________  #
# 09/14/2016  T89228[OK] QA:CHG0162867 PROD:CHG0162868 Release 12 Changes  #
# 10/27/2016  T81657[SV] QA:CHG0167414 PROD:CHG0167415 Final run ACDATES   #
#                                    		 	update issue fix   #
# 01/06/2017  T89228[OK] QA:CHG0207723 PROD:CHG0207724 Run Day change      #
############################################################################

date +"*** `basename $0` Executing  %Y%m%d %T"

. ${EPM_FILE_DIR}/epm_nonsec.sh

set -e
trap 'exit_rtn' ERR

function exit_rtn
{
dbcrc=$?
if test $dbcrc -eq 0
then
  exit 0
else
  echo "Error found... $epm_script terminating"
  exit $dbcrc
fi
}


echo " "
echo "EPM_PGM_DIR is $EPM_PGM_DIR"
echo "EPM_SEC_DIR is $EPM_SEC_DIR"
echo "EPM_TEMPFILS_DIR is $EPM_TEMPFILS_DIR"
echo " "

#TWS_SCHED_ALIAS=`echo $UNISON_JOB |cut -f1 -d'.' |cut -f2 -d'#'`
#TWS_SCHED=`echo $UNISON_JOB |sed -e "s,${TWS_SCHED_ALIAS},${UNISON_SCHED},g"`


run_day=$(date +"%a")
echo RUN_DAY: $run_day

if [ $run_day == "Thu" ]; 
then   
	rpt_ver_cd="F"
	echo "Final Run REPORT VERSION CODE IS : $rpt_ver_cd"
	## new year check ##
	mth=$(date +"%m")
	if [ $mth == "01" ];
	then 
		echo "It is January, Run is for previous year December"
		yr=$(( `date +'%Y'` - 1 ))
		mnth="12"
		pst_per=$yr$mnth
		echo "PST PER ${pst_per}"
	else
		pst_per=$(( `date +'%Y%m'` - 1))
		echo "PST PER ${pst_per}"
	fi
elif [ $run_day == "Wed" ]; 
then
	rpt_ver_cd="A"
	echo "Accrual Run REPORT VERSION CODE IS : $rpt_ver_cd"
	pst_per=$((`date +'%Y%m'`))
	echo "PST PER ${pst_per}"
else
echo "Not a Valid day for run"
fi

export pst_per=$pst_per
export rpt_ver_cd=$rpt_ver_cd

bteq << EOFBTEQ
/*****************************************************************************/
/* Name:    epm_acdates_run_mstr.btq    	                             */
/*                                                                           */
/* Description: To populate the epm dates table for the GPI run.             */
/*									     */
/*****************************************************************************/
/* Date        Who  	   Release                                           */
/* _________   __________  _______________________________________________   */
/* 09/14/2016  T89228[OK]  QA:CHG0162867 PROD:CHG0162868 Release 12 Changes  */
/*****************************************************************************/


.run file $EPM_SEC_FIL;


.set MAXERROR 1
.set ERRORLEVEL 3624 SEVERITY 0; /* ignore collect statistics error  */
.set ERROROUT STDOUT

SET QUERY_BAND='UTILITYNAME=BTEQ;OSUSER=${LOGNAME};PROJECT=EPM;PROCESS/REPORT=epm_acdates_run_mstr.btq;Job=${TWS_SCHED};' FOR SESSION;


DELETE FROM $dbepmtables.epm_acdates_mstr
WHERE pst_per='$pst_per'
and RPT_VER_CD ='$rpt_ver_cd' ;

.if ERRORLEVEL <> 0 THEN .GOTO FAILURE

LOCKING TABLE $dbcontrol.ACDATES_MSTR FOR ACCESS

---selecting new cal_dt as schedules will run at the weekend of the closing week or a week after the closing week.
Insert into  $dbepmtables.epm_acdates_mstr
(run_dt
,rn_typ
,cal_typ_cd
,cal_per_strt_dt
,cal_per_end_dt
,cal_per_abbr_txt
,cal_per_nm
,pst_per
,rpt_ver_cd
,per_strt
,per_end
)
 SEL
current_date -1
,'YTD' (CHAR(04))
,cal_typ_cd
,Cal_yr_strt_dt as strt_dt
,cal_per_end_dt as end_dt
,cal_per_abbr_txt
,cal_per_nm
,trim(cur_yr_ac_prd)(char(6))
,'$rpt_ver_cd' as rpt_ver_cd
,cur_yr_ac_prd as per_strt
,cur_yr_ac_prd as per_end
from $dbcontrol.acdates_mstr 
where 
cur_yr_ac_prd ='$pst_per'
group by 1,2,3,4,5,6,7,8,9,10,11

UNION ALL

 SEL
current_date -1
,'CURR' (CHAR(04))
,cal_typ_cd
,Cal_per_strt_dt as strt_dt
,cal_per_end_dt as end_dt
,cal_per_abbr_txt
,cal_per_nm
,trim(cur_yr_ac_prd)(char(6))
,'$rpt_ver_cd' as rpt_ver_cd
,cur_yr_ac_prd as per_strt
,cur_yr_ac_prd as per_end
from $dbcontrol.acdates_mstr 
where
cur_yr_ac_prd ='$pst_per'
group by 1,2,3,4,5,6,7,8,9,10,11
;

                 
.if ERRORLEVEL <> 0 THEN .GOTO FAILURE
 
 COLLECT STATS ON $dbepmtables.epm_acdates_mstr;
.if ERRORLEVEL <> 0 THEN .GOTO FAILURE
.quit 0 
 
.LABEL FAILURE
.REMARK '*** BTEQ error detected. ***'
.quit 99                 
                 
EOFBTEQ

date +"*** `basename $0` Completed  %Y%m%d %T"

exit 0