#!/bin/bash

#use this when on star
#use regular when on hive
#alias bc="~cs9e-1/bin/arch/sun4u/bc"

# bashcalc <expression>
# This function simply passes in the given expressions to 'bc -l' and
#prints the result
function bashcalc {
  echo "$1" | bc -l
 }

# sine <expression>
# This function prints the sine of the given expression
function sine {
    echo "s ($1)" | bc -l
}

  # cosine <expression>
  # This function prints the cosine of the given expression
function cosine {
  echo "c ($1)" | bc -l
}

# angle_reduce <angle>
# Prints the angle given expressed as a value between 0 and 2pi
function angle_reduce {
  pipi=$(echo "8*a(1)" | bc -l)
  integr=$(echo "scale = 0;$1/$pipi" | bc -l)
  ans=$(echo "$1-$integr*$pipi" | bc -l)
  echo "$ans"
}
function float_lte {
  echo $1 '<='  $2 | bc -l

}

function float_lt {
  echo $1 '<'  $2 | bc -l

}
function float_eq {
  echo $1 '==' $2 | bc -l
}
#additional functions not required 
function float_gt {
  echo $1 '>'  $2 | bc -l

}
function float_gte {
  echo $1 '>='  $2 | bc -l

}


function add {
  echo $1 '+' $2 | bc -l
}
function subtract {
  echo $1 '-' $2 | bc -l
}
function multiply {
  echo $1 '*' $2 | bc -l
}
function divide {
  echo $1 '/' $2 | bc -l
}