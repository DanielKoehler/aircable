vCard Usage Example

# Introduction #

This example will show you how to make a vCard deliver system.


# Code #
## AIRcable.bas ##
```
@ERASE

0 REM Line $1 BT address of the accepted peer
1 0

@INIT 50
0 REM debug
50 Z = 1
51 A = baud 1152
0 REM we must be visible
52 A = slave -1
0 REM J stores the pio where the led is attached
53 J = 20
0 REM LED output an don
54 A = pioout J
55 A = pioset J
56 A = enable 2
0 REM E is the start line of the hash table
57 E = 300
0 REM L is the start line of the inq results table
0 REM M is the index inside the result table
59 L = 900
60 M = 0
61 K = 0
62 A = zerocnt
63 ALARM 1
64 RETURN

0 REM @IDLE 90
0 REM 90 A = slave 5
0 REM 91 RETURN

95 ALARM 2
96 RETURN

@ALARM 100
0 REM K state variable
0 REM K = 0 need inq
0 REM K = 1 inq in progress
0 REM K = 2 inq with results, need to sort results and send messsages
0 REM K = 3 sending messages
0 REM K = 4 file needs to be closed
100 IF K = 0 THEN 109
101 B = status
102 IF B > 0 THEN 95
103 IF K = 1 THEN 114
104 IF K = 2 THEN 125
105 IF K = 3 THEN 130
106 IF K = 4 THEN 170
107 RETURN

109 M = 0
110 A = inquiry 9
111 K = 1
112 ALARM 10
113 RETURN

114 A = status
115 IF A > 0 THEN 118
116 IF M > 0 THEN 120
117 K = 0
118 ALARM 2
119 RETURN

120 K = 2
121 GOTO 118

125 D = 0
126 K = 3
127 A = open "vCard.vcf";
128 ALARM 1
129 RETURN

130 $0 = $(L + D)
131 GOSUB 200
0 REM we will forget about collisions
132 N = readcnt
133 B = strlen $(A+E)
134 IF B > 0 THEN 160
135 GOTO 140

140 $0[0] = 0
141 FOR B = 0 TO 11
142 PRINTV $(L+D)[B]
143 NEXT B
144 PRINTV " "
145 PRINTV N
146 $(A+E) = $0

148 A = bizcard $(L+D)
149 D = D +1                             
150 IF D = M THEN 165
151 ALARM 2
152 RETURN

160 B = atoi $0(L+D)[13]
161 IF (B-N) > 240 THEN 140
162 GOTO 149

165 K = 4
166 ALARM 3
167 RETURN

170 A = close
171 K = 0
172 ALARM 2
173 RETURN

0 REM hash calc function
0 REM Prime number to use 541
200 A = 0;
201 FOR C = 0 TO 11
202 A = A + $0[C];
203 NEXT C
204 B = A / 541
205 B = B * 541
206 A = A - B
207 RETURN

@INQUIRY 220
220 ALARM 2
221 $(L+M) = $0
222 M = M+1
223 K = 2
224 RETURN
```

## Example vCard.vcf ##
```
BEGIN:VCARD
VERSION:2.1
FN:AIRcable Support
N:AIRcable Support;;;;
TEL;WORK:4088501884
EMAIL;PREF;INTERNET:support@aircable.net
ORG:Wireless Cables Inc.
URL:http://www.aircable.net
END:VCARD
```

[Download AIRcable.bas](http://aircable.googlecode.com/svn/examples/vcard/AIRcable.bas)
[Download vCard.vcf](http://aircable.googlecode.com/svn/examples/vcard/vCard.vcf)

# Explanation #
This code will search for devices and will send a vCard to each one of them. Each device will get a card once every two hours. The device will have a table in memory with devices it has all ready served, and will try not to serve them again between two hours. We use a simple HASH system to index the table, the HASH system is not the best, but is good for our use.

One thing that you must take into account when working with vCards is that you can't close the file until it has all ready been send, so you have to check the Bluetooth status before closing the file.