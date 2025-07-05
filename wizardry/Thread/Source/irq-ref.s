 	ldr r2, [r3]
 	ldrh r1, [r3, #OFFSET_REG_IME - 0x200]
 	mrs r0, spsr
	push {r0-r3,lr}

 	mov r12, #0
	strh r12, [r3, #OFFSET_REG_IME - 0x200]
	and r1, r2, r2, lsr #16
	mov r0, #0
	ands r12, r1, #INTR_FLAG_VCOUNT
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	mov r12, 0x1
	strh r12, [r3, #OFFSET_REG_IME - 0x200]
	ands r12, r1, #INTR_FLAG_SERIAL
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_TIMER3
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_HBLANK
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_VBLANK
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_TIMER0
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_TIMER1
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_TIMER2
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_DMA0
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_DMA1
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_DMA2
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_DMA3
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_KEYPAD
 	bne IntrMain_FoundIntr
	add r0, r0, 0x4
	ands r12, r1, #INTR_FLAG_GAMEPAK
	strbne r12, [r3, #REG_SOUNDCNT_X - REG_IE]
 	bne . @ spin
 IntrMain_FoundIntr:
	strh r12, [r3, #OFFSET_REG_IF - 0x200]
	bic r2, r2, r12
 	// TODO: fix me if wireless adapter will be enabled
 	// gSTWIStatus not initialized because rfu_initializeAPI expects gf_rfu_REQ_api
 	// to be in iwram
 	// but that's a waste of iwram space
	//ldr r12, =gSTWIStatus
	//ldr r12, [r12]
	//ldrb r12, [r12, 0xA]
 	//mov r1, 0x8
	//lsl r12, r1, r12

	// r2 = all remaining allowed interrupts (REG_IE minus the interrupt we're handling right now)
	// (gamepak | serial | timer3 | vcount | hblank) & (remainingAllowedInterrupts)
	mov r12, #INTR_FLAG_GAMEPAK
	orr r12, r12, #INTR_FLAG_SERIAL | INTR_FLAG_TIMER3 | INTR_FLAG_VCOUNT | INTR_FLAG_HBLANK
	and r2, r2, r12
	strh r2, [r3, #OFFSET_REG_IE - 0x200]

	ldr r1, =gIntrTableAndThreadInfo
	// check if we need to suspend the sub thread
	// in sub thread must be 0x10, since that's the offset
	// that vblank uses to gIntrTableAndThreadInfo.intrTable
	// otherwise, it is 0xff so it doesn't conflict with other intr table offsets
	ldrb r2, [r1, #oThreadInfo_SubThreadRunning]
	cmp r2, r0
	// if we need to suspend the thread, save the irq stack
	// we need to reference this so we can fetch the registers saved
	// when the interrupt was triggered
	// these sub-thread registers will be saved for when it is called again
	// +#20 is to skip over r0-r3, lr pushed earlier
	addeq r12, sp, #20
 	mrs r3, cpsr
 	bic r3, r3, #PSR_I_BIT | PSR_F_BIT | PSR_MODE_MASK
 	orr r3, r3, #PSR_SYS_MODE
 	msr cpsr_cf, r3

	// read intr function ahead of time
	// so that we can clobber r0
	ldr r3, [r1, r0]
	// again, check if we need to suspend the subthread
	cmp r2, r0
	bne IntrMain_NoSubThread
	// switch to main thread stack if we're in a vblank interrupt
	// only other relevant interrupt that might use too much stack is hblank
	// but it probably doesn't

	// save the sub-thread irq lr
	// which is the address where the thread needs to resume
	// we have to push this first as due to register issues
	// we resume the thread by popping into pc
	ldr r0, [r12, #0x14]

	// manually set thumb bit on lr
	// irq will always set lr to be arm mode
	// which breaks when resuming the thread
	// where spsr was stored
	ldr r2, [r12, #-0x14]
	// shift into carry
	lsr r2, r2, #(PSR_T_BIT_POS + 1)
	// set thumb bit if carry was set
	orrcs r0, r0, #1

	// save to the stack
	push {r0}
	// save the sub thread general registers, and sys mode lr
	push {r4-r11,lr}

	// read the sub-thread irq saved regs
	// we're reading what r0-r3,r12 are
	// of where the irq saved regs are stored
	// but we have to use different scratch registers
	// so that we save r0 so we can read the intr function later
	ldmia r12, {r0,r2,r4,r5,r6}

	// save the sub-thread irq saved regs (except lr)
	push {r0,r2,r4,r5,r6}

	// main thread was restored, so mark in sub thread as false
	mov r0, #0xff
	strb r0, [r1, #oThreadInfo_SubThreadRunning]

	// save the sub-thread stack pointer
	str sp, [r1, #oThreadInfo_SubThreadStackPtr]

	// and load the main thread stack pointer
	ldr sp, [r1, #oThreadInfo_MainThreadStackPtr]
	// this pops off the main thread registers, because the sp we just loaded
	// had previously pushed the main thread registers before

	// restore the main thread irq saved registers (except lr)
	pop {r0,r2,r4,r5,r6,lr}
	// restore the main thread irq lr
	// and store them to where they're saved on the stack
	stmia r12, {r0,r2,r4,r5,r6,lr}

	// restore the main thread general registers
	pop {r4-r11,lr}

IntrMain_NoSubThread:
	push {lr}
 	adr lr, IntrMain_RetAddr
	bx r3
 IntrMain_RetAddr:
	pop {lr}
 	mrs r3, cpsr
 	bic r3, r3, #PSR_I_BIT | PSR_F_BIT | PSR_MODE_MASK
 	orr r3, r3, #PSR_I_BIT | PSR_IRQ_MODE
 	msr cpsr_cf, r3
	pop {r0-r3,lr}
 	strh r2, [r3, #OFFSET_REG_IE - 0x200]
 	strh r1, [r3, #OFFSET_REG_IME - 0x200]
 	msr spsr_cf, r0
 	bx lr
