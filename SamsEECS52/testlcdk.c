#include "mp3defs.h"

void disp()
{
	while(!key_available()) {;}
	display_time(6711);
	display_title("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
	display_status(3);
	display_artist("37-Fort Minor - where'd you go (featuring holly brook and jonah matranga)");
}