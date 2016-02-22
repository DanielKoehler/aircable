# Introduction #

This example shows how to access a high precision analog-to-digital converter with I2C interface.


# Details #

We use the 18 bit Microchip device [MCP3421](http://ww1.microchip.com/downloads/en/DeviceDoc/22003b.pdf)

The first part of the code initializes the chip to do one single conversion at 18 bit with a gain of factor 8, to use it with a type K thermocouple.

The second part reads the voltage value in 3 bytes from the ADC chip and just prints all 3 bytes to the SLAVE port.

The generic function "A = i2c $1" uses the 2 variable T and R to determine the number of bytes to be transmitted (T) and received (R). It is possible to do both at the same time, but the I2C device must be able to do that.

The first byte in the referenced $1 string contains the I2C address of the device, in this case 0xD0, or 208 in decimal. It does not count for the number of bytes transmitted. The second byte (0x8F, 143) is written into the configuration register of the chip.

Reading bytes from the chip are stored in the global variable $0. Since we want to print the numbers in decimal characters, we convert into a variable and print it.

The first 3 chars are the result of the ADC conversion, the 4th is the repeat of the configuration register. See chip data sheet.

We tested the code by running the shell over the SPP port and start the code manually.

TAG$ RUN 35
0 0 131 15


```

0 REM i2c interfaced to MCP3421

35 R = 0
36 T = 1
37 $1[0] = 208
38 $1[1] = 143
39 A = i2c $1

40 $0[0] = 0;
41 $0[1] = 0;
42 $0[2] = 0;
43 $0[3] = 0;
44 $1[0] = 208
45 T = 0;
46 R = 4;
47 A = i2c $1
48 FOR C = 0 TO 3
49   D = $0[C]
50   PRINTS D
51   PRINTS " "
52 NEXT C
53 PRINTS "\n\r"
55 RETURN

```
