#include <algorithm>
#include <cctype>
#include <cstdlib>
#include <testlib.h>

using ld = long double;
ld x, y;
int idx;
const ld eps = 1e-6;

int main(int argc, char **argv)
{
	registerTestlibCmd(argc, argv);
	x = ouf.readDouble(), y = ans.readDouble();
	if (abs(x - y) / std::max((ld)1, abs(y)) > eps)
		quitf(_wa, "on Line %d, read %.6Lf, expect %.6Lf, error %.6Lf", idx, x, y,
			  abs(x - y) / std::max((ld)1, abs(y)));
	quitf(_ok, "Accepted.");
}
