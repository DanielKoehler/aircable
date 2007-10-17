@ERASE

0 REM PIO LIST:
0 REM 1 IR OFF
0 REM 2 RIGHT BUTTON
0 REM 3 LEFT BUTTON
0 REM 4 LASER
0 REM 9 GREEN LED
0 REM 12 MIDDLE BUTTON
0 REM 20 BLUE LED

0 REM Y used for reading
0 REM X used for calibration
0 REM W used for button
0 REM V used for debug menu
0 REM U used for lcd state
0 REM T, R used for i2c
0 REM S shows deep sleep state
0 REM ABCDEFGHIJKLMNO

0 REM $1 reserved for i2c
0 REM $2 is for button state
0 REM $3 is for peer BT address
0 REM $4 messages rate, default 15
0 REM $5 used for ice water compensation
0 REM $6 used for LCD contrast storage
0 REM $7 used for type of sensor
0 REM $8 last showed message
0 REM $9 0 for ºF, 1 for ºC


0 REM $15 code version
0 REM $16 device name
0 REM $17 Welcome message
0 REM $18 reserved

0 REM $10 - $14 types of sensor
0 REM $20 min value to compare
0 REM $21 max value to compare

0 REM $22 wake up interrupt
0 REM $23 non deep sleep interrupts


1 
2 
0 REM 3 0050C2585088
3
4 15
5 540.
6 200
7 K
8 XXXºF
9 0

10 K
11 IR
12 RESERVED
13 RESERVED
14 RESERVED

15 0.1
16 SMARTinteractive
17 SMART

20 RESERVED
21 RESERVED

22 P000000000001
23 P011000000001

@INIT 47
47 A = uarton
48 A = baud 1152
49 Z = 1
50 A = disable 3
0 REM LED output and on
51 A = pioout 9
52 A = pioset 9

0 REM LCD contrast between 100 and 200
53 L = atoi $6
54 IF L > 200 THEN 57
55 IF L = 0 THEN 57
56 GOTO 61
57 L = 160
58 $0[0] = 0
59 PRINTV L
60 $6 = $0
0 REM LCD bias
61 A = auxdac L

0 REM show welcome message
62 $0[0] = 0
63 PRINTV $17
64 PRINTV" "
65 PRINTV $7
66 PRINTV"         "
67 A = lcd $0

0 REM set name
69 A = getuniq $18
70 $0 = $16
71 PRINTV " "
72 PRINTV $18
73 A = name $0

0 REM initialize buttons 
0 REM PIO2 right, PIO3 left, PIO12 middle
0 REM PIO12 goes high when pressed, add 
74 A = pioin 12
75 A = pioclr 12
0 REM right button
76 A = pioin 2
77 A = pioset 2
78 A = pioin 3
79 A = pioset 3

0 REM schedule wake up interrupt.
80 A = pioirq $22

0 REM button state variable
81 W = 0

82 A = zerocnt

0 REM ice water compensation
83 X = atoi $5[0]
84 IF X > 700 THEN 87
85 IF X = 0 THEN 87
86 GOTO 91
87 X = 460
88 $0[0] = 0
89 PRINTV X
90 $5 = $0

91 A = strlen $3
92 IF A >= 12 THEN 100
93 $0[0]=0
94 PRINTV"NOT PAIRED, I CAN'T "
95 PRINTV"DO MY DUTY"
96 A = strlen $0
97 FOR B = 0 TO A-8
98 C = lcd$0[0]
99 NEXT B


0 REM let's start up
100 Q = 0;
101 ALARM 10
0 REM mark we are booting
102 U = 1000
103 A = nextsns 15

0 REM laset pio out and high
104 A = pioset 4
105 A = pioout 4
106 A = lcd
107 A = uartoff
108 IF $480[0]<>0 THEN 117
109 $480="BT ADDR  "
110 $481="PEER BT  "
111 $482="CONTRAST "
112 $483="PROBE    "
113 $484="CALIBRATE"
114 $486="%F \ %C  "
115 $487="INQUIRY  "
116 $488="PAIR     "
117 S = 0
118 RETURN


0 REM buttons and power
@PIO_IRQ 120
0 REM press button starts alarm for long press recognition
120 IF $0[2]=48 THEN 130;
121 IF $0[3]=48 THEN 130;
122 IF $0[12]=49 THEN 130;
0 REM was it a release, handle it
123 IF W <> 0 THEN 200;
124 RETURN

0 REM button press, save state, start ALARM
130 IF S = 0 THEN 140
131 $2 = $0;
132 W = 1;
133 ALARM 3
134 RETURN

140 A = pioirq $23
141 S = 1
142 A = uarton
143 A = lcd"PRESS     "
144 ALARM 60
145 N = -1
146 RETURN

0 REM button handlers -----------------

0 REM long button press
150 A = pioget 12
151 B = pioget 2
152 C = pioget 3
0 REM M = power off
0 REM M + R = visible
0 REM R + L = debug panel
153 IF B = 0 THEN 180
154 IF A = 1 THEN 160
0 REM ignore other long presses
155 W = 0
156 ALARM 1
157 RETURN

0 REM long button press
160 A = lcd "GOOD BYE"
161 ALARM 0;
162 A = pioget 12;
163 IF A = 1 THEN 162;
164 A = lcd;
165 A = reboot;
166 FOR E = 0 TO 10
167   WAIT 1
168 NEXT E
169 RETURN

0 REM combinations handler
180 IF A = 1 THEN 185
181 IF C = 0 THEN 190
182 GOTO 155

0 REM discoverable for 2 minutes
185 A = slave 120
185 A = enable 1
187 A = lcd "VISIBLE     "
188 WAIT 3
189 GOTO 155

0 REM debug mode
190 A = lcd"DEVICE     "
191 WAIT 2
192 U = 10
193 V = 0
194 GOTO 490

0 REM short press handler
0 REM right, left, middle
200 A = uarton
201 W = 0
202 IF U <> 0 THEN 495
203 A = status
204 IF A > 1 THEN 208
205 IF $2[2] = 48 THEN 225;
206 IF $2[3] = 48 THEN 235;
207 IF $2[12] = 49 THEN 210;
208 ALARM 60
209 RETURN

0 REM connect to peer
210 A = strlen $3
211 IF A < 12 THEN 220
212 A = master $3
213 U = 10
214 ALARM 20
215 A = lcd"WAIT. . . "
216 A = uarton
217 RETURN

220 A = lcd"NOT PAIRED"
221 ALARM 60
222 RETURN

0 REM show batteries level
225 A = lcd"WAIT. . ."
226 U = 100
227 A = nextsns 1
228 ALARM 60
229 N = 1
230 RETURN

0 REM show current temp
235 A = lcd"WAIT. . ."
236 GOSUB 360
237 ALARM 60
238 RETURN


@ALARM 240
240 A = pioset 9
241 A = uarton

242 IF U >= 200 THEN 250
243 IF U <> 0 THEN 245
244 IF W = 1 THEN 150

245 S = 0
246 A = lcd
247 A = pioirq $22
248 A = uartoff
249 N = 1
250 RETURN

@SENSOR 296
296 ALARM 0
297 IF N <> 0 THEN 350;
298 A = pioset 9;
299 A = uarton;
300 A = sensor $0;
301 V = atoi $0;
302 IF U = 100 THEN 310;
303 IF V <= 2100 THEN 330;
0 REM meassure again in 30 minutes
304 N = 1;
305 A = nextsns 1800;
306 ALARM 20
307 RETURN

310 U = 0;
311 J = 0;
312 IF V < 3000 THEN 314;
313 J = J + 20;
314 IF V < 2820 THEN 316;
315 J = J + 20;
316 IF V < 2640 THEN 318;
317 J = J + 20;
318 IF V < 2460 THEN 320;
319 J = J + 20;
320 IF V < 2100 THEN 322;
321 J = J + 20;
322 $0="BAT 
323 PRINTV J;
324 PRINTV"    
325 A = lcd $0;
326 ALARM 30;
327 GOTO 304; 

330 $0="LOW BATT";
331 A = lcd $0;
332 A = ring;
333 WAIT 1;
334 $0 = "#LB%";
335 PRINTV V;
336 A = strlen $3;
337 IF A < 12 THEN 304;
338 A = pioset 20;
339 A = message $3;
340 WAIT 20
341 A = status;
342 IF A < 100 THEN 304;
343 A = disconnect 3;
344 A = pioclr 20
345 GOTO 304;

350 ALARM 10
351 N = N -1;
352 RETURN;

0 REM display temp handler ------
360 GOSUB 410
361 IF $7[0] = 73 THEN 380
362 $0="T "
363 Y = Y + X
364 Y = Y / 20

0 REM show in ºF or ºC?
365 IF $9[0]=49 THEN 372
0 REM convert to ºF
366 Y = Y * 9
367 Y = Y / 5
368 Y = Y + 32
369 PRINTV Y
370 PRINTV"%F         "
371 GOTO 374

0 REM display ºC
372 PRINTV Y
373 PRINTV"%C         "


0 REM save temp string. then display
374 $8 = $0
375 A = lcd $8
376 RETURN

0 REM IR sensor
380 $0 ="IR. "
381 IF Y  <= -32000 THEN 405
0 REM ºF or ºC?
382 IF $9[0]=49 THEN 395
383 Y = Y * 9
384 Y = Y / 5
385 Y = Y + 320
386 C = Y / 10
387 PRINTV C
388 PRINTV"."
389 D = C * 10
390 D = Y-D
391 PRINTV D
392 A = pioset 1
393 GOTO 370

395 C = Y / 10
396 PRINTV C
397 PRINTV"."
398 D = C * 10
399 D = Y-D
400 PRINTV D
401 A = pioset 1
402 GOTO 373

405 $0="ERR READ"
406 A = lcd $0
407 RETURN

0 REM I2C sensor reading handler
410 IF $7[0] = 75 THEN 420
411 IF $7[0] = 73 THEN 440
412 Y = 0
413 RETURN

0 REM K sensor connected to MCP3421
420 R = 0;
0 REM 461 A=ring
421 T = 1;
0 REM slave address is 0xD0
422 $1[0] = 208;
423 $1[1] = 143;
424 A = i2c $1;
425 $0[0] = 0;
426 $0[1] = 0;
427 $0[2] = 0;
428 $0[3] = 0;

429 $1[0] = 208;
430 T = 0;
431 R = 4;
432 A = i2c $1;
433 Y = $0[1] * 256;
434 Y = Y + $0[2];
435 RETURN

0 REM laser on
440 A = pioclr 4
0 REM read IR Temp module
441 A = pioout 1
0 REM 481 A = ring
442 A = pioclr 1
0 REM temp is in Kelvin
0 REM substract 273.15 to get Celsius
0 REM temp / 0.02 is K
0 REM F = address: 6 is ambient, 7 object
443 F = 7
0 REM E is repeat limit
444 E = 0;
445 $0[0] = 0;
446 $0[1] = 0;
447 $0[2] = 0;
448 R = 3;
449 T = 1;
0 REM slave address 0x5A
450 $1[0] = 180;
0 REM command read RAM addr 0x06
451 $1[1] = F;
452 A = i2c $1;
453 E = E + 1;
0 REM read until good reading
454 IF E > 10 THEN 468;
455 IF A <> 6 THEN 445;
456 IF $0[2] = 255 THEN 445;
457 IF $0[2] = 0 THEN 445;

0 REM calculate temp, limit 380 C
458 B = $0[1];
459 IF B > 127 THEN 468;
460 B = B * 256;
461 B = B + $0[0];
462 B = B - 13658;
463 B = B / 5;

464 Y = B
465 A = pioset 1
0 REM laser off
466 A = pioset 4
467 RETURN

0 REM failed reading
468 A = pioset 1
0 REM laser off
469 A = pioset 4
470 Y = -32000
471 RETURN


0 REM DEBUG MENU
0 REM 480 to 489 RESERVED!!!
480 
481 
482 
483 

490 IF V > 6 THEN 493
491 A = lcd $(480 + V)
492 RETURN

493 A = lcd"EXIT     "
494 RETURN

0 REM menu handler
495 IF U > 199 THEN 704
496 IF U = 20 THEN 546
497 IF U = 30 THEN 576
498 IF U = 40 THEN 650
499 IF U = 50 THEN 680
0 REM right left middle
500 IF $2[2] = 48 THEN 503;
501 IF $2[3] = 48 THEN 508;
502 IF $2[12] = 49 THEN 515;
503 RETURN

503 IF V > 6 THEN 506
504 V = V + 1
505 GOTO 490

506 V = 0
507 GOTO 490

508 IF V < 1 THEN 511
509 V = V - 1
510 GOTO 490

511 V = 7
512 GOTO 490

0 REM option choosen
515 ALARM 0
0 REM own addr
516 IF V = 0 THEN 526
0 REM peer addr
517 IF V = 1 THEN 532
0 REM contrast
518 IF V = 2 THEN 540
0 REM probe
519 IF V = 3 THEN 570
0 REM calibrate
520 IF V = 4 THEN 590
0 REM message rate
521 IF V = 5 THEN 640
0 REM ºF / ºC
522 IF V = 6 THEN 670
523 U = 0
524 ALARM 1
525 RETURN

0 REM own addr
526 A = getaddr
527 FOR B = 0 TO 4
528 A = lcd $0[B]
529 WAIT 1
530 NEXT B
531 RETURN

0 REM peer addr
532 A = strlen $3
533 IF A < 12 THEN 536
534 $0 = $3
535 GOTO 527

536 A = lcd"NO PEER "
537 RETURN

0 REM contrast
540 $0="TEST 
541 PRINTV L
542 A = auxdac L
543 A = lcd$0
544 U = 20
545 RETURN

546 IF $2[2] = 48 THEN 550;
547 IF $2[3] = 48 THEN 555;
548 IF $2[12] = 49 THEN 560;
549 RETURN

550 IF L > 220 THEN 540
551 L = L + 10
552 GOTO 540

555 IF L < 160 THEN 540
556 L = L - 10
557 GOTO 540

560 U = 10
561 $0[0]=0
562 PRINTV L
563 $6 = $0
564 ALARM 1
565 RETURN

570 U = 30
571 J = 0

572 $0 = $(10+J)
573 PRINTV"            "
574 A = lcd $0
575 RETURN

0 REM probe selector
576 IF $2[2] = 48 THEN 580;
577 IF $2[3] = 48 THEN 582;
578 IF $2[12] = 49 THEN 585;
579 RETURN

580 J = 0
581 GOTO 572

582 J = 1
583 GOTO 572

585 $7 = $(10+J)
586 U = 10
587 ALARM 1
588 RETURN

0 REM calibration
590 IF $7[0] <> 75 THEN 634
591 ALARM 0
592 $0[0] = 0
593 PRINTV"           PUT PR"
594 PRINTV"OBE IN ICEWATER" 

595 E = strlen $0
596 FOR D = 1 TO 2
597  FOR C = 1 TO E -8
598   A = lcd$0[C];
599  NEXT C;
600  WAIT 1
601 NEXT D
602 $0[0] = 0
603 PRINTV "        STIRR"
604 PRINTV " FOR 30 SECONDS "
605 E = strlen $0
606 FOR C = 1 TO E -8
607   A = lcd$0[C];
608 NEXT C;
609 WAIT 1

610 D = 30
611 $0[0] = 0
612 PRINTV"STIRR "
613 PRINTV D
614 PRINTV"    "
615 A = lcd $0

0 REM check buttons because we cannot get PIO interrupts here
0 REM we do that instead of 1 sec wait
0 REM 474 WAIT 1 << no can do

616 FOR F = 0 TO 3
617  A = pioget 12;
618  IF A = 1 THEN 626;
619  A = pioget 2;
620  IF A = 0 THEN 626;
621  A = pioget 3;
622  IF A = 0 THEN 626;
623 NEXT F;

624 D = D -1
625 IF D > 0 THEN 611

626 $0 = "DONE "
627 PRINTV Y
628 PRINTV"          "
629 A = lcd $0

0 REM store X persistently
630 $0[0] = 0
631 PRINTV Y
632 $5 = $0
633 X = Y
634 U = 10
635 ALARM 1
636 RETURN

0 REM message rate
640 U = 40
641 P = P / 60

642 $0[0] = 0
643 PRINTV P
644 PRINTV" MIN         "
645 A = lcd $0
646 RETURN

650 IF $2[2] = 48 THEN 654;
651 IF $2[3] = 48 THEN 657;
652 IF $2[12] = 49 THEN 660;
653 RETURN

654 IF P > 55 THEN 642
655 P = P + 5
656 GOTO 642

657 IF P < 5 THEN 642
658 P = P - 5
659 GOTO 642

660 U = 10
661 $0[0]=0
662 PRINTV P
663 $4 = $0
664 P = P * 60
665 ALARM 1
666 RETURN

0 REM ºF / ºC changer
670 U = 50
671 J = 0

672 IF J > 0 THEN 676
673 A = lcd "%F              "
674 ALARM 0
675 RETURN

676 A = lcd "%C              "
677 GOTO 674

0 REM right left middle
680 IF $2[2] = 48 THEN 685;
681 IF $2[3] = 48 THEN 687;
682 IF $2[12] = 49 THEN 689; 
683 RETURN

685 J = 0
686 GOTO 672

687 J = 1
688 GOTO 672

689 $0[0] = 0
690 PRINTV J
691 $9=$0
692 U = 10
693 ALARM 1
694 RETURN

0 REM __________INTERACTIVE MODE_______
@MASTER 699
699 A = nextsns 18000
700 A = lcd "WAIT . . ."
701 U = 200
702 A = pioset 20
703 GOTO 710

0 REM __interactive mode button handler __
0 REM $MENU code: right, left, middle
704 IF $2[2] = 48 THEN 810;
705 IF $2[3] = 48 THEN 820;
706 IF $2[12] = 49 THEN 830;
707 RETURN

0 REM __generate menu __
709 RESERVED
0 REM __send our current temp__
710 PRINTM"!"
711 GOSUB 545
712 PRINTM Y
713 PRINTM":"
714 PRINTM X
715 PRINTM"#"
716 PRINTM$11
717 PRINTM"\n"

0 REM __ get amount of messages __
718 TIMEOUTM 5
719 INPUTM $0
720 IF $0[0] = 63 THEN 750
721 IF $0[0] = 37 THEN 725
722 PRINTM"@@@@\n\r"
723 WAIT 3
724 GOTO 710

725 $709 = $0[1]
726 $0 = $709
0 REM M amount of options
727 K = atoi $0
728 C = 0
729 IF K > 100 THEN 745

0 REM __get each menu entry __
730 TIMEOUTM 20
731 INPUTM $0
732 $(900+C)=$0[2]
733 C = C +1
734 IF C>= K THEN 737
735 PRINTM"&"
736 GOTO 738
737 PRINTM"$"
738 A = hex8 C
739 PRINTM$0
740 PRINTM"\n"
741 IF C < K THEN 730
0 REM V is index
0 REM K is amout of messages
742 V = 0
743 GOTO 790

745 A = lcd"ERROR...    "
746 RETURN

0 REM <monitor> handler
750 A = xtoi $0[1]
751 S = A
752 IF A < 4 THEN 759
0 REM we receive max and min
753 PRINTM"&MIN\n\r"
754 INPUTM $20
755 PRINTM $20
756 PRINTM"\n\r&MAX\n\r
757 INPUTM $21
758 A = A - 4
759 IF A < 2 THEN 761
760 A = A -2
761 IF A < 1 THEN 770
762 U = 0
763 GOTO 220

770 U = 2
771 IF S < 4 THEN 788
0 REM PLACE TO COMPARE
788 S = 0
789 GOTO 710

0 REM clear lcd then display menu
790 $0=$(900+V)
791 A = strlen $0
792 PRINTV"          "
793 A = lcd $0
794 RETURN

0 REM if line is empty then we show the
0 REM exit option
795 A = lcd "EXIT     "
796 V = -1
797 RETURN

0 REM __right button pressed
810 V = V + 1
811 IF V = K THEN 795
812 GOTO 790

0 REM __left button pressed
820 IF V =-1 THEN 824
821 IF V = 0 THEN 795
822 V = V-1
823 GOTO 790

824 V = K-1
825 GOTO 790

0 REM __middle button pressed
830 IF V = -1 THEN 840
831 PRINTM"@"
832 A = V+1
833 PRINTM A
834 GOTO 710

0 REM __choose exit, tell NSLU2
840 PRINTM"\x03"
841 A = lcd"Finished"
842 ALARM 3
843 U = 0
844 RETURN


@SLAVE 950
0 REM LED on
950 ALARM 0
951 Q = 0
952 A = pioset 20
953 A = shell
954 RETURN

0 REM do we need this at all???
@CONTROL 960
0 REM remote request for DTR, disconnect
960 IF $0[0] = 49 THEN 962;
961 REM A = disconnect 1
962 RETURN 

0 REM slave for 60 seconds after boot
0 REM then stop FTP too
@IDLE 980
980 A = pioclr 9
981 A = pioset 9
982 IF Q = 1 THEN 992
983 IF Q = 2 THEN 996
984 A = slave -1
985 Q = 1
0 REM startup the automatic again
986 IF U = 2 THEN 991
987 U = 0
988 W = 0
989 ALARM 2
990 RETURN

0 REM after some time disable FTP
992 A = disable 3
993 WAIT 3
994 A = slave -1
995 Q = 2
996 RETURN

