#!/bin/ksh
##########################################################################
# Name:  epm_btlr_vldt.sh                                                #
#                                                                        #
# Description: Compares the Bottler to balance tables                    #
#                                                                        #
##########################################################################
# Date       By   	 Description                                     #
# __________ __________  ____________________________________            #
# 06/13/2016 T89228 [OK] QA:CHG0155076 PROD:CHG0155077 RELEASE11 CHANGES #
# 09/09/2016 T83308 [CA] QA:CHG0162867 PROD:CHG0162868 RELEASE12 CHANGES #
# 17/03/2017 T89228 [OK] QA:CHG0185198 PROD:CHG0185199 RELEASE13 CHANGES #
##########################################################################

date +"*** `basename $0` Executing  %Y%m%d %T"

echo "EPM_PGM_DIR is $EPM_PGM_DIR"
echo "EPM_OUT_DATA_DIR is $EPM_OUT_DATA_DIR"
echo "EPM_FILE_DIR is $EPM_FILE_DIR"
echo "EPM_SEC_DIR is $EPM_SEC_DIR"
echo "EPM_TEMPFILS_DIR is $EPM_TEMPFILS_DIR"


if [ $# -gt 0 ]; then
echo "PARAMETER PASSED IS $1"
TYP=$1
else
echo " *** NO PARAMETER PASSED *** "
exit 99
fi

. ${EPM_FILE_DIR}/epm_nonsec.sh
. ${EPM_FILE_DIR}/process_dates.txt

#TWS_SCHED_ALIAS=`echo $UNISON_JOB |cut -f1 -d'.' |cut -f2 -d'#'`
#TWS_SCHED=`echo $UNISON_JOB |sed -e "s,${TWS_SCHED_ALIAS},${UNISON_SCHED},g"`

export epm_file_dir=${EPM_FILE_DIR}
export typ=$TYP
. $EPM_PGM_DIR/epm_${TYP}_btlr_vldt.sh


#PST_PER=`sed -n "/pst_per_curr/p" ${EPM_FILE_DIR}/process_dates.txt | cut -d'/' -f3`
#RUN_TYPE=`sed -n "/rpt_ver_cd_curr/p" ${EPM_FILE_DIR}/process_dates.txt | cut -d'/' -f3`

#sed -f $epm_nonsec_fil \
#    -f $epm_sec_fil \
#    -f ${EPM_FILE_DIR}/process_dates.txt\
#    -e "s,&typ,${TYP},g"\
#    -e "s,&epm_file_dir,${EPM_FILE_DIR},g" \
#    -e "s,${TWS_SCHED},$TWS_SCHED,g" -e "s,${LOGNAME},${LOGNAME},g" \
#     $EPM_PGM_DIR/epm_${TYP}_btlr_vldt.btq > $EPM_TEMPFILS_DIR/epm_${TYP}_btlr_vldt.btq.tmp
     
#bteq < $EPM_TEMPFILS_DIR/epm_${TYP}_btlr_vldt.btq.tmp

#rm -f $EPM_TEMPFILS_DIR/epm_${TYP}_btlr_vldt.btq.tmp

date +"*** `basename $0` Completed  %Y%m%d %T"

exit 0

