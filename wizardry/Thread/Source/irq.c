#include "gbafe.h"
#include <string.h>
#include "kthread.h"

#define IRQ_COUNT 14
extern void *gIRQHandlers[IRQ_COUNT];
extern u32 IntrMain_Buffer[0x200];
void DummyIRQRoutine(void);

extern void IrqMain_CHAX(void);
extern void kthread_test(void);

// lynjump
void StoreIRQToIRAM(void)
{
	int i;

	for(i = 0; i < IRQ_COUNT; i++)
		gIRQHandlers[i] = DummyIRQRoutine;

#if 0
	CpuFastCopy(IrqMain, IntrMain_Buffer, sizeof IntrMain_Buffer);
#else
	CpuFastCopy(IrqMain_CHAX, IntrMain_Buffer, sizeof IntrMain_Buffer);
#endif

	INTR_VECTOR = IntrMain_Buffer;

	// CHAX
	gThreadInfo.sub_thread_running = INVALID_SUBTHREAD_RUNNING_MODE;
	gThreadInfo.sub_thread_state = SUBTHREAD_NONE;

	// test
	CreateSubThread(kthread_test);
}
