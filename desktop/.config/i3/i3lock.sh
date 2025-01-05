#!/bin/bash

rectangles=" "

SR=$(xrandr --query | grep ' connected' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*')
for RES in $SR; do
  SRA=(${RES//[x+]/ })
  CX=$((${SRA[2]} + 25))
  CY=$((${SRA[1]} - 80))
  rectangles+="rectangle $CX,$CY $((CX+300)),$((CY-80)) "
done

TMPBG=/tmp/screen.png
scrot $TMPBG && convert $TMPBG -scale 5% -scale 2000% -draw "fill black fill-opacity 0.5 $rectangles" $TMPBG

i3lock \
  -i $TMPBG \
  --clock --date-str "Type password to unlock..." \
  --inside-color=00000000 --ring-color=ffffffff --line-uses-inside \
  --keyhl-color=d23c3dff --bshl-color=d23c3dff --separator-color=00000000 \
  --insidever-color=fecf4dff --insidewrong-color=d23c3dff \
  --ringver-color=ffffffff --ringwrong-color=ffffffff \
  --radius=20 --ring-width=3 --verif-text="" --wrong-text="" \
  --lock-text="ffffffff" --time-color="ffffffff" --date-color="ffffffff"
#  --time-pos="ix-90:iy-20" \
#  --date-pos="tx+24:ty+25" \
#  --ind-pos="x+290:h-120" 

rm $TMPBG
