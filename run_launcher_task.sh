#!/bin/bash
while :
do
    ./launcher_test.sh "b=AsusLauncher_1.4_play";
	sleep 30;
	./launcher_test.sh "b=AsusLauncher_1.4_beta";
	sleep 30;
	./launcher_test.sh "b=AsusLauncher_1.4_dev";
    sleep 100;
done