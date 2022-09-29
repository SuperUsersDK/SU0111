#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
	FILE *fd;
	for (int i=1; i<argc; i++) {
		FILE *fd=fopen(argv[i], "w");
		if (fd == NULL) {
			fprintf(stderr, "fopen failed for %s\n", argv[i]);
			return EXIT_FAILURE;
		}
		fprintf(fd, "Some random output in %s\n", argv[i]);
		fclose(fd);
	}
	return EXIT_SUCCESS;
}
