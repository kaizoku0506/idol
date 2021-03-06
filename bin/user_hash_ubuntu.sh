#!/bin/bash

set -e

completion() {
    echo "user_hash_ubuntu.sh has completed for idol "${IDOL_NAME} | tee -a ${LOG_OUT};
    echo "Bats Tests Generated: "$(grep -c "@test" ${OUTPUT_BATS});
    exit 0;
}

generate_user_hash() {
    echo "Generating User Golden Hash for "${IDOL_NAME} >> ${LOG_OUT};
    rm -f /tmp/user_hash.txt && touch /tmp/user_hash.txt;
	cat /etc/passwd >> /tmp/user_hash.txt;
	local hashgolden=($(md5sum /tmp/user_hash.txt));
	echo $hashgolden;
}

generate_user_hash_bats() {
    echo "Generating user Hash Test for "${IDOL_NAME} >> ${LOG_OUT};
    echo "@test \"USER CHECK - "${IDOL_NAME}" user HASH\" {" >> ${OUTPUT_BATS};
    echo "cat /etc/passwd > /tmp/user_hash.txt" >> ${OUTPUT_BATS};
    echo "HASHCHECK=(\$(md5sum /tmp/user_hash.txt))" >> ${OUTPUT_BATS};
    echo "[ \$HASHCHECK = ${HASHGOLDEN} ]" >> ${OUTPUT_BATS};
    echo "}" >> ${OUTPUT_BATS};
    echo " " >> ${OUTPUT_BATS};
}

handoff() {
    echo "user_hash_ubuntu.sh has been kicked off by idol_create.sh..." | tee -a ${LOG_OUT};
    echo "user_hash_ubuntu.sh is initiating user hash BATS creation..." | tee -a ${LOG_OUT};
    echo "idol name.................."${IDOL_NAME} | tee -a ${LOG_OUT};
    echo "" | tee -a ${LOG_OUT};
}

initialize_bats() {
    echo "#!/usr/bin/env bats" >> ${OUTPUT_BATS};
    echo "" >> ${OUTPUT_BATS};
    echo "load test_helper" >> ${OUTPUT_BATS};
    echo "fixtures bats" >> ${OUTPUT_BATS};
    echo "" >> ${OUTPUT_BATS};
}

#################################
##     INPUT AND VARIABLES     ##
#################################
HASH_BATS=$1;
IDOL_NAME=$2;
LOG_OUT=$3;

OUTPUT_BATS=${HASH_BATS}/user_hash.bats;

#################################
##     ACKNOWLEDGE HANDOFF     ##
#################################
handoff;

#################################
##         CREATE BATS         ##
#################################
initialize_bats;
HASHGOLDEN=$(generate_user_hash);
generate_user_hash_bats;

#################################
##   ACKNOWLEDGE COMPLETION    ##
#################################
completion;
