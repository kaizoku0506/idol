#!/bin/bash

#################################
##          FUNCTIONS          ##
#################################

create_spec_test() {
	mkdir  -p ${serverspec_dir};
	touch ${spec_test};

	echo "# This file has been auto-generated by Idol." >> ${spec_test};
	echo "" >> ${spec_test};
	echo "require 'serverspec'" >> ${spec_test};
	echo "require 'spec_helper'" >> ${spec_test};
	echo "" >> ${spec_test};
	echo "# Required by serverspec" >> ${spec_test};
	echo "set :backend, :exec" >> ${spec_test};
	echo "" >> ${spec_test};

}

describe_spec() {
	local service_name=${1};

	echo "describe service('"${service_name}"') do" >> ${spec_test};
	
	local i=0;

	for run_level in ${2} ${3} ${4} ${5} ${6} ${7} ${8}; do
		IFS=': ' read -a run_level <<< "${run_level}"

		if [ ${run_level[1]} = "on" ]; then
			echo "  it { should be_enabled.with_level("${run_level[0]}") }" >> ${spec_test};
		fi
		i=$[i + 1];
	done

	if (ps ax | grep -v grep | grep ${service_name} >> /dev/null); then
		echo "  it { should be_running }" >> ${spec_test};
	fi

	echo "end" >> ${spec_test};
	echo "" >> ${spec_test};

}

read_all_services() {
	service_count=$(chkconfig > /tmp/services && wc -l /tmp/services | awk '{ print $1 }');
	echo "Service Count is: "${service_count};

	for (( i=1; i<=${service_count}; i++ )); do
		read_individual_service;
	done;

	rm /tmp/services;
}

read_individual_service() {

	local service_name=$(sed "${i}q;d" /tmp/services | awk '{ print $1 }');
	for n in {0..6}; do
		local x=$[n + 2];
		local run_${n}=$(sed "${i}q;d" /tmp/services | awk '{ print $'$x' }');
	done

	describe_spec ${service_name} ${run_0} ${run_1} ${run_2} ${run_3} ${run_4} ${run_5} ${run_6};
}

#################################
##     INPUT AND VARIABLES     ##
#################################
serverspec_dir=${HOME}/serverspec_tests;
spec_test="${serverspec_dir}/services_spec.rb";


#################################
##      CREATE SPEC TESTS      ##
#################################
create_spec_test;
read_all_services;