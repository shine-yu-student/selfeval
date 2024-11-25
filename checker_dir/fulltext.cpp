#include <cctype>
#include <string>
#include <testlib.h>

std::string str1, str2;
int idx;

void proc(std::string &x)
{
	while (x.size() and std::isspace(x.back()))
		x.pop_back();
}

int main(int argc, char **argv)
{
	registerTestlibCmd(argc, argv);
	do
	{
		str1 = ouf.readLine(), str2 = ans.readLine();
		proc(str1), proc(str2);
		idx++;
		if (str1 == str2)
			continue;
		quitf(_wa, "on Line %d.", idx);
	} while (!ouf.eof() and !ans.eof());
	quitf(_ok, "Accepted.");
}
