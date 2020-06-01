# _**MIPS architecture project**_  
The aim of this project is to write a MIPS assembly app that draws polynomials up to 3rd degree on bitmap without using floating point registers.  
More in .asm file description:  
```
assumptions: 	x belongs < -4 , 4 )
		        y belongs < -4 , 4 )
		        polynomial coefs belongs < -8 , 8 )
		        3 bits for an argument, 4 for coef, so (in worst case)
                it gives 4 + 3 + 3 + 3 + 1 for overflow = 14 bits
 		        for an integer part of number, and 18 for fractional
                part, to avoid overflow in further processing
```
