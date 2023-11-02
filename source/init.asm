            
#ifdef MCHIP 
#define cold_boot  07000h
#define warm_boot  07003h
#else 
#define cold_boot  08000h
#define warm_boot  08003h
#endif

            
            org     0000h
            
; ***************************************************************
; ***       Define Reset Vectors in ROM                       ***
; ***************************************************************
          
            lbr     cold_boot
            lbr     warm_boot
