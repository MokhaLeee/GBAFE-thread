	.INCLUDE "macros.inc"
	.INCLUDE "gba.inc"
	.INCLUDE "kthread.inc"
	.SYNTAX UNIFIED

	.section .text

THUMB_FUNC_START start_sub_thread
start_sub_thread:
	bx pc
	.arm
	.align 2, 0
start_sub_thread_arm:
	push {r4-r11, lr}
	add lr, lr, #4
	push {r0-r3, r12, lr}

	ldr r0, =gThreadInfo

	# save stack pointer
	str sp, [r0, #oThreadInfo_main_thread_sp]
	ldr sp, =SUB_THREAD_STACK_BASE

	# Add a mark for IRQ handler
	mov r1, #DEFAULT_SUBTHREAD_RUNNING_MODE
	strb r1, [r0, #oThreadInfo_sub_thread_running]

	# jump to thread
	ldr r0, [r0, oThreadInfo_func]
	adr lr, start_sub_thread_return
	bx r0

start_sub_thread_return:
	ldr r0, =gThreadInfo
	ldr sp, [r0, #oThreadInfo_main_thread_sp]
	pop {r0-r3, r12, lr}
	pop {r4-r11, lr}
	bx lr

THUMB_FUNC_START resume_sub_thread
resume_sub_thread:
	bx pc
	.arm
	.align 2, 0
resume_sub_thread_arm:
	push {r4-r11, lr}
	add lr, lr, #4
	push {r0-r3, r12, lr}

	ldr r0, =gThreadInfo
	str sp, [r0, #oThreadInfo_main_thread_sp]
	ldr sp, [r0, #oThreadInfo_sub_thread_sp]

	mov r1, #DEFAULT_SUBTHREAD_RUNNING_MODE
	strb r1, [r0, #oThreadInfo_sub_thread_running]

	pop {r0-r3, r12}

	# 0x04: kernel_vblank_isr
	# 0x10: IrqMain
	# 0x14: bios irq_vector
	ldr lr, [sp, #0x24]
	sub lr, lr, #4
	str lr, [sp, #0x24]

	# shift thumb bit into carry flag
	lsr lr, lr, #1

	# restore sub-thread general registers, EXCEPT r4
	pop {r5-r11,lr}

	# carry clear = arm mode = can just return away
	popcc {r4, pc}

	// need to switch to thumb mode
	adr r4, resume_sub_thread_thumb+1
	bx r4

	.thumb
resume_sub_thread_thumb:
	pop {r4, pc}
