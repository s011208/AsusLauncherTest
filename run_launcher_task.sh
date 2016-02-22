#!/bin/bash
while :
do
    ./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_play";
	./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_beta";
	./AsusLauncherTest/launcher_test.sh "b=AsusLauncher_1.4_dev";
	sleep 10;
done