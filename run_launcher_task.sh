#!/bin/bash
while :
do
    ./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_play";
	sleep 120;
	./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_beta";
	sleep 120;
	./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_dev";
	sleep 120;
done