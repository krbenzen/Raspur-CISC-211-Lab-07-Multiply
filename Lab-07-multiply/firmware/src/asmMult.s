/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Benzen Raspur"  

.align   /* realign so that next mem allocations are on word boundaries */
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    /*Initialize all the variables first*/
    ldr  r4, =a_Multiplicand
    movs r5, #0
    str  r5, [r4]
    ldr  r4, =b_Multiplier
    str  r5, [r4]
    ldr  r4, =rng_Error
    str  r5, [r4]
    ldr  r4, =a_Sign
    str  r5, [r4]
    ldr  r4, =b_Sign
    str  r5, [r4]
    ldr  r4, =prod_Is_Neg
    str  r5, [r4]
    ldr  r4, =a_Abs
    str  r5, [r4]
    ldr  r4, =b_Abs
    str  r5, [r4]
    ldr  r4, =init_Product
    str  r5, [r4]
    ldr  r4, =final_Product
    str  r5, [r4]

    /*Copy input from r0 and r1 into memory*/
    ldr  r4, =a_Multiplicand
    str  r0, [r4]
    ldr  r4, =b_Multiplier
    str  r1, [r4]

/*Check if r0 is in this range we est earlier -32768 to 32767*/
    ldr  r4, =0x00007FFF  /*limit 32767*/
    cmp  r0, r4
    ble  check_r0_low   
out_of_range:
    ldr  r4, =rng_Error
    movs r5, #1
    str  r5, [r4]        
    movs r0, #0          
    b    done

check_r0_low:
    /*check r0 =>= -32768*/
    ldr  r4, =0xFFFF8000  
    cmp  r0, r4
    bge  check_r1_range  

    /*else out of range*/
    b    out_of_range

check_r1_range:
    /*Check if r1 is in this range we est earlier -32768 to 32767*/
    ldr  r4, =0x00007FFF
    cmp  r1, r4
    ble  check_r1_low
    b    out_of_range

check_r1_low:
    ldr  r4, =0xFFFF8000
    cmp  r1, r4
    bge  store_sign_bits
    b    out_of_range

store_sign_bits:
    /*if r0 < 0, else 0 . if r1 < 0, else 0*/
    movs r5, #0
    cmp  r0, #0
    bge  store_a_sign
    movs r5, #1
store_a_sign:
    ldr  r4, =a_Sign
    str  r5, [r4]

    movs r5, #0
    cmp  r1, #0
    bge  store_b_sign
    movs r5, #1
store_b_sign:
    ldr  r4, =b_Sign
    str  r5, [r4]

    mov  r2, r0      /*hold a in 2*/
    cmp  r2, #0
    bge  store_a_abs
    rsbs r2, r2, #0 
store_a_abs:
    ldr  r4, =a_Abs
    str  r2, [r4]

    mov  r3, r1      /*hold b in 3*/
    cmp  r3, #0
    bge  store_b_abs
    rsbs r3, r3, #0  
store_b_abs:
    ldr  r4, =b_Abs
    str  r3, [r4]

    /*Determine if product should be neg
       If either is zero, final product is 0, not neg*/
    cmp  r2, #0
    beq  product_sign_zero
    cmp  r3, #0
    beq  product_sign_zero
    ldr  r4, =a_Sign
    ldr  r5, [r4]
    ldr  r4, =b_Sign
    ldr  r4, [r4]
    eors r5, r5, r4         
    ldr  r4, =prod_Is_Neg
    str  r5, [r4]
    b    do_mult

product_sign_zero:
    /*Product is zero then the prod_Is_Neg = 0 */
   ldr  r4, =prod_Is_Neg
    movs r5, #0
    str  r5, [r4]

do_mult:
    /*Multiply a_Abs r2 and b_Abs r3*/
    movs r4, #0    /*r4 will hold the product*/
    movs r5, #16   /*loop counter*/

mult_loop:
    tst  r3, #1    /*add a_Abs*/
    beq  no_add
    adds r4, r4, r2
    
no_add:
    lsrs r3, r3, #1   /*shift right*/
    lsls r2, r2, #1   /*shift left*/
    subs r5, r5, #1
    bne  mult_loop
    /*Store positive product into init_Product*/
    ldr  r6, =init_Product
    str  r4, [r6]
    /*If prod_Is_Neg = 1 negate it*/
    ldr  r6, =prod_Is_Neg
    ldr  r6, [r6]
    cmp  r6, #0
    beq  store_final_product
    /* Make product negative */
    rsbs r4, r4, #0

store_final_product:
    /*Store final product*/
    ldr  r6, =final_Product
    str  r4, [r6]
    /*Copy product to r0*/
    mov  r0, r4
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




