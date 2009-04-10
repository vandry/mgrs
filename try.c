#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "mgrslib/mgrs.h"

int
main(int argc, char **argv)
{
double lat, lon;
long result;
char *p;
char buf[32];

	if (argc == 2) {
		result = Convert_MGRS_To_Geodetic(
			argv[1],
			&lat, &lon
		);
		fprintf(stdout, "result=%ld %g %g\n", result,
			lat / M_PI * 180.0,
			lon / M_PI * 180.0
		);
	} else if (argc == 3) {
		lat = strtod(argv[1], &p) / 180.0 * M_PI;
		if ((argv[1][0] == 0) || ((*p) != 0)) {
			fprintf(stderr, "bad lat\n");
			return 1;
		}
		if ((lat < -M_PI_2) || (lat > M_PI_2)) {
			fprintf(stderr, "your latitude is not exactly on Earth\n");
			return 1;
		}
		lon = strtod(argv[2], &p) / 180.0 * M_PI;
		if ((argv[2][0] == 0) || ((*p) != 0)) {
			fprintf(stderr, "bad lon\n");
			return 1;
		}
		if ((lon < -M_PI) || (lon > M_PI)) {
			fprintf(stderr, "your longitude is freaky\n");
			return 1;
		}
		result = Convert_Geodetic_To_MGRS(
			lat, lon,
			5,
			&(buf[0])
		);
		fprintf(stdout, "%s\n", buf);
	} else {
		fprintf(stderr, "holy crap, you did not call the tool correctly\n");
		return 1;
	}
	return 0;
}
