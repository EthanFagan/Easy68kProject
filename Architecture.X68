*-----------------------------------------------------------
* Title      : Castle botherers 7
* Written by : Ethan Fagan
* Date       : 16/3/18
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    org $1000

*-------------------------------------------------------
*------horses stored at $2000--
*-------------------------------------------------------
*------soldiers stored at $2500---
*-------------------------------------------------------
*------gold stored at $2250---
*-------------------------------------------------------
*------feed stored at $2200---
*-------------------------------------------------------
*------castle strength stored at $2750---
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
min_feed    EQU 100    min feed requirement
min_horses  EQU 1      min number of horses
max_horses  EQU 10     max number of horses
min_soldier EQU 6      min soldiers
min_charge  EQU 1      min rate of fuel use based of speed (oats for horses)
max_charge  EQU 5      max rate e.g. Flank       
hit_point   EQU 5      points accumilated on castle (objective) strike
miss_point  EQU 8      points deducted for ordinace miss

amount_feed_purchased EQU 0      amount of feed entered by the player
amount_horses_purchased EQU 0    amount of horses entered by the player
amount_soldiers_hired EQU 0      amount of soldiers entered by the player

mine_loc    EQU 100    example for a hit


*Start of Game
start:
    move.b  #100,$4000 put score/health in memory location $4000
    lea     $4000,A3   assign address A3 to that memory location
    move.l  #0,$2000    assigns initial soldiers, gold, feed, horses and the strength of the first castle
    move.l #0,$2500
    move.l #200,$2250
    move.l #5,$2750

    bsr     welcome    branch to the welcome subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.b  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     soldiers        branch to soldiers input subroutine
    bsr     horses          branch to ship input subroutine
    bsr     feed            branch to feed input subroutine
    bsr     rate            branch to rate (charging speed) input subroutine
    bsr     distance        branch to mission distance/location input subroutine
    
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         

    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     market           enters the market menu
    bsr     siege
    rts
*-------------------------------------------------------
*---------------Draw Mission Updates--------------------
* Draw the game progress information, status regarding
* mission
*-------------------------------------------------------
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*---------------------OutputHorses----------------------
outputHorses:
      bsr     endl
      lea NoOfHorses, A1
      move.b #14,D0
      trap #15
*-------loads message----
      move.l $2000,D1
      move.b #3,D0
      trap #15
      rts
*-------------------------------------------------------
*---------------------OutputSoldiers--------------
outputSoldiers:
      bsr     endl
      lea OutPutSol,A1
      move.b #14,D0
      trap #15
*------loads message-----
      move.l $2500, D1
      move.b #3,D0
      trap #15
      rts
*-------------------------------------------------------
*---------------------OutputFeed------------------
outputFeed: 
      bsr     endl
      lea NoOfFeed,A1
      move.b #14,D0
      trap #15
*---------loads messge-----
      move.l $2500, D1
      move.b #3,D0
      trap #15
      rts
*-------------------------------------------------------
*---------------------OutputGold--------------
outputGold
      bsr     endl
      lea NoOfGold, A1
      move.b #14,D0
      trap #15

      move.l $2250,D1
      move.b #3,D0
      trap #15
      rts



*-------------------------------------------------------
*------------------Display status-----------
*-------------------------------------------------------
Status:
       bsr outputSoldiers
       bsr outputHorses
       bsr outputFeed
       bsr outputGold
       bsr endl       
       rts
*-------------------------------------------------------
*------------------Market-------------------------------
*-------------------------------------------------------
market: 
       lea market_image,A1
       move.b #14,D0
       trap #15
       bsr Status
       bsr horses  
       bsr soldiers
       bsr feed    
       rts

*-------------------------------------------------------
*------------------chooseCastle-------------------------
*-------------------------------------------------------
chooseCastle:
          
       rts

*-----------------------Horse feed-----------------------
* Input the feed load for each horse. Feed costs money
* For an advanced mark you need to manage this resource
*------------------------------------------------------- 
feed:
    bsr     endl
    *------------------------------------------------------
    lea     shoppp_image, A1
    move.b  #14,D0
    trap    #15
    bsr     endl  
*------------------------------------------------------
    lea     feed_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.l #0,D1
    
    move.b #4,D0
    trap    #15
    

    move.l $2200, d2
    
    add.l d1,d2
    move.l d2, $2200
    
    move.l $2250, d2
    mulu #5 ,d1
    sub.l d1, d2
    move.l d2, $2250 *adjusts the gold count

    bsr Status
    rts

*-------------------------------------------------------
*--------------------Horses Inventory---------------------
* Number of horses to be allocated to a mission 
*------------------------------------------------------- 
horses:
    bsr     endl
    *----displays shop image----
    lea     shoppp_image, A1
    move.b  #14,D0
    trap    #15
    bsr     endl 
    
    lea     horses_msg,A1
    
    move.b  #14,D0
    trap    #15
    
    move.l #0,D1
    *----addds amount entered to horses and subtracts it from gold
    move.b #4,D0
    trap    #15
    

    move.l $2000, d2
    
    add.l d1,d2
    move.l d2, $2000
    
    move.l $2250, d2
    mulu #25,d1
    sub.l d1, d2
    move.l d2, $2250 *adjusts the gold count

    bsr Status 
    rts
    
*-------------------------------------------------------
*-----------------------Soldiers----------------------
*-------------------------------------------------------   
soldiers:
    bsr     endl
    *-----------displays shop image----
    lea     shoppp_image,A1
    move.b  #14,D0
    trap    #15
    bsr     endl       
    lea     soldiers_msg,A1
    
    move.b $2500, D3
    divu #25, D3
    move.b  #14,D0
    trap    #15
    
    move.l #0,D1
    *---user enters  a value and value is added to soldiers and taken away from gold
    move.b #4,D0
    trap    #15
    
    move.l $2500, d2
    
    add.l d1,d2
    move.l d2, $2500 *adjusts the soldiers count
    
    move.l $2250, d2
    mulu #25,d1
    sub.l d1, d2
    move.l d2, $2250 *adjusts the gold count
    *-----------------
*    cmp #0,$2250
*    blt replay
    
    bsr Status
    rts

*-------------------------------------------------------
*------------------sieging------------------------------
*-------------------------------------------------------
siege:
      lea castle_image, A1
      move.b #14,D0
      trap #15
      
      move.l $2000, d2
      move.l $2750, d3
      bsr victory_screen
      rts
*-------------------------------------------------------
*-----------------victory-------------------------------
*-------------------------------------------------------
victory_screen:
        bsr clear_screen
        lea victory, A1
        move.b #14,D0
        trap #15
        bsr market
*-------------------Horse(s) Charge Speed---------------
* horses speed to and from a mission
*------------------------------------------------------- 
rate:
    bsr     endl
    bsr     decorate
    lea     rate_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*------------------Mission Distance---------------------
* Distance to battle location
*------------------------------------------------------- 
distance:
    bsr     endl
    bsr     decorate
    lea     distance_msg,A1
    move.b  #14,D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:

       rts

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.b  #14,D0
    trap    #15
    move.b  (A3),D1     retrieve the value A3 point to and move to D1
    move.b  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Taking Fire---------------------
* This could be used for collision detection, if 
*-------------------------------------------------------
collision:
    move.b  #mine_loc,D1
    cmp     #100,D1 is( x == 100)?
	bne     collision_miss if x is equal to 100, then hit
collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15
    rts

*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.b  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.b  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.b  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.b  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     defeat,A1
    move.b  #14, D0
    trap    #15
    
    lea     replay_msg,A1
    move.b  #14,D0
    trap    #15
    
    move.b  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'SIEGEMASTER:A GENERAL RISES'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'You are nothing.They made it so.The dark wizards who rule   '
                dc.b    $0D,$0A
                dc.b    'the lands you called home.They took all you had, your clothes,'
                dc.b    $0D,$0A
                dc.b    'your family, your name.With nothing left, you decide its time for change'
                dc.b    $0D,$0A
                dc.b    'You will raise an army, and burn their strongholds to the ground.'
                dc.b    $0D,$0A,0
feed_msg:       dc.b    'Feed load (each horse needs 5 units of feed)'
                dc.b    $0D,$0A
                dc.b    'cost per unit = 5 feed/1 gold'
                dc.b    $0D,$0A
                dc.b    'Enter feed load : ',0
horses_msg:     dc.b   'Orses are 25 gold a pop'
                dc.b    $0D,$0A
                dc.b    'Ow many orses ye want?:',0
rate_msg:       dc.b    'One Third[1], Two Thirds[2], Standard Charge[3], ' 
                dc.b    $0D,$0A
                dc.b    'Full Charge[4], Flank Charge[5] units feed per click'
                dc.b    $0D,$0A
                dc.b    'Enter Speed : ',0
distance_msg:   dc.b    'Mission distance e.g. 40 (with 100 units of feed  '
                dc.b    $0D,$0A
                dc.b    'One Third speed 20 units remain for manuvouirs) horses '
                dc.b    $0D,$0A
                dc.b    'Horses without feed are lost.'
                dc.b    $0D,$0A
                dc.b    'Enter mission distance : ',0
soldiers_msg:       dc.b    'Each horse you plan to purchase needs a knight'
                dc.b    $0D,$0A
                dc.b    'cost per unit = 25 gold'
                dc.b    $0D,$0A
                dc.b    'Enter # of soldiers you want: ',0
gameplay_msg:   dc.b    'Add Gameplay !',0
update_msg:     dc.b    'Update Gameplay !',0
draw_msg:       dc.b    'Draw Screen !',0
hit_msg:        dc.b    'Strike!',0
miss_msg:       dc.b    'Miss!',0
loop_msg:       dc.b    '.',0
replay_msg:     dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:        dc.b    'Score : ',0
shoppp_image:   dc.b    '***********************   "WELCOME"   ***********************'
                dc.b    $0D,$0A
                dc.b    '********************          O            ******************'
                dc.b    $0D,$0A
                dc.b    '**************              / V \            ****************'
                dc.b    $0D,$0A
                dc.b    '********           -----------------------          *********'
                dc.b    $0D,$0A
                dc.b    '*******            |*******______********|           ********'
                dc.b    $0D,$0A
                dc.b    '******             |******|market|*******|          *******'
                dc.b    $0D,$0A
                dc.b    '******             |*********************|            *******'
                dc.b    $0D,$0A
                dc.b    '                                                             ',0
*-----------------------------------------------------------------------------------------------
market_image:   dc.b    '**                       \market/                          **'
                dc.b    $0D,$0A
                dc.b    '**************/------/|****/--\****|\------\*****************'
                dc.b    $0D,$0A
                dc.b    '************|------|  |**/  ||  \**|   |------|**************'
                dc.b    $0D,$0A
                dc.b    '************|  D   |   /    ||    \    |  D   |**************'
                dc.b    $0D,$0A
                dc.b    '************|      | /      ||      \  |      |**************'
                dc.b    $0D,$0A
                dc.b    '*******************/        ||        \**********************'
                dc.b    $0D,$0A
                dc.b    '*****************/          ||          \********************'
                dc.b    $0D,$0A
                dc.b    '***************/            ||            \******************'
                dc.b    $0D,$0A
                dc.b    '*************/              ||              \****************'

                dc.b    '                                                             ',0
*-----------------------------------------------------------------------------------------------

castle_image:   dc.b    '*****************************/-\**************               '
                dc.b    $0D,$0A
                dc.b    '*************/\************|**0**|********/\****             '
                dc.b    $0D,$0A
                dc.b    '***********|-------------         -----------|-\****         '
                dc.b    $0D,$0A
                dc.b    '***********|  D    D     ---------   D   D   |***|***********'
                dc.b    $0D,$0A
                dc.b    '***********|  D    D        -        D   D   |***|***********'
                dc.b    $0D,$0A
                dc.b    '***********|              |*|*|              |***|***********'
                dc.b    $0D,$0A
                dc.b    '***********|              |*|*|              |***|***********'
                dc.b    $0D,$0A
                dc.b    '                                                             ',0
*-----------------------------------------------------------------------------------------------
victory:        dc.b    '*************************************************************'
                dc.b    '**************T*O*T*A*L**D*O*M*I*N*A*T*I*O*N*****************'
                dc.b    '*************************************************************'
                dc.b    '********"you have liberated the castle and its people"*******'
                dc.b    '*************************************************************',0
*-----------------------------------------------------------------------------------------------
defeat:         dc.b    '*************************************************************'
                dc.b    '**************C*R*U*S*H*I*N*G**D*E*F*E*A*T*******************'
                dc.b    '*************************************************************'
                dc.b    '********"the losses were heavy, but hope is not lost"********'
                dc.b    '*************************************************************',0
*-----------------------------------------------------------------------------------------------
OutPutSol:  dc.b   'Your current amount of soldiers is:',0
NoOfGold: dc.b   'Your current gold is:',0
NoOfFeed: dc.b   'Your current feed amount is:',0
NoOfHorses: dc.b 'Your current amount of horses is:',0
Press0: dc.b 'Press 0 to continue',0
health:     ds.w    1
score:      ds.w    1 reserve space for score

    end start

    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
