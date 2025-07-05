#pragma once

#include "gbafe.h"

typedef void (*thread_task_func)(void);

enum {
	SUBTHREAD_NONE = 0,
	SUBTHREAD_PENDING,
	SUBTHREAD_ACTIVE
};


struct ThreadInfo {
	u8 sub_thread_running;
	u8 sub_thread_state;

	u8 _pad_[2];

	void *main_thread_sp;
	void *sub_thread_sp;

	thread_task_func func;
};

extern struct ThreadInfo gThreadInfo;

void CreateSubThread(thread_task_func func);

void start_sub_thread(void);
void resume_sub_thread(void);
