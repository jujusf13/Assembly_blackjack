;CS 274
;
; IPA 5

;print string instructions
;MOV AH, 0x13            ; move BIOS interrupt number in AH
;MOV CX, 11              ; move length of string in cx
;MOV BX, 0               ; mov 0 to bx, so we can move it to es
;MOV ES, BX              ; move segment start of string to es, 0
;MOV BP, OFFSET hello    ; move start offset of string in bp
;MOV DL, 0               ; start writing from col 0
;int 0x10                ; BIOS inter

;rng variables
x0: db 0xAD      ;X0 (173)       ;Xk starts at (173), then Xk+1
xk: db 0xAD
a: db 0x03       ;A value a, odd and ideally co-prime to (3)
m: db 0xFB       ;A large prime m that fits in a register of the required size (251)
n: db 0x00 ;     ;random num n, for card indexing

;game configs
num_decks: db 0x01      ;initial set at 1
num_cards: db 0x34      ;initial set at 52

;score variables
player_score: db 0x00 ; Will be used for player score
cpu_score: db 0x00

;win variables
player_wins: db 0x00
cpu_wins: db 0x00

;bet variables
player_bets: db 0x00  db 0x00  ;total bet amount player has (takes 2 bytes in memory)
cpu_bets: db 0x00  db 0x00      ;total bet amount cpu has   (takes 2 bytes in memory)

;bet variables
total_player_bets: db 0x00  db 0x00  ;total bet amount player has (takes 2 bytes in memory)
total_cpu_bets: db 0x00  db 0x00      ;total bet amount cpu has   (takes 2 bytes in memory)

round_player_bet: db 0x00  db 0x00        ;round bet player has made
round_cpu_bet:  db 0x00 db 0x00        ;round bet cpu has made

betting_pool: db 0x00 db 0x00           ;round_player_bet + round_cpu_bet (winner gets the sum)

;printable strings
deck: db "23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA23456789TJQKA"
db 0x00
total_bet_question: db "How much betting money would you like? Must be a number between $10-$1000"
db 0x00
round_bet_question: db "How much would you like to bet? Make sure its between your current total bets "
db 0x00
bet_question: db "Which mode would you like to play against: Conservative, Normal, or Aggressive?"
db 0x00
risk_question: db "Determine the risk level you would like to play against for each action: Keep hand, Add card, Forfeit card. Must add to 100."
db 0x00
difficulty_question: db "Select difficulty mode: Easy, Normal, or Hard"
db 0x00
deck_question: db "How many decks of cards? 1-3"

db 0x00
of: db "of"
db 0x00
c: db "Clubs"
db 0x00
d: db "Diamonds"
db 0x00
s: db "Spades"
db 0x00
h: db "Hearts"
db 0x00
player_win: db "You win!"
db 0x00
game_tie: db "It's a tie!"
db 0x00
cpu_win: db "CPU wins!"
db 0x00

player_choice: db "hit, stand, or forfeit (type h, s, or f)"
db 0x00
ace_value: db "You have an ace. Keep your score as it is or add 10 to it? (y to add, n to stay)"
db 0x00

; misc
p_to_d_cards: db 0x02 ; 2 cards to deal, subtract from this
c_to_d_cards: db 0x02 ; 2 cards to deal to cpu




; Buffers

base:
    db 0x00
; To make a buffer users will write to
; INT 0x10h need an initial 'guess' of how
; many characters will appear
;N:  db 0x0a
buffer:    ; value of intial bet amount
    
    db 0x05    ; Actual value read after INT
    db 0x05
    db [0xff, 0x05] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff

buffer2:    ;value for player choice (h, s, f)
    
    db 0x03    ; Actual value read after INT
    db 0x03
    db [0xff, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff
    
buffer3:    ;value for number of decks
    
    db 0x03    ; Actual value read after INT
    db 0x03
    db [0xff, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff
    
buffer4:    ;value for computer betting mode (C, N, A)
    
    db 0x03    ; Actual value read after INT
    db 0x03
    db [0xff, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff
    
buffer5:    ;value for computer difficulty (E, N, H)
    
    db 0x03    ; Actual value read after INT
    db 0x03
    db [0xff, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff

buffer6:    ;value for amount of round bet made
    
    db 0x03    ; Actual value read after INT
    db 0x03
    db [0xff, 0x03] ; Buffer of the right size  
                    ; First value: filler
                    ; Second value: number of bytes
    db 0xff

def calc_num_cards{
    mov ax,0    ;reset ax
   
    mov bp, offset num_cards    ;get index of num cards in memory
    
    
    mov ax, 0x34        ;move '52' into ax
    mul byte [offset num_decks]        ;multipy 52 by num of decks
    mov byte [bp],al    ;update num cards in memory
    
    mov ax,0    ;reset ax
}

def rng{
    
    call calc_num_cards
    
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
    
    mov al, byte [offset xk]    ;X subscript k
    mov bl, byte [offset a]    ;coprime a
    mov cl, byte [offset m]    ;prime number m
    mov dx, 0
   
    
    ;obtain Xk+1 by Xk+1 = a * Xk mod m
    mul bx              ;multiply a by X subscript k
    div cx              ;then mod m = X subscript k+1
    mov ax,dx           ;this is Xk+1
    mov byte [offset xk],al     ;store k+1 into mem[0]
    
    mov dx,0            ;reset dx 
    mov byte [offset xk],al     ;store k+1 into mem[0]
    mov cl,byte[offset num_cards]
    ;obtain index by n = Xk+1 mod num of cards
    div cx            ;Xk+1 mod num of cards
    mov byte [offset n], dl    ;store n into mem[4]
    
    ;reset all registers
    mov ax,0
    mov bx,0
    mov cx,0
    mov dx,0
    
    ret
}

    
def check_suit_cpu{ ; checks what suit the card picked is
    ; 4th byte (5th index)
    cmp byte[4],0x0C    ;check if n is below 12
    jbe _print_h_cpu        ;if so,print hearts
    cmp byte[4],0x19    ;check if n is below 25
    jbe _print_c_cpu        ;if so,print clubs
    cmp byte[4],0x26    ;check if n is below 38
    jbe _print_s_cpu       ;if so, print spades
    cmp byte[4], 0x33   ;check if n is below 51
    jbe _print_d_cpu        ;if so,print diamnonds
    
    ret
}

_print_h_cpu:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 6             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET h   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num_cpu

_print_c_cpu:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET c   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num_cpu
    
_print_s_cpu:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET s   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num_cpu
    
_print_d_cpu:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX,  8           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET d   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num_cpu

def display_card_cpu{ ; player hit method
    call rng
    ; randomly displays value of card
    MOV bp, OFFSET deck
    mov al, byte [4]
    mov si, ax; rng card value
    add bp, si ; the index of the string we want to print
    mov ah, 0x02 ; BIOS function for printing char in ah, 
    mov dl, byte [bp]
    int 0x21    ;print card value
    
    ;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 2           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET of   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    call check_suit_cpu
    
    ret
}

string_to_num_cpu: ;for player

    MOV bp, OFFSET deck
    ;mov al, byte [4] ;rand number n (index of deck)
    mov al, byte [4]
    mov ah, 0
    mov si, ax 
    add bp, si ; the index of the string we want to print
    mov dl, byte [bp] ; stores character in

    ; add number to player byte[5] which is the 6th index
    ; which is the player score
    ;mov ax, 0 ; move zero into ax
    
    cmp dl, 0x41           ; Compare with ASCII value of 'A'
    je  convert_A_cpu            ; Jump if equal to 'A'
    cmp dl, 0x32           ; Compare with ASCII value of '2'
    je  convert_2_cpu            ; Jump if equal to '2'
    cmp dl, 0x33           ; Compare with ASCII value of '3'
    je  convert_3_cpu            ; Jump if equal to '3'
    cmp dl, 0x34           ; Compare with ASCII value of '4'
    je  convert_4_cpu            ; Jump if equal to '4'
    cmp dl, 0x35           ; Compare with ASCII value of '5'
    je  convert_5_cpu            ; Jump if equal to '5'
    cmp dl, 0x36           ; Compare with ASCII value of '6'
    je  convert_6_cpu            ; Jump if equal to '6'
    cmp dl, 0x37           ; Compare with ASCII value of '7'
    je  convert_7_cpu            ; Jump if equal to '7'
    cmp dl, 0x38           ; Compare with ASCII value of '8'
    je  convert_8_cpu            ; Jump if equal to '8'
    cmp dl, 0x39           ; Compare with ASCII value of '9'
    je  convert_9_cpu            ; Jump if equal to '9'
    cmp dl, 0x54           ; Compare with ASCII value of 'T'
    je  convert_T_cpu            ; Jump if equal to 'T'
    cmp dl, 0x4A           ; Compare with ASCII value of 'J'
    je  convert_J_cpu            ; Jump if equal to 'J'
    cmp dl, 0x51           ; Compare with ASCII value of 'Q'
    je  convert_Q_cpu            ; Jump if equal to 'Q'
    cmp dl, 0x4B           ; Compare with ASCII value of 'K'
    je  convert_K_cpu            ; Jump if equal to 'K'


; CHANGE FROM PLAYER SCORE VALUE TO CPU SCORE VALUE
; AND JUMP TO CPU_CHOICE_METHOD INSTEAD

convert_A_cpu:
    mov al, byte [8]        ; Load current value of byte[8] into al (the cpu score of the round so far)
    add al, 0x1             ; Add the integer value for 'A' (e.g., 11 for Ace)
    mov byte [8], al        ; Store the result back into byte[8]
    mov al, 0
    
    mov al, byte [offset c_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from cpu_left_to_deal
    mov byte [offset c_to_d_cards], al   ; move value back into memory
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth

convert_2_cpu:
    mov al, byte [8]     
    add al, 0x2          
    mov byte [8], al       
    mov al, byte [offset c_to_d_cards]      
    sub al, 0x01                        
    
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
    

convert_3_cpu:
    mov al, byte [8]        
    add al, 0x3             
    mov byte [8], al        
    mov al, byte [offset c_to_d_cards]        
    sub al, 0x01         
    
    mov byte [offset c_to_d_cards], al   
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
    
convert_4_cpu:
    mov al, byte [8]       
    add al, 0x4         
    mov byte [8], al     
    mov al, byte [offset c_to_d_cards]   
    sub al, 0x01                         
    mov byte [offset c_to_d_cards], al 
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
   
convert_5_cpu:
    mov al, byte [8]       
    add al, 0x5       
    mov byte [8], al   
    mov al, byte [offset c_to_d_cards]     
    sub al, 0x01                             
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
   
convert_6_cpu:
    mov al, byte [8]       
    add al, 0x6            
    mov byte [8], al      
    mov al, byte [offset c_to_d_cards]        
    sub al, 0x01                               
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
   
convert_7_cpu:
    mov al, byte [8]      
    add al, 0x7           
    mov byte [8], al       
    mov al, byte [offset c_to_d_cards]      
    sub al, 0x01                          
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset p_to_d_cards], 0
    jbe _cpu_choice_meth
  
convert_8_cpu:
    mov al, byte [8]     
    add al, 0x8          
    mov byte [8], al     
    mov al, byte [offset c_to_d_cards]     
    sub al, 0x01                              
    mov byte [offset c_to_d_cards], al 
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth

convert_9_cpu:
    mov al, byte [8]     
    add al, 0x9       
    mov byte [8], al   
    mov al, byte [offset c_to_d_cards]     
    sub al, 0x01                    
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth

convert_T_cpu:
    mov al, byte [8]      
    add al, 0xA             ; Add the integer value for 'T' (e.g., 10 for Ten)
    mov byte [8], al       
    mov al, byte [offset c_to_d_cards]    
    sub al, 0x01                                
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
    
convert_J_cpu:
    mov al, byte [8]    
    add al, 0xB             ; Add the integer value for 'J' (e.g., 11 for Jack)
    mov byte [8], al       
    mov al, byte [offset c_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset c_to_d_cards], al   ; move value back into memory
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
   
convert_Q_cpu:
    mov al, byte [8]        ; Load current value of byte[7] into al
    add al, 0xC             ; Add the integer value for 'Q' (e.g., 12 for Queen)
    mov byte [8], al        ; Store the result back into byte[7]
    mov al, byte [offset c_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset c_to_d_cards], al   ; move value back into memory
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth
   
convert_K_cpu:
    mov al, byte [8]        ; Load current value of byte[7] into al
    add al, 0xD             ; Add the integer value for 'K' (e.g., 13 for King)
    mov byte [8], al        ; Store the result back into byte[7]
    mov al, byte [offset c_to_d_cards]    
    sub al, 0x01                      
    mov byte [offset c_to_d_cards], al  
    cmp byte [offset c_to_d_cards], 0
    jg _cpu_hit
    cmp byte [offset c_to_d_cards], 0
    jbe _cpu_choice_meth

_cpu_choice_meth:
    mov ax, 1

_cpu_hit:
    mov ax, 1

_cpu_stand:
    mov ax, 1




; CPU specific^^



_win:
    ;print player wins statement
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 9              ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET player_win   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter


_tie:
    ;print tie statement
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 9              ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET game_tie   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter

_lose:
    ;print cpu win statement
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 10              ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET cpu_win    ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter






def check_suit{ ; checks what suit the card picked is
    ; 4th byte (5th index)
    cmp byte[4],0x0C    ;check if n is below 12
    jbe _print_h        ;if so,print hearts
    cmp byte[4],0x19    ;check if n is below 25
    jbe _print_c        ;if so,print clubs
    cmp byte[4],0x26    ;check if n is below 38
    jbe _print_s        ;if so, print spades
    cmp byte[4], 0x33   ;check if n is below 51
    jbe _print_d        ;if so,print diamnonds
    
    ret
}

_print_h:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 6             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET h   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num

_print_c:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET c   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num
    
_print_s:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 5             ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET s   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num
    
_print_d:
;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX,  8           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET d   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    jmp string_to_num




def display_card { ; player hit method
    call rng
    ; randomly displays value of card
    MOV bp, OFFSET deck
    mov al, byte [4]
    mov si, ax; rng card value
    add bp, si ; the index of the string we want to print
    mov ah, 0x02 ; BIOS function for printing char in ah, 
    mov dl, byte [bp]
    int 0x21    ;print card value
    
    ;print string instructions
    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 2           ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET of   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    call check_suit
    
    ret
}

def erase_card{
    ;sets card value to 0 in deck after it has been used
    mov ax,0        ;reset ax
    mov bp, offset deck     ;pointer to deck string
    mov al, byte [4]        ;load n index into al
    add bp,ax               ;find nth value in deck 
    mov byte [bp],0         ;set nth value to 0 in deck  
    
    ret
}



_ask_total_bet_amount:
    
    ; Initialize relevant variable
    ; Use interrupt here to read user input
    MOV ah, 0x13            ; move BIOS interrupt number in AH
    MOV cx, 73       ; move length of string in cx
    MOV bx, 0               ; mov 0 to bx, so we can move it to es
    MOV es, bx             ; move segment start of string to es, 0
    MOV bp, OFFSET total_bet_question   ; move start offset of string in bp
    MOV dl, 0              ; start writing from col 0
    int 0x10                ; BIOS inter
    
    mov ah, 0x0A
    lea dx, word buffer
    mov si, dx ;index i, start at 53
    int 0x21
    
    ;check if valid bet is placed
    cmp byte [si,1], 1 ;check if bet size has less than 2 integers
    jl _ask_total_bet_amount         ;jump back to start if so
    cmp byte [si,1],3  ;check if bet size has greater than 4 integers
    jg _ask_total_bet_amount         ;jump back to start if so
    jl _convert_total_bet    ;bet is between 10-1000, jump to game loop
    cmp byte [si,5], 0x30  ;check if last number is between 1000-1999,i.e greater than 1000
    jg _ask_total_bet_amount         ;jump to start if so
    jmp _convert_total_bet  ;bet is between 10-1000, jump to game loop
    
_convert_total_bet:
    ;convert bet string into integer
    mov bp, offset buffer
    mov di,offset total_player_bets
    add bp,1
    
    mov ax,0x01 
    
    mov bx,0
    mov bl, byte [si,2]   ;load current char in string
    
    ;cmp bl, 0xff    ; check if at end of string in buffer
    ;je _game_loop   ;finished converting, jump to next step (will be changed)
    
    mov cx,0
    mov cl,byte [bp]  ;load length of string into cl
    
    
    cmp cl, 3       ;check if in 1000's place
    je _mult_by_1000     ;multiply curr char by 1000
    cmp cl, 2           ;check if in 100's place
    je _mult_by_100      ;multiply curr char by 100
    cmp cl, 1           ;check if in 10's place
    je _mult_by_10       ;multiply curr char by 10
            
    ;add ones place to player_bets                    
    sub bl,0x30          
    mul bl              ;1 x curr char val
    add byte[di,1], al  ;add ones places to player_bets
  
    jmp _ask_bet_mode      ;conversion is finished,jump somewhere (will be changed)
    
_mult_by_10:
    ;operation to multiply by base 10^1
    mov dx, 0x0A
    mul dx            ;1 x 10
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;10 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
   
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_total_bet
    
_mult_by_100:
    ;operation to multiply by base 10^2
    mov dx, 0x64        
    mul dx            ;1 x 100
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;100 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_total_bet

_mult_by_1000:
     ;operation to multiply by base 10^3
    mov dx, 0x3E8
    mul dx            ;1 x 1000
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;1000 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_total_bet
    
_ask_round_bet_amount:
    
    ; Initialize relevant variable
    ; Use interrupt here to read user input
    MOV ah, 0x13            ; move BIOS interrupt number in AH
    MOV cx, 77      ; move length of string in cx
    MOV bx, 0               ; mov 0 to bx, so we can move it to es
    MOV es, bx             ; move segment start of string to es, 0
    MOV bp, OFFSET round_bet_question   ; move start offset of string in bp
    MOV dl, 0              ; start writing from col 0
    int 0x10                ; BIOS inter
    
    mov ah, 0x0A
    lea dx, word buffer6
    mov si, dx ;index i, start at 53
    int 0x21
    
    ; Check if the value is greater than 0 and less than the total bets
    mov bp, offset total_player_bets
    mov ah, byte [bp];load total player bets number (16 bytes)
    mov al, byte [bp,1]
    
    ;VALID INPUT CHECK NEEDS TO BE FINISHED
    ;cmp byte [si,2], 0    ; Check if the value is greater than 0
    ;jle _ask_round_bet_amount ; Jump to start if not greater than 0
    ;cmp  [si,], ; Compare with total bets (assuming it's a 16-bit integer)
    ;jg _ask_round_bet_amount ; Jump to start if greater than total bets
    ;jl _convert_round_bet ; Value is valid, proceed to game loop

    
_convert_round_bet:
    ;convert bet string into integer
    mov bp, offset buffer6
    mov di,offset round_player_bet
    add bp,1
    
    mov ax,0x01 
    
    mov bx,0
    mov bl, byte [si,2]   ;load current char in string
    
    ;cmp bl, 0xff    ; check if at end of string in buffer
    ;je _game_loop   ;finished converting, jump to next step (will be changed)
    
    mov cx,0
    mov cl,byte [bp]  ;load length of string into cl
    
    
    cmp cl, 3       ;check if in 1000's place
    je _mul_by_1000     ;multiply curr char by 1000
    cmp cl, 2           ;check if in 100's place
    je _mul_by_100      ;multiply curr char by 100
    cmp cl, 1           ;check if in 10's place
    je _mul_by_10       ;multiply curr char by 10
            
    ;add ones place to player_bets                    
    sub bl,0x30          
    mul bl              ;1 x curr char val
    add byte[di,1], al  ;add ones places to player_bets
  
    jmp start     ;conversion is finished,jump somewhere (will be changed)
    
_mul_by_10:
    ;operation to multiply by base 10^1
    mov dx, 0x0A
    mul dx            ;1 x 10
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;10 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_round_bet
    
_mul_by_100:
    ;operation to multiply by base 10^2
    mov dx, 0x64        
    mul dx            ;1 x 100
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;100 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_round_bet

_mul_by_1000:
     ;operation to multiply by base 10^3
    mov dx, 0x3E8
    mul dx            ;1 x 1000
    sub bl,0x30       ;convert char val to hex value  
    mul bx            ;1000 x curr char val
    add byte[di],ah     ;add result to player_bets (upper byte)
    add byte [di,1],al  ;add result to player_bets (lower byte)
    inc si              ;increment to next char
    dec byte[bp]
    jmp _convert_round_bet    
    

; computer betting mode
_ask_bet_mode:

    MOV ah, 0x13            ; BIOS interrupt for printing string
    MOV CX, 79        ; Length of string for bet question
    MOV BX, 0               ; Set BX to 0 for segment start of string
    MOV ES, BX              ; Move segment start of string to ES
    MOV BP, OFFSET bet_question   ; Start offset of bet question string
    MOV DL, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    mov ah, 0x0A
    lea dx, word buffer4
    mov si, dx
    int 0x21
    
     ;Determine bet amount based on the mode
    cmp byte [si,2], 0x43             ; Check if mode is Conservative
    je _conservative_mode     ; Jump if mode is Conservative
    cmp byte [si,2], 0x4E             ; Check if mode is Normal
    je _normal_mode           ; Jump if mode is Normal
    cmp byte [si,2], 0x41             ; Check if mode is Aggressive
    je _aggressive_mode       ; Jump if mode is Aggressive
    
    
; If none of the modes match, default to Normal mode
_normal_mode:
    mov al, byte [offset round_player_bet]   ; Load bet amount
    jmp _bet_done           ; Jump to the end of the betting logic
    
_conservative_mode:
    ; Under-bet human by 20%
    mov al, byte [offset round_player_bet]   ; Load bet amount
    sub al, 20             ; Subtract 20%
    jmp _bet_done           ; Jump to the end of the betting logic
    
_aggressive_mode:
    ; Outmatch human bet by 30%
    mov al, byte [offset round_player_bet]   ; Load bet amount
    add al, 30             ; Add 30%
    jmp _bet_done
    
_bet_done:
    mov byte [offset round_cpu_bet], al  ; Store the computed bet amount
    jmp _ask_num_decks      ;jump to next question

_ask_num_decks:
    MOV ah, 0x13            ; BIOS interrupt for printing string
    MOV CX, 28     ; Length of string for bet question
    MOV BX, 0               ; Set BX to 0 for segment start of string
    MOV ES, BX              ; Move segment start of string to ES
    MOV BP, OFFSET deck_question    ; Start offset of bet question string
    MOV DL, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    mov ah, 0x0A
    lea dx, word buffer3
    mov si, dx
    int 0x21
    
    mov al, byte [si,2]
    cmp al,0x31
    je _one_deck
    cmp al,0x32
    je _two_decks
    cmp al,0x33
    je _three_decks
    
; If none of the modes match, default to Normal mode
_one_deck:
    mov al, byte [offset num_decks]   ; Load bet amount
    jmp _decks_done           ; Jump to the end of the betting logic
    
_two_decks:
    ; Under-bet human by 20%
    mov al, byte [offset num_decks]   ; Load bet amount
    inc al             ; Subtract 20%
    jmp _decks_done           ; Jump to the end of the betting logic
    
_three_decks:
    ; Outmatch human bet by 30%
    mov al, byte [offset num_decks]   ; Load bet amount
    inc al             ; Add 1
    inc al             ; Add 1
    jmp _decks_done
    
_decks_done:
    mov byte [offset num_decks], al  ; Store the computed bet amount
    
    
; difficulty mode
_ask_difficulty:

    MOV ah, 0x13            ; BIOS interrupt for printing string
    MOV CX, 46             ; Length of string for difficulty question
    MOV BX, 0               ; Set BX to 0 for segment start of string
    MOV ES, BX              ; Move segment start of string to ES
    MOV BP, OFFSET difficulty_question  ; Start offset of difficulty question string
    MOV DL, 0               ; Start writing from column 0
    int 0x10                ; Invoke BIOS interrupt
    
    mov ah, 0x0A
    lea dx, word buffer5
    mov si, dx
    int 0x21
    
    cmp byte [si,2], 0x45             ; Check if difficulty level is Easy
    je _easy_level           ; Jump if difficulty level is Easy
    cmp byte [si,2], 0x4E             ; Check if difficulty level is Normal
    je _normal_level         ; Jump if difficulty level is Normal
    cmp byte [si,2], 0x48             ; Check if difficulty level is Hard
    je _hard_level           ; Jump if difficulty level is Hard
    
; If none of the levels match, default to Normal level
_normal_level:
    ; Default parameters for Normal difficulty
    jmp _difficulty_done   ; Jump to the end of difficulty level setting
_easy_level:
    ; Decrease initial money for computer opponent (50% of human's initial amount)
    jmp _difficulty_done   ; Jump to the end of difficulty level setting
_hard_level:
    ; Increase initial money for computer opponent (50% extra money than the human)
_difficulty_done:
    

string_to_num: ;for player

    MOV bp, OFFSET deck
    ;mov al, byte [4] ;rand number n (index of deck)
    mov al, byte [4]
    mov ah, 0
    mov si, ax 
    add bp, si ; the index of the string we want to print
    mov dl, byte [bp] ; stores character in

    ; add number to player byte[5] which is the 6th index
    ; which is the player score
    ;mov ax, 0 ; move zero into ax
    
    cmp dl, 0x41           ; Compare with ASCII value of 'A'
    je  convert_A            ; Jump if equal to 'A'
    cmp dl, 0x32           ; Compare with ASCII value of '2'
    je  convert_2            ; Jump if equal to '2'
    cmp dl, 0x33           ; Compare with ASCII value of '3'
    je  convert_3            ; Jump if equal to '3'
    cmp dl, 0x34           ; Compare with ASCII value of '4'
    je  convert_4            ; Jump if equal to '4'
    cmp dl, 0x35           ; Compare with ASCII value of '5'
    je  convert_5            ; Jump if equal to '5'
    cmp dl, 0x36           ; Compare with ASCII value of '6'
    je  convert_6            ; Jump if equal to '6'
    cmp dl, 0x37           ; Compare with ASCII value of '7'
    je  convert_7            ; Jump if equal to '7'
    cmp dl, 0x38           ; Compare with ASCII value of '8'
    je  convert_8            ; Jump if equal to '8'
    cmp dl, 0x39           ; Compare with ASCII value of '9'
    je  convert_9            ; Jump if equal to '9'
    cmp dl, 0x54           ; Compare with ASCII value of 'T'
    je  convert_T            ; Jump if equal to 'T'
    cmp dl, 0x4A           ; Compare with ASCII value of 'J'
    je  convert_J            ; Jump if equal to 'J'
    cmp dl, 0x51           ; Compare with ASCII value of 'Q'
    je  convert_Q            ; Jump if equal to 'Q'
    cmp dl, 0x4B           ; Compare with ASCII value of 'K'
    je  convert_K            ; Jump if equal to 'K'

convert_A:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x1             ; Add the integer value for 'A' (e.g., 11 for Ace)
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, 0
    
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth

convert_2:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x2             ; Add the integer value for '2'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
    

convert_3:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x3             ; Add the integer value for '3'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
    
convert_4:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x4             ; Add the integer value for '4'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
   
convert_5:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x5             ; Add the integer value for '5'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
   
convert_6:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x6             ; Add the integer value for '6'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
   
convert_7:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x7             ; Add the integer value for '7'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
  
convert_8:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x8             ; Add the integer value for '8'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth

convert_9:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0x9             ; Add the integer value for '9'
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth

convert_T:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xA             ; Add the integer value for 'T' (e.g., 10 for Ten)
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
    
convert_J:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xB             ; Add the integer value for 'J' (e.g., 11 for Jack)
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
   
convert_Q:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xC             ; Add the integer value for 'Q' (e.g., 12 for Queen)
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
   
convert_K:
    mov al, byte [7]        ; Load current value of byte[7] into al
    add al, 0xD             ; Add the integer value for 'K' (e.g., 13 for King)
    mov byte [7], al        ; Store the result back into byte[7]
    mov al, byte [offset p_to_d_cards]        ; Load current value of byte[7] into al
    sub al, 0x01                                       ; sub 1 from player_left_to_deal
    mov byte [offset p_to_d_cards], al   ; move value back into memory
    cmp byte [offset p_to_d_cards], 0
    jg player_hit
    cmp byte [offset p_to_d_cards], 0
    jbe player_choice_meth
    





; create a buffer for player choice
player_choice_meth:

    MOV AH, 0x13            ; move BIOS interrupt number in AH
    MOV CX, 40              ; move length of string in cx
    MOV BX, 0               ; mov 0 to bx, so we can move it to es
    MOV ES, BX              ; move segment start of string to es, 0
    MOV BP, OFFSET player_choice   ; move start offset of string in bp
    MOV DL, 0               ; start writing from col 0
    int 0x10                ; BIOS inter
    
    mov ah, 0x0A
    lea dx, word buffer2
    mov si, dx
    int 0x21
    
    mov al, byte [si,2]
    cmp byte[si,2], 0x68 ; compare to h
    je player_hit
    cmp byte[si,2], 0x73 ; s
    je player_stand
    cmp byte[si,2], 0x66 ; f
    je player_forfeit
    
    jmp player_choice_meth

player_hit:
    call display_card ; has rng inside
    
    ;if ace is hit, add when then call ace_was_hit

player_stand:
    jmp _cpu_turn ; jump here because CPU goes after player

    
player_forfeit:
    jmp _inc_cpu_win ;place holder, remove
    ; Subtract player bet from total score
    

;def ace_was_hit{
    ;ask user if they want to keep as 1 or make 11
    ;add current value plus 10
    ;ret
;}


_compare_wins:
    mov ax, 0
    mov bx, 0
    mov al, byte[offset player_wins]
    mov bl, byte[offset cpu_wins]
    
    cmp al, bl
    jg _win ; change proce
    jl _lose
    ;je tie
    
_compare_scores:
    mov ax,0
    mov bx,0

    mov al, byte [offset player_score]
    mov bl, byte [offset cpu_score]

    cmp ax,bx
    jg _inc_player_win
    cmp ax,bx
    jl _inc_cpu_win
    
_inc_player_win:
    mov ax,0
    mov al,byte [offset player_wins]
    inc ax
    mov byte [offset player_wins],al

_inc_cpu_win:
    mov ax,0
    mov al,byte [offset cpu_wins]
    inc ax
    mov byte [offset cpu_wins],al





; Gameplay

start:
   jmp _ask_total_bet_amount
   ;call ask_num_decks
_player_turn:

    mov byte[offset p_to_d_cards], 2 ; resets cards to deal
    jmp player_hit ; starts round for player, does

_cpu_turn:

_game_loop:


_end_game:
