@ERASE

0 REM command line version
1 Pre-1.0

0 REM temp
2 TEMP

0 REM default mode
3 1110

0 REM current mode
4 z

0 REM last discovered device
5 0

0 REM friendly name
6 AIRcable

0 REM PIN
7 1234

0 REM baud rate 0 equal external
8 1152

0 REM PIO list
9 000011000

0 REM modes
0 REM cable slave
10 1010
0 REM cable master
11 3010
0 REM service slave
12 1110
0 REM service master
13 3110

@INIT 100
100 Z = 0
101 A = baud 1152
102 B = 0
103 GOTO 197
104 RETURN

0 REM seek 
0 REM I number of bytes from beggining
170 A = seek I
171 RETURN

0 REM close file
178 A = close;
179 RETURN;

0 REM open file
180 A = open "text";
181 RETURN;

0 REM Print \n\r
185 PRINTU"\n\r";
186 RETURN;

0 REM read line
189 A = read 32;
190 $2 = $0;
191 RETURN

0 REM read line + print function
192 A = read 32;
193 PRINTU $0
194 RETURN;


@UART 196
196 INPUTU $0
197 PRINTU"\x1B[2J
198 STTYU 7
199 GOSUB 185;
200 GOSUB 180;
201 GOSUB 192;
203 GOSUB 185;
204 GOSUB 192;
206 PRINTU " ";
207 PRINTU $1;
208 GOSUB 185;
209 X = 0;
210 GOTO 300;
211 RETURN

0 REM Menu creator
250 B = 1;
251 GOSUB 192;
253 GOSUB 185;
254 GOSUB 189;
255 A = strlen $2;
256 IF A = 0 THEN 264;
257 PRINTU B;
258 PRINTU " - ";
259 PRINTU $2;
260 GOSUB 185;
262 B = B+1;
263 GOTO 254;
264 IF X = 0 THEN 271
265 I = 3 * 32;
266 PRINTU"0 - ";
267 GOSUB 170;
268 GOSUB 192;
270 GOSUB 185;
271 I = 5 * 32;
272 GOSUB 170;
273 GOSUB 192
275 PRINTU " ";
276 RETURN

300 IF X = 0 THEN 400;
301 IF X = 1 THEN 400;
302 IF X = 2 THEN 410;
303 IF X = 3 THEN 414;
304 IF X = 4 THEN 420;
305 IF X = 5 THEN 425;
306 IF X = 6 THEN 430;
307 IF X = 7 THEN 435;
308 IF X = 8 THEN 399;
309 IF X = 9 THEN 440;
0 REM calc module
310 B = X / 10;
311 B = B * 10;
312 Y = X - B;
313 IF Y = 0 THEN 399;
314 IF B = 20 THEN 460;
315 IF B = 30 THEN 470;
316 IF B = 40 THEN 530;
317 IF B = 50 THEN 550;
318 IF B = 60 THEN 660;
319 IF B = 70 THEN 710;
320 GOTO 450;

350 INPUTU $0;
351 X = X + $0[0]-48;
352 PRINTU"\x1B[2J
353 GOTO 300

399 X = 0
0 REM main
400 I = (29*32);
401 GOSUB 170:
402 GOSUB 250;
403 GOTO 350;

0 REM mode menu
410 I = (58*32);
412 X = X *10;
413 GOTO 401;

0 REM manual mode
414 I = (64*32);
415 GOTO 412;

0 REM relay pair
420 I = (69*32);
421 GOTO 412;

0 REM edit settings
425 I = (74*32);
426 GOTO 412;

0 REM security
430 I = (85*32);
431 GOTO 412;

0 REM debug
435 I = (92*32);
436 GOTO 412;

0 REM reboot
440 A = reboot
441 WAIT 2
442 RETURN

0 REM invalid option
450 I = (27*32);
451 GOSUB 170;
452 GOSUB 192;
454 GOSUB 185;
455 X = 0;
456 GOTO 400;

0 REM mode selector
460 IF Y > 4 THEN 450;
461 $4=$(9+Y);
462 GOTO 399

0 REM manual mode
470 IF Y = 1 THEN 495
471 IF Y = 2 THEN 480
472 IF Y = 3 THEN 510
473 GOTO 450

0 REM manual inquiry
0 REM relay mode inquiry
480 I = (23*32);
481 GOSUB 170;
482 GOSUB 192;
484 PRINTU "18 ";
485 I = (22*32);
486 GOSUB 170;
487 GOSUB 192;
489 GOSUB 185
490 GOTO 399

0 REM open slave channel
495 I = (24*32);
496 GOSUB 170;
497 GOSUB 192;
499 PRINTU "18 ";
500 I = (22*32);
501 GOSUB 170;
502 GOSUB 192;
504 GOSUB 185
505 GOTO 399

0 REM manual master
0 REM relay mode pair
510 I = (98*32);
511 GOSUB 170;
512 GOSUB 192;
514 PRINTU $5;
515 GOSUB 185;
516 GOSUB 192;
518 GOTO 399;

0 REM realy mode menu
530 IF Y = 1 THEN 480;
531 IF Y = 2 THEN 510;
532 IF Y = 3 THEN 540;
533 GOTO 450;

0 REM relay mode settings menu
540 I = (152 * 32);
541 GOSUB 545
542 IF $0[0] < 49 THEN 450
543 IF $0[0] > 50 THEN 450
544 RETURN

545 GOSUB 170;
546 GOSUB 250;
547 INPUTU $0
548 RETURN

0 REM edit settings menu
550 IF Y = 1 THEN 565
551 IF Y = 2 THEN 575
552 IF Y = 3 THEN 580
553 IF Y = 4 THEN 590
554 IF Y = 5 THEN 595
555 IF Y = 6 THEN 620
556 IF Y = 7 THEN 630
558 IF Y = 8 THEN 640
559 IF Y = 9 THEN 650
560 GOTO 450

0 REM new name
565 I = (101 * 32);
566 A = 6
567 GOSUB 570
568 GOTO 399

570 GOSUB 170;
571 GOSUB 610;
572 INPUTU $A
573 RETURN

0 REM new pin
575 I = (103 * 32);
576 A = 7
577 GOSUB 570
578 GOTO 399

0 REM interface settings
580 I = (105 * 32);
581 GOSUB 545
582 IF $0[0] < 49 THEN 450
583 IF $0[0] > 50 THEN 450
584 GOTO 399

0 REM baud rate
590 I = (109*32);
591 A = 2
592 GOSUB 570
593 GOTO 399

0 REM parity
595 I = (112*32);
596 GOSUB 545
597 IF $0[0] < 49 THEN 450
598 IF $0[0] > 51 THEN 450
599 GOTO 399

0 REM string input.
610 GOSUB 189;
611 A = strlen $2;
612 IF A = 0 THEN 616;
613 PRINTU $2;
614 GOSUB 185;
615 GOTO 610
616 RETURN;

0 REM stop bits
620 I = (118*32);
621 GOSUB 545
622 IF $0[0] < 49 THEN 450
623 IF $0[0] > 50 THEN 450
624 GOTO 399

0 REM pio list
630 I = (121*32);
631 A = 9;
632 GOSUB 570
633 GOTO 399

0 REM Class of Device
640 I = (123*32);
641 A = 2;
642 GOSUB 570;
643 GOTO 399;

0 REM Date
650 I = (126*32);
651 A = 2;
652 GOSUB 570;
653 GOTO 399;

0 REM security menu.
660 IF Y = 1 THEN 670
661 IF Y = 2 THEN 680
662 IF Y = 3 THEN 690
664 IF Y = 4 THEN 700
665 GOTO 450

0 REM obex/obexftp settings
670 I = (129*32);
671 GOSUB 545
672 IF $0[0] < 49 THEN 450
673 IF $0[0] > 52 THEN 450
674 GOTO 399

0 REM PIN/settings settings
680 I = (134*32);
681 GOSUB 545
682 IF $0[0] < 49 THEN 450
683 IF $0[0] > 52 THEN 450
684 GOTO 399

0 REM Name Filter
690 I = (139*32);
691 A = 2
692 GOSUB 570;
693 GOTO 399;

0 REM Addr Filter
700 I = (141*32);
701 A = 2
702 GOSUB 570;
703 GOTO 399;

0 REM debug menu
710 IF Y = 1 THEN 720
711 IF Y = 2 THEN 730
712 IF Y = 3 THEN 748
713 IF Y = 4 THEN 750
714 IF Y = 5 THEN 760
715 GOTO 450;

0 REM shell
720 GOTO 399

0 REM enable trace
730 I = (144*32);
731 A = 2
732 GOSUB 570;
733 GOTO 399;

0 REM read input / print line
740 I = (149*32);
741 A = 2;
742 A = atoi($2);
743 $0=$A;
744 GOSUB 190;
745 GOSUB 185;
746 RETURN

0 REM print line
748 GOSUB 740;
749 GOTO 399;

0 REM change line
750 GOSUB 740;
751 R = A;
752 I = (150*32);
753 A = 2;
754 GOSUB 570;
755 $R=$2;
756 GOTO 399;

0 REM list code
760 Z = 1 
761 FOR A = 0 TO 1024
762 $0 = $A;
763 GOSUB 193;
764 GOSUB 185;
765 NEXT A
766 Z = 0
767 GOTO 399

@IDLE 1000
1000 A = slave 15
1001 RETURN

@SLAVE 1002
1002 A = shell
1003 RETURN
