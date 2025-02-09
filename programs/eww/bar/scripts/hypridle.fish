#! /usr/bin/env fish

mkdir /tmp/eww

# Create a named pipe if it doesn't exist
set fifo /tmp/eww/hypridle
test -p $fifo; or mkfifo $fifo

if test 0 = (pidof hypridle || echo 0)
    echo caffeine
else
    echo ciao
end

# Keep reading even if the writer closes
while true
    # Read line-by-line and process input
    cat $fifo && if test 0 = (pidof hypridle || echo 0)
        echo caffeine
    else
        echo ciao
    end
end
