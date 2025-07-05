#include "gbafe.h"
#include "kthread.h"

void kthread_test(void)
{
	while (1)
		;
}

// lynjump
void InitUnits(void)
{
	int i;

	CreateSubThread(kthread_test);

	for (i = 0; i < 0x100; i++) {
		struct Unit *unit = GetUnit(i);

		if (unit) {
			ClearUnit(unit);
			unit->index = i;
		}
	}
}
