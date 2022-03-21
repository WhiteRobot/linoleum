#!/bin/bash

screenWidth=$(xwininfo -root | awk '$1=="Width:" {print $2}')
screenHeight=$(xwininfo -root | awk '$1=="Height:" {print $2}')

bottomBarHeight=50

screenHeight=$(( $screenHeight - $bottomBarHeight ))

halfWidth=$(( $screenWidth / 2 ))
halfHeight=$(( $screenHeight / 2 ))

thirdWidth=$(( $screenWidth / 3 ))

col1Left=0
col2Left=$thirdWidth
col3Left=$(( $thirdWidth * 2 ))

row1Top=0
row2Top=$halfHeight

IFS=$'\n'

activeDesktop=$(wmctrl -d | sed -E -n 's/^([0-9])[^\*]+\*.*/\1/p')

windowArray=($(wmctrl -l | sed -E -n 's/^(0x[0-9a-z]{8})  0 [a-z0-9]+ .*/\1/p'))

windowCount=${#windowArray[@]}

# Randomize the window positions. Later this will be a priority array from a config file.
IFS=$'\n' windowArray=($(sort -R <<<"${windowArray[*]}"))
unset IFS

if [[ "$windowCount" -eq 1 ]]
then
  # A single window full screen.
  wmctrl -ir "${windowArray[0]}" -b add,maximized_vert,maximized_horz
  wmctrl -ir ${windowArray[0]} -e 0,0,0,$screenWidth,$screenHeight
  
elif [[ "$windowCount" -eq 2 ]]
then
  # Two windows side by side.
  wmctrl -ir "${windowArray[0]}" -b remove,maximized_horz
  wmctrl -ir "${windowArray[0]}" -b add,maximized_vert
  wmctrl -ir "${windowArray[0]}" -e 0,0,0,$halfWidth,$screenHeight
  
  wmctrl -ir "${windowArray[1]}" -b remove,maximized_horz
  wmctrl -ir "${windowArray[1]}" -b add,maximized_vert
  wmctrl -ir "${windowArray[1]}" -e 0,$halfWidth,0,$halfWidth,$screenHeight
  
elif [[ "$windowCount" -eq 3 ]]
then
  # A single large window on the left with two smaller windows stacked to the right.
  wmctrl -ir "${windowArray[0]}" -b remove,maximized_horz
  wmctrl -ir "${windowArray[0]}" -b add,maximized_vert
  wmctrl -ir "${windowArray[0]}" -e 0,0,0,$(( $thirdWidth * 2 )),$screenHeight
  
  wmctrl -ir "${windowArray[1]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[1]}" -e 0,$col3Left,0,$thirdWidth,$(( $halfHeight - 35 ))
  
  wmctrl -ir "${windowArray[2]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[2]}" -e 0,$col3Left,$row2Top,$thirdWidth,$halfHeight
  
elif [[ "$windowCount" -eq 4 ]]
then
  # a '4 up' configuration with four windows in equal quadrants.
  wmctrl -ir "${windowArray[0]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[0]}" -e 0,0,0,$halfWidth,$halfHeight
  
  wmctrl -ir "${windowArray[1]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[1]}" -e 0,$halfWidth,0,$halfWidth,$halfHeight
  
  wmctrl -ir "${windowArray[2]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[2]}" -e 0,0,$row2Top,$halfWidth,$halfHeight
  
  wmctrl -ir "${windowArray[3]}" -b remove,maximized_vert,maximized_horz
  wmctrl -ir "${windowArray[3]}" -e 0,$halfWidth,$row2Top,$halfWidth,$halfHeight
  
fi
