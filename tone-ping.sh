previous=1 #the previous ping time

PLAY=/usr/local/Cellar/sox/14.4.1/bin/play

function multiply ()
{
    echo "$1 * $2" | bc -l
}

function add ()
{
    echo "$1 + $2" | bc -l
}

# current-frequency previous-frequency duration
function sound ()
{
    FADE="fade q 0.2 $3 0.2"
    SHORT="fade q 0.4 $3 0.4"
    LONG="fade q 0.4 $(add $3 2) 0.4"
    HIGH="$(multiply $2 10)-$(multiply $1 10)"
    DOUBLE="$(multiply $2 2)-$(multiply $1 2)"
    MEDIUM="$(multiply $2 3)-$(multiply $1 3)"
    REVERSE="$(multiply $1 3)-$(multiply $1 3)"
    LOW="$2-$1"
    VOLUME="loudness -10"
    SOFT="loudness -30"
    VSOFT="loudness -40"
    CHORUS="chorus 0.7 0.9 20 0.4 .25 2 -s"
    #$PLAY -q -n synth $3 sine $MEDIUM $SHORT &
    $PLAY -q -n synth $3 sine $LOW sine $MEDIUM $FADE $VOLUME chorus 0.7 0.9 20 0.4 .25 2 -s &
    $PLAY -q -n synth $3 sine $REVERSE $SHORT $VOLUME chorus 0.7 0.9 20 0.4 .25 2 -s &
    $PLAY -q -n synth $(add $3 2) trapezium $DOUBLE $LONG $SOFT bass +12 &
    $PLAY -q -n synth $3 pink $1 $FADE $VSOFT &
    #$PLAY -V0 -n synth $3 trapezium $MEDIUM $FADE $VOLUME &
    #$PLAY -V1 -n synth sin %-12 sin %-9 sin %-5 sin %-2 fade h 0.1 2 0.1
    #$PLAY -V1 -n synth $3 sine $HIGH $FADE gain -12 bass +12 treble -3 &
}

function errsound ()
{
    $PLAY -q -n synth 1.7 brown 80 fade q 0.2 1.7 0.2 loudness -30 &
}

while :
do
    #get the ping time
    time=$(ping -c 1 $1 | sed -n 2p | cut -f 4- -d = | rev | cut -c 4- | rev; exit ${PIPESTATUS[0]});
    success=$? # wether the ping was sucessful
    if [[ $success == 0 ]];
    then
	echo $previous-$time
	sound $time $previous 2
	previous=$time
    else
	errsound
    fi
    sleep 1.25
done


