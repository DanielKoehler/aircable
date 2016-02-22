There are times when you need to use bitwise operators, for example if you need to calculate a checksum. Unfortunately the AIRcable OS lacks of this operations, so you will have to implement them.

Here we will show you some simple, but yet powerful ways to implement some commons bitwise operations for 8 bits variables.

# Bitwise AND #
Truth table:
| A | B | = |
|:--|:--|:--|
| 0 | 0 | 0 |
| 1 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 1 | 1 |

```
0 REM bitwise AND, Arguments in B and A
0 REM result in A
0 REM will modify variables V and U
650 U = 0;
0 REM If needed different than 8 bits
0 REM change next line
651 V = 128;
652 IF V = 0 THEN 662;
653 IF A<V THEN 658;
654 IF B<V THEN 660;
655 U=U+V;
656 A=A-V;
657 B=B-V;
658 IF B<V THEN 660;
659 B=B-V;
660 V=V/2;
661 GOTO 652;
662 A=U;
663 RETURN;
```

# Bitwise XOR #
Truth table:
| A | B | = |
|:--|:--|:--|
| 0 | 0 | 0 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 0 |

```
0 REM bitwise XOR, Arguments in B and A
0 REM result in A
0 REM will modify variables V and U
650 U = 0;
0 REM If needed different than 8 bits
0 REM change next line
651 V = 128;
652 IF V=0 THEN 666;
653 IF A<V THEN 658;
0 REM A=1 B=?
654 IF B<V THEN 662;
0 REM A=1 B=1
655 A=A-V;
656 B=B-V;
657 GOTO 664
658 IF B<V THEN 664;
0 REM A=0 B=1
659 U = U+V;
660 B=B-V;
661 GOTO 664
0 REM A=1 B=0
662 U=U+V;
663 A=A-V
664 V=V/2;
665 GOTO 652;
666 A=U;
667 RETURN;
```
