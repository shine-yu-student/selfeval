#!/bin/bash

config_file=$1
tfm=$TIMEFORMAT
TIMEFORMAT='%3R'
debug_patch=0

if (($# < 1))
then
	echo "Error: missing workspace path"
	exit 1
fi

if (($# > 1))
then
	if (($2 == "-d"))
	then
		debug_patch=1
	fi
fi

readarray -t arr -d "\n" < $config_file

workspace_dir="${arr[0]}"
sandbox_dir="${arr[1]}"
checker_dir="${arr[2]}"
compile_args_std="${arr[3]}"
compile_args_checker="${arr[4]}"
previous_checker="dummy"

mkdir $sandbox_dir

array_size="${#arr[@]}"

ptr=5

while (($ptr<array_size))
do
	readarray -d " " -t subarr < <(echo -e "${arr[$ptr]}")
	task_name="${subarr[0]}"
	if [ "$task_name" == "//" ]
	then
		ptr=$(expr $ptr + 1)
		continue
	fi
	checker_name="${subarr[1]}"
	file_pattern="${subarr[2]}"
	task_number="${subarr[3]}"
	time_limit=$(echo "${subarr[4]}*0.001" | bc)"s"
	echo "Judging task $task_name:"
	printf "Compiling checker: "
	if [ "$previous_checker" != "$checker_name" ]
	then
		g++ $checker_dir/$checker_name.cpp -o $sandbox_dir/checker $compile_args_checker
		result=$?
		if ((result > 0))
		then
			printf "failed returning %d.\n" $result
			ptr=$(expr $ptr + 1)
			continue
		fi
		printf "done.\n"
		previous_checker=$checker_name
	else
		printf "skipped.\n"
	fi
	printf "Compiling std: "
	g++ $workspace_dir/$task_name/$task_name.cpp -o $sandbox_dir/std $compile_args_std
	result=$?
	if ((result > 0))
	then
		printf "failed returning %d.\n" $result
		ptr=$(expr $ptr + 1)
		continue
	fi
	printf "done.\n"
	cd $sandbox_dir
	tptr=1
	while [ $tptr -le $task_number ]
	do
		if ((debug_patch == 0))
		then
			printf "\nRunning on task $tptr:\n"
		else
			printf "Running on task $tptr:\n"
		fi
		file_name=${file_pattern/\{\}/$tptr}
		cp $workspace_dir/$task_name/$file_name.in $task_name.in
		cp $workspace_dir/$task_name/$file_name.ans $task_name.ans
		proc_time=$((time /usr/bin/timeout $time_limit ./std) 2>&1)
		result=$?
		if ((result == 124))
		then
			printf "Time limit exceeded.\n"
			tptr=$(expr $tptr + 1)
			continue
		fi
		printf "Program exited with return value %d in %.3f seconds.\n" $result $proc_time
		./checker ./$task_name.in ./$task_name.out ./$task_name.ans
		tptr=$(expr $tptr + 1)
		if ((debug_patch == 1))
		then
			read
		fi
	done
	rm ./$task_name.in ./$task_name.out ./$task_name.ans ./std
	ptr=$(expr $ptr + 1)
done
rm ./checker
rmdir $sandbox_dir
