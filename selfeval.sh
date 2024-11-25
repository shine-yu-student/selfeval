#!/bin/bash

config_file=$1
tfm=$TIMEFORMAT
TIMEFORMAT='%3R'
debug_patch=0

if (($2 == "-d"))
then
	debug_patch=1
fi

readarray -t arr -d "\n" < $config_file

workspace_dir="${arr[0]}"
sandbox_dir="${arr[1]}"
checker_dir="${arr[2]}"
compile_args="${arr[3]}"

mkdir $sandbox_dir

array_size="${#arr[@]}"

ptr=4

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
		printf "Running on task $tptr:\n"
		file_name=${file_pattern/\{\}/$tptr}
		cp $workspace_dir/$task_name/$file_name.in $task_name.in
		cp $workspace_dir/$task_name/$file_name.ans $task_name.ans
		proc_time=$((time timeout $time_limit $sandbox_dir/std) 2>&1)
		result=$?
		if((result == 124))
		then
			printf "Time limit exceeded.\n"
			tptr=$(expr $tptr + 1)
			continue
		fi
		printf "Program exited with return value %d in %.3f seconds.\n" $result $proc_time
		$sandbox_dir/checker $sandbox_dir/$task_name.in $sandbox_dir/$task_name.out $sandbox_dir/$task_name.ans
		tptr=$(expr $tptr + 1)
		if ((debug_patch == 1))
		then
			read
		fi
	done
	rm $sandbox_dir/$task_name.in $sandbox_dir/$task_name.out $sandbox_dir/$task_name.ans $sandbox_dir/std $sandbox_dir/checker
	ptr=$(expr $ptr + 1)
done
rmdir $sandbox_dir
# /home/tyoi/yse/oiclass/67431ae9752b8de081989ccf /home/tyoi/yse/oiclass/67431ae9752b8de081989ccf/sandbox