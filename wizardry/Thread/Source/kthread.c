#include "gbafe.h"
#include "kthread.h"

void CreateSubThread(thread_task_func func)
{
    gThreadInfo.func = func;
    gThreadInfo.sub_thread_state = SUBTHREAD_PENDING;
}
