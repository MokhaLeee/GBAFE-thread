#include "gbafe.h"
#include "kthread.h"

#define IRQ_COUNT 14
extern void *gIRQHandlers[IRQ_COUNT];
extern u32 IntrMain_Buffer[0x200];
void DummyIRQRoutine(void);

// lynjump
void StoreIRQToIRAM(void)
{
	int i;

	for(i = 0; i < IRQ_COUNT; i++)
		gIRQHandlers[i] = DummyIRQRoutine;

	CpuFastCopy(IrqMain, IntrMain_Buffer, sizeof IntrMain_Buffer);
	INTR_VECTOR = IntrMain_Buffer;

	// CHAX
	gThreadInfo.sub_thread_running = 0xFF;
	gThreadInfo.sub_thread_state = SUBTHREAD_NONE;
}
