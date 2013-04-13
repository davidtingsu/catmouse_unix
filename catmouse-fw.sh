#!/bin/bash 
#-x
# Cat & Mouse Framework
# CS9E - Assignment 4.2
#
# Framework by Jeremy Huddleston <jeremyhu@cs.berkeley.edu>
# $LastChangedDate: 2007-10-11 15:49:54 -0700 (Thu, 11 Oct 2007) $
# $Id: catmouse-fw.sh 88 2007-10-11 22:49:54Z selfpace $

# Source the file containing your calculator functions:
#. bashcalc-functions.sh
# http://askubuntu.com/questions/98782/how-to-run-an-alias-in-a-shell-script
shopt -s expand_aliases
. bash-calc.sh
. assert.sh

TRUE=1
FALSE=0
EXIT_SUCCESS=0
EXIT_FAILURE=1
TWO_PI=$(echo "8*a(1)" | bc -l)
PI=$(echo "4*a(1)" | bc -l)
LOG=$(echo log$(date "+%Y-%m-%d_%H:%M:%S"))

# Additional math functions:

# angle_between <A> <B> <C>
# Returns true (exit code 0) if angle B is between angles A and C and false otherwise
function angle_between {
	local A=$1
	local B=$2
	local C=$3

	# ADD CODE HERE FOR PART 1

	#An angle B is between angles A and C iff both of the following criteria are met.
	#1) cos (B-A) > cos (C-A)
	#2) cos (C-B) > cos (C-A)

	#echo float_gt $( cosine $(subtract B A) )  $( cosine $(subtract C A) )  

	local ba=$( cosine $(subtract $B $A) )
	local ca=$( cosine $(subtract $C $A) )
	local cb=$( cosine $(subtract $C $B) )

	local cmp_one=$(float_gt $ba  $ca ) 
	local cmp_two=$(float_gt $cb  $ca )
	
	if [ $cmp_one -eq $TRUE ] && [ $cmp_two -eq $TRUE ]
	then
		#success
		echo $TRUE 
		exit $EXIT_SUCCESS 
	else
		#failure
		echo $FALSE 
		exit $EXIT_FAILURE 
	fi


}

#=== test angle between ===#

# angle_between <A> <B> <C>

 pi=$(echo "4*a(1)" | bc -l)
 pi_over_2=$(echo "$pi/2" | bc -l)
 pi_over_3=$(echo "$pi/3" | bc -l)
 pi_over_4=$(echo "$pi/4" | bc -l)

#== fail first cond ===#
#1) cos (B-A) > cos (C-A)
#angle_between  0 $pi_over_3 $pi_over_4 #false
#angle_between $pi_over_2   $pi_over_2 $pi_over_2 #false
cond="$(angle_between  $pi_over_4 $pi_over_2 0) -eq $FALSE" 
assert "$cond" $LINENO

#== fail second cond ===#
#2) cos (C-B) > cos (C-A)
#eq not geq
cond="$(angle_between  0 0 $pi_over_4) -eq $FALSE" 
assert "$cond" $LINENO

#== pass both cond ===#
cond="$(angle_between $pi_over_4   $pi_over_3 $pi_over_2) -eq $TRUE" 
assert "$cond" $LINENO



### Simulation Functions ###
# Variables for the state
RUNNING=0
GIVEUP=1
CAUGHT=2

# does_cat_see_mouse <cat angle> <cat radius> <mouse angle>
#
# Returns true (exit code 0) if the cat can see the mouse, false otherwise.
#
# The cat sees the mouse if
# (cat radius) * cos (cat angle - mouse angle)
# is at least 1.0.
function does_cat_see_mouse {
	local cat_angle=$1
	local cat_radius=$2
	local mouse_angle=$3
	

	local angle=$(subtract $cat_angle  $mouse_angle)
	local cosine_angle=$(cosine angle)
	local prod=$(multiply $cat_radius $cosine_angle)
	# ADD CODE HERE FOR PART 1
	if [ $(float_gte $prod 1.0) -eq $TRUE ]
	then 
		#success
		echo $TRUE 
		exit $EXIT_SUCCESS
	else

		#failure
		echo $FALSE 
		exit $EXIT_FAILURE 
	fi
}
# === TEST does_cat_see_mouse === #

#test does 1 0.8 1 
cond="$(does_cat_see_mouse 1 0.8 1) -eq $FALSE" 
assert "$cond" $LINENO
#test does 1 100  1 
cond="$(does_cat_see_mouse 1 200 1) -eq $TRUE" 
assert "$cond" $LINENO

cond="$(does_cat_see_mouse 0 1 0) -eq $TRUE" 
assert "$cond" $LINENO

# === Sanity TEST for assertion ===#
cond="0 -eq 0"
assert "$cond" $LINENO


# next_step <current state> <current step #> <cat angle> <cat radius> <mouse angle> <max steps>
# returns string output similar to the input, but for the next step:
# <state at next step> <next step #> <cat angle> <cat radius> <mouse angle> <max steps>
#
# exit code of this function (return value) should be the state at the next step.  This allows for easy
# integration into a while loop.
function next_step {
	local state=$1
	local -i step=$2
     #increment step
    local step=$(add $step 1)

	local old_cat_angle=$3
	local old_cat_radius=$4
	local old_mouse_angle=$5
	local -i max_steps=$6

	#NOTE: mouse is at the statue

	# First, make sure we are still running
	if (( ${state} != ${RUNNING} )) ; then
		echo ${state} ${step} ${old_cat_angle} ${old_cat_radius} ${old_mouse_angle} ${max_steps}
		return ${state}
	fi


    #== ALL UPDATES assuming cat is running around circle==#
    local statue_radius=1 #diameter

    #=== CAT ===#
    # cat moves an angle of 1.25, when it is at base of statue
    # cat moves an angle of 1.25, when it is at statue, otherwise it move 1.25/cat_radius meters
    local cat_move_in_dist=1
    local cat_arc_dist=1.25
    local cat_unit_angle_change=$(divide $cat_arc_dist $old_cat_radius)
    local new_cat_angle=$( angle_reduce $( add $old_cat_angle $cat_unit_angle_change )  )
    local new_cat_radius=$old_cat_radius



    #=== MOUSE ===#
    # mouse always moves an angle  of 1

    local mouse_radius=$statue_radius
	local mouse_arc_dist=1
    local mouse_unit_angle_change=$(divide $mouse_arc_dist $mouse_radius)
    local new_mouse_angle=$( angle_reduce  $(add $old_mouse_angle $mouse_unit_angle_change) )

    #== ADJUSTMENTS assuming cat sees mouse and changes radius ==#

	# Move the cat first
	#does_cat_see_mouse <cat angle> <cat radius> <mouse angle>
	#TODO: change to statue radius, is it given since I just invented it?
    if [ $(float_lte $(subtract $old_cat_radius $statue_radius) 0) -ne $TRUE ] && [ $(does_cat_see_mouse $old_cat_angle $old_cat_radius $old_mouse_angle) -eq $TRUE ] ; then
		# Move the cat in if it's not at the statue and it can see the mouse
		#move 1n toward statue

        echo $step cat sees mouse ca:$old_cat_angle, cr:$old_cat_radius, mr:$mouse_radius, ma:$old_mouse_angle >> "$LOG"
		if [ $(float_gt $(subtract $old_cat_radius $cat_move_in_dist) $statue_radius) -eq $TRUE ]; then
			new_cat_radius=$( subtract $old_cat_radius $cat_move_in_dist )
		else
			new_cat_radius=$statue_radius
		fi
        new_cat_angle=$old_cat_angle
		
	else
		# Move the cat around if it's at the statue or it can't see the mouse
		# Check if the cat caught the mouse
		#If the cat can't see the mouse, the cat circles 1.25 meters counterclockwise around the statue.
		if [ $( angle_between $old_cat_angle $new_mouse_angle $new_cat_angle ) -eq $TRUE ]; then
	        state=${CAUGHT}

            echo $step cat catches mouse ca:$old_cat_angle, cr:$old_cat_radius, mr:$mouse_radius, ma:$old_mouse_angle >> "$LOG"
        else

            echo $step cat chasing mouse ca:$old_cat_angle, cr:$old_cat_radius, mr:$mouse_radius, ma:$old_mouse_angle >> "$LOG"
	    fi

	fi


	#TODO: change to statue radius, is it given since I just invented it?
    # Now move the mouse if it wasn't caught
    if [ ${state} -ne $CAUGHT ]; then
        # Move the mouse #already moved

        #witless mouse moves one meter counterclockwise around the statue's base
        # Give up if we're at the last step and haven't caught the mouse
        if [ ${step} -eq ${max_steps} ] && [ ${state} -ne $CAUGHT ] ; then
            state=$GIVEUP

            echo $step cat gives up ca:$old_cat_angle, cr:$old_cat_radius, mr:$mouse_radius, ma:$old_mouse_angle >> "$LOG"
        fi
    fi

	echo ${state} ${step} ${new_cat_angle} ${new_cat_radius} ${new_mouse_angle} ${max_steps}
	return ${state}
}

### Main Script ###

if [[ ${#} != 4 ]] ; then
	echo "$0: usage" >&2
	echo "$0 <cat angle> <cat radius> <mouse angle> <max steps>" >&2
	exit 1
else
	echo  "WELCOME TO THE GAME OF CAT AND MOUSE"
	echo
	echo  "next_step <current state> <current step #> <cat angle> <cat radius> <mouse angle> <max steps>"
	echo

fi

# ADD CODE HERE FOR PART 3
max_steps=$4
mouse_angle=$3
cat_radius=$2
cat_angle=$1
START=0
END=$max_steps
i=$START
STATE=$RUNNING
step=$START

echo BEGIN LOG $(date) > "$LOG"
if [ $END -le $i ]; then
    echo $step cat gives up:$cat_angle, cr:$cat_radius, mr:1, ma:$mouse_angle >> "$LOG"
fi
while [[ $i -lt $END ]]
do
	# next_step <current state> <current step #> <cat angle> <cat radius> <mouse angle> <max steps>
	RESULT=$(next_step $STATE $step $cat_angle $cat_radius $mouse_angle $max_steps)
	echo $RESULT

	STATE=$(echo $RESULT| tr -s " " | cut -d" " -f1,1)
    step=$(echo $RESULT| tr -s " " | cut -d" " -f2,2)
	cat_angle=$(echo $RESULT| tr -s " " | cut -d" " -f3,3) #automatically adjusted by number of steps so i commented this out
	cat_radius=$(echo $RESULT| tr -s " " | cut -d" " -f4,4)
	mouse_angle=$(echo $RESULT| tr -s " " | cut -d" " -f5,5)
	max_steps=$(echo $RESULT| tr -s " " | cut -d" " -f6,6)
	echo
	((i = i + 1))

    if [ $STATE -eq $CAUGHT ]; then
        echo "Game Over. Mouse was caught!"
        break
    fi

    if [ $STATE -ne $CAUGHT ] && [ $step -eq $END ]; then
        echo "Game Over. Mouse escaped!"
        break
    fi
done
cat "$LOG"
echo
if [ -f "$LOG" ]; then
    rm "$LOG"
fi
