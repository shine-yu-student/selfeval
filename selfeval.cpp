#include <chrono>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <format>
#include <fstream>
#include <future>
#include <iostream>
#include <string>

using namespace std;
const int N = 1e5 + 10;
string task, checker, filename, t_filename, pcn, workdir, sandbox, ckd;
int num, ps, idx, ms, ret, tms;

void ignore_sigterm(int signal)
{
}

void run()
{
	if (task[0] == task[1] and task[0] == '/')
		return;
	idx++;
	cerr << format("Judging task {}:\n", task);
	fprintf(stderr, "Compiling checker: ");
	if (pcn != checker)
		system(format("g++ {}\\{}.cpp -std=c++20 -O2 -o {}\\checker --static", ckd, checker, sandbox).c_str());
	fprintf(stderr, pcn != checker ? "completed.\n" : "skipped.\n");
	pcn = checker;
	fprintf(stderr, "Compiling std: ");
	system(format("g++ {1}\\{0}\\{0}.cpp -std=c++14 -O2 -o {2}\\std --static", task, workdir, sandbox).c_str());
	fprintf(stderr, "completed.\n");
	ps = filename.find("{}");
	// system("pause");
	for (int i = 1; i <= num; i++)
	{
		fprintf(stderr, "\nRunning on task %d:\n", i);
		t_filename = filename.substr(0, ps) + to_string(i) + filename.substr(ps + 2);
		system(format("copy {2}\\{0}\\{1}.in {3}\\{0}.in", task, t_filename, workdir, sandbox).c_str());
		system(format("copy {2}\\{0}\\{1}.in {0}.in", task, t_filename, workdir).c_str());
		// system("pause");
		auto start_time = chrono::high_resolution_clock::now();
		future<int> ft = async(system, format("{}\\std.exe", sandbox).c_str());
		future_status ftt = ft.wait_for(chrono::milliseconds(ms));
		if (ftt != future_status::ready)
		{
			fprintf(stderr, "Time limit exceeded.\n");
			system("taskkill /im std.exe /t /f");
			system("taskkill /im cmd.exe /t /f");
			continue;
		}
		ret = ft.get();
		// system("pause");
		auto track_time = chrono::high_resolution_clock::now();
		fprintf(stderr, "Program exited with return value %d in %.3lf milliseconds\n", ret,
				(track_time - start_time).count() / 1e6);
		if (ret)
			continue;
		system(format("copy {}.out {}", task, sandbox).c_str());
		system(format("{3}\\checker.exe {3}\\{0}.in {3}\\{0}.out {2}\\{0}\\{1}.ans", task, t_filename, workdir, sandbox)
				   .c_str());
	}
	// system(format("del {}\\checker.exe", task).c_str());
	system(format("del {}\\std.exe", sandbox).c_str());
	system(format("del {}\\{}.in", sandbox, task).c_str());
	system(format("del {}\\{}.out", sandbox, task).c_str());
	system(format("del {}.in", task).c_str());
	system(format("del {}.out", task).c_str());
	fprintf(stderr, "\n");
}
int main(int argc, char **argv)
{
	typedef void (*SignalHP)(int);
	SignalHP prvhd;
	prvhd = signal(SIGTERM, ignore_sigterm);
	prvhd = signal(SIGINT, ignore_sigterm);
	if (argc == 1)
	{
		fprintf(stderr, "Error: please provide root directory\n");
		return 0;
	}
	if (argc == 2)
	{
		fprintf(stderr, "Error: please provide sandbox directory\n");
		return 0;
	}
	if (argc == 3)
	{
		fprintf(stderr, "Error: please provide checker directory\n");
		return 0;
	}
	workdir = argv[1];
	sandbox = argv[2];
	ckd = argv[3];
	system(format("mkdir {}", sandbox).c_str());
	ifstream fin(format("{}\\config.txt", workdir));
	while (fin >> task >> checker >> filename >> num >> ms)
	{
		run();
	}
	system(format("del {}\\checker.exe", sandbox).c_str());
	system(format("rmdir {}", sandbox).c_str());
}