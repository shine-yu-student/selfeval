#!/bin/bash

config_file=$1
tfm=$TIMEFORMAT
$TIMEFORMAT='%3R'

readarray -t arr -d "\n" < $config_file

workspace_dir="${arr[1]}"
sandbox_dir="${arr[2]}"
checker_dir="${arr[3]}"
compile_args="${arr[4]}"

mkdir $sandbox_dir

array_size="${#arr[@]}"

ptr=5

while (($ptr<array_size))
do
	readarray -d " " -t subarr < <(echo -e "${arr[$ptr]}")
	task_name="${subarr[0]}"
	checker_name="${subarr[1]}"
	file_pattern="${subarr[2]}"
	task_number="${subarr[3]}"
	time_limit=$(echo "${subarr[4]}*0.001" | bc)"s"
	echo "Judging task $task_name:"
	printf "Compiling checker: "
	g++ $checker_dir/$checker_name.cpp -o $sandbox_dir/checker -std=c++20 -O2 --static
	result=$?
	if ((result > 0))
	then
		printf "failed returning %d.\n" $result
		continue
	fi
	printf "done.\n"
	printf "Compiling std: "
	g++ $workspace_dir/$task_name/$task_name.cpp -o $sandbox_dir/std $compile_args
	result=$?
	if ((result > 0))
	then
		printf "failed returning %d.\n" $result
		continue
	fi
	printf "done.\n"
	cd $sandbox_dir
	tptr=1
	while [ $tptr -le $task_number ]
	do
		printf "Running on task $tptr:"
		file_name=${file_pattern/{}/$tptr}
		cp $workspace_dir/$task_name/$file_name.in $task_name.in
		cp $workspace_dir/$task_name/$file_name.ans $task_name.ans
		proc_time=$(time "timeout $time_limit ./std")
		result=$?
		if((result == 124))
		then
			printf "Time limit exceeded.\n"
			continue
		fi
		printf "Program exited with return value %d in %s seconds" $result $proc_time
	done