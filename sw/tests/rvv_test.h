#ifndef __RVV_RVV_TEST_H__
#define __RVV_RVV_TEST_H__

// Helper test macros
#define RVV_TEST_INIT(vl, avl)            vl = reset_v_state ( avl ); exception = 0;
#define RVV_TEST_CLEANUP()                RVV_TEST_ASSERT_EXCEPTION(0); exception = 0;
// BUG: Can't return a non-zero value from here...
// #define RVV_TEST_ASSERT( expression ) if ( !expression ) { return -1; }
// Quick workaround:
#define RVV_TEST_ASSERT( expression )     if ( !(expression) ) { goto RVV_TEST_error; }
#define RVV_TEST_ASSERT_EXCEPTION( val )  RVV_TEST_ASSERT ( exception == (uint64_t)(val) );
#define RVV_TEST_CLEAN_EXCEPTION()        exception = 0;
#define RVV_TEST_PASSED()                 asm volatile ( "li %0, %1" : "=r" (magic_out) : "i"(RVV_TEST_MAGIC));
#define RVV_TEST_FAILED()                 asm volatile ( "nop;nop;nop;nop;" );

#define VLMAX (1024 * ARA_NR_LANES)
#ifndef RVV_TEST_AVL
  #define RVV_TEST_AVL(EEW) (VLMAX / (EEW))
#endif

// Helper test variables
typedef uint64_t vcsr_dump_t [5];
uint64_t exception;
uint64_t magic_out;

void enable_rvv() {
  // Enalbe RVV by seting MSTATUS.VS
  asm volatile (" li      t0, %0       " :: "i"(MSTATUS_VS));
  asm volatile (" csrs    mstatus, t0" );
}

uint64_t reset_v_state ( uint64_t avl ) {
    uint64_t vl_local = 0;

	asm volatile (
    "fence                                \n\t"
	  "vsetvli  %0    , %1, e64, m8, ta, ma \n\t"
	  "csrw	    vstart, 0                   \n\t"
	  "csrw	    vcsr  , 0                   \n\t"
    "fence                                \n\t"
	: "=r" (vl_local)  : "r" (avl) :
  );

    return vl_local;
}

void vcsr_dump ( vcsr_dump_t vcsr_state ) {
	asm volatile (
		"csrr  %0, vstart \n\t"
		"csrr  %1, vtype  \n\t"
		"csrr  %2, vl     \n\t"
		"csrr  %3, vcsr   \n\t"
		"csrr  %4, vlenb  \n\t"
		: "=r" (vcsr_state[0]),
		  "=r" (vcsr_state[1]),
		  "=r" (vcsr_state[2]),
		  "=r" (vcsr_state[3]),
		  "=r" (vcsr_state[4])
  );
}

// Override default weak trap vector
void trap_vector () {
    exception = 1;
    asm volatile (
        "nop;"
        "csrr	t6, mepc;" 
        "addi	t6, t6, 4; # PC = PC + 4, valid only for non-compressed trapping instructions\n"
        "csrw	mepc, t6;"
        "nop;"
    );
}

#endif // __RVV_RVV_TEST_H__
