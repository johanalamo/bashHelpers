#!/bin/bash
#get link to generic functions"
if [ -h "$0" ]; then
  realPath="`readlink $0`";
  pathFileFunctions="`dirname $realPath`";
  fullRealPath="${pathFileFunctions}/genericFunctions.sh";
  source $fullRealPath;
else
  source ./genericFunctions.sh
fi;

#exit;
conf_file="androidbashhelper.conf";

if [ ! -f "$conf_file" ]; then
   echo "The file $conf_file does not exists. It has to be created. Here is an example of its content:";
   echo
   echo "app=com.alamo.books";
   echo "package=com.alamo.books";
   echo "activity=MainActivity";
   echo "gradle=gradle  #other option:   ./gradlew ";
   echo; echo;
   exit 1;
fi;

log_file="log.txt";

#get values from androidbashhelper.conf file
app=`cat $conf_file | grep "app=" | awk -F= '{print $2}'`;
pkg=`cat $conf_file | grep "package=" | awk -F= '{print $2}'`;
activity=`cat $conf_file | grep "activity=" | awk -F= '{print $2}'`
gradle=`cat $conf_file | grep "gradle=" | awk -F= '{print $2}'`


#adb connect 192.168.0.58;
passenger_id=$(adb devices -l | grep emulator | grep -oE "transport_id.*$" | awk -F: '{print $2}')
driver_id=$(adb devices -l | grep SM_ | grep -oE "transport_id.*$" | awk -F: '{print $2}')
#passenger_id=1
#driver_id=1
# adb tcpip 5555
echo pass $passenger_id;
echo driv $driver_id;
case $1 in
"c")
	#este debe correrse sin ningun emulador conectado
	adb connect 192.168.0.58;
	echo "ll: $?";
	if [ "$?" == "0" ]; then
		echo exito
	else
		echo fracaso
	fi
exit;

	adb tcpip 5555
	adb devices -l;
	exit;
;;
"logpassenger")
	adb -t $passenger_id shell logcat --pid=$(adb -t $passenger_id shell ps | grep passenger | awk '{print $2}')
	exit
;;
"logdriver")
	adb -t $driver_id shell logcat --pid=$(adb -t $driver_id shell ps | grep driver | awk '{print $2}')
	exit
;;
# passenger section
"cp")
	wr y "Compiling passenger";
	./gradlew assemblePassengerDebug # 2>/tmp/comp_error.txt 1>/tmp/comp_success.txt ;
	r=$?;
	if [ $r -eq 0 ]; then
	  wr g "compilacion de Passenger Debug correcta";
	  echo;
	  exit 0;
	else
	  wr r "FALLO LA COMPILACIÓN DE PASSENGER";
	  echo;
	  exit 1;
	fi
;;
"up")
	wr y "UNINSTALLING passenger";
    adb -t $passenger_id shell cmd package uninstall com.lipo.passenger.debug
    exit
;;
"ip")
	wr y "Installing passenger";
    adb -t $passenger_id install "`pwd`/presentation/build/outputs/apk/passenger/debug/presentation-passenger-debug.apk"

	r=$?;
	if [ $r -eq 0 ]; then
	  wr g "Instalación de Passenger Debug correcta";
	  echo;
	  exit 0;
	else
	  #cat /tmp/comp_error.txt | grep "e: "; 
	  wr r "FALLO LA INSTALACIÓN DE PASSENGER";
	  echo;
	  exit 1;
	fi
    #anterior manejarla con $? 0->exito   otro-> fall{o
    #adb shell am start -n "com.lipo.passenger.debug/com.lipo.presentation.activities.LauncherActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
    exit;
;;
"rp")
    rtext=$(adb -t $passenger_id shell am start -n "com.lipo.passenger.debug/com.lipo.presentation.activities.LauncherActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>&1 1>&1)
    wr y "Running Passenger"
    echo "$rtext"
	r=$(echo $rtext | grep -i "error" | wc -l)
	if [ $r -eq 0 ]; then
	  wr g "Iniciacion de Passenger Debug correcta";
	  echo;
	  exit 0;
	else
	  wr r "FALLO LA Iniciacion DE PASSENGER";
	  echo;
	  exit 1;
	fi
    
    exit;
;;
"tp")
	./a.sh cp && ./a.sh up && ./a.sh ip && ./a.sh rp;
	exit $?
;;
# DRIVER section
"cd")
	wr y "Compiling driver";
	./gradlew assembleDriverDebug 
	r=$?;
	if [ $r -eq 0 ]; then
	  wr g "compilacion de DRIVER Debug correcta";
	  echo;
	  exit 0;
	else
	  wr r "FALLO LA COMPILACIÓN DE DRIVER";
	  echo;
	  exit 1;
	fi
;;
"ud")
	wr y "UNINSTALLING driver";
    adb -t $driver_id shell cmd package uninstall com.lipo.driver.debug
    exit
;;
"id")
	wr y "Installing driver";
    adb -t $driver_id install "`pwd`/presentation/build/outputs/apk/driver/debug/presentation-driver-debug.apk"

	r=$?;
	if [ $r -eq 0 ]; then
	  wr g "Instalación de Driver Debug correcta";
	  echo;
	  exit 0;
	else
	  wr r "FALLO LA INSTALACIÓN DE Driver";
	  echo;
	  exit 1;
	fi
    exit;
;;
"rd")
    rtext=$(adb -t $driver_id shell am start -n "com.lipo.driver.debug/com.lipo.presentation.activities.LauncherActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>&1 1>&1)
    wr y "Running Driver"
    echo "$rtext"
	r=$(echo $rtext | grep -i "error" | wc -l)
	if [ $r -eq 0 ]; then
	  wr g "Iniciacion de Driver Debug correcta";
	  echo;
	  exit 0;
	else
	  wr r "FALLO LA Iniciacion DE driver";
	  echo;
	  exit 1;
	fi
    
    exit;
;;
"td")
	./a.sh cd && ./a.sh ud && ./a.sh id && ./a.sh rd;
	exit $?
;;
"comkotlin" | "comandroid")
   if [ "$1" = "comkotlin" ]; then
      instruction="compileKotlin";
   else
      instruction="assembleDebug";
   fi;

    first=1;

    while [ "$2" = "-r" ] || [ $first -eq 1 ]; do
        #$gradle assembleDebug --stacktrace --debug 2>>$log_file 1>>$log_file;
#        $gradle assembleDebug  --rerun-tasks --warning-mode all --full-stacktrace 2>/tmp/comp_error.txt 1>/tmp/comp_success.txt ;
        $gradle $instruction  --rerun-tasks --warning-mode all --full-stacktrace 2>/tmp/comp_error.txt 1>/tmp/comp_success.txt ;
        r=$?;
        if [ $r -eq 0 ]; then
          cat /tmp/comp_success.txt | grep "w: ";
          cat /tmp/comp_error.txt | grep "w: ";
          wr g comp_ok;
          echo;
          exit 0;
        else
          cat /tmp/comp_error.txt | grep "e: "; wr r comp_fail;
          echo;
          exit 1;
        fi
        first=0;
        sleep 3s;
    done;
    exit;
;;
"test")
  $gradle test  --rerun-tasks --debug --full-stacktrace  2>/tmp/test_error.txt 1>/tmp/test_success.txt ;
  r=$?;
  passed=$(cat /tmp/test_success.txt | grep -i -e "${pkg}.*>.*PASSED" | wc -l);
  failed=$(cat /tmp/test_success.txt | grep -i -e "${pkg}.*>.*FAILED" | wc -l);
  #there is an error. when it's success, each passed test is saved twice in the file
  if [ $r -eq 0 ]; then
    #cat /tmp/test_success.txt ;
          #recalculate passed value; because each result appears twice in the file
          cat /tmp/test_success.txt | grep -i -e "${pkg}.*>.*PASSED" | cut -c 40- | sort > /tmp/tmp001.txt;
          rm /tmp/tmp002.txt 2>/dev/null;
          fin=`cat /tmp/tmp001.txt | wc -l`
          for (( c=1; c<=fin; c++ ))
          do
            (( c_uno = c - 1 ))
            actual=$(cat /tmp/tmp001.txt | head -$c | tail -1)
            existe=$(cat /tmp/tmp001.txt | head -$c_uno | grep "$actual" | wc -l)
            if [ $existe -eq 0 ]; then
              echo $actual >> /tmp/tmp002.txt
            fi;
          done
    passed=$(cat /tmp/tmp002.txt | wc -l );

    cat /tmp/test_success.txt | grep  -i -e "FLAGFLAG" -e " e: " -e "WARN" -e " w: " ;
#    cat /tmp/test_error.txt | grep -e "FLAG" -e " e: " -e " w: ";
    cant=$(cat /tmp/test_success.txt | grep PASSED | wc -l);
     wr g "t_ok -> PAS: $passed    FAIL: $failed";
     echo;
     exit 0;
  else
    cat /tmp/test_success.txt | grep -A 3 -i -e "TestEventLogger.*${pkg}.*>.*FAILED";
    cat /tmp/test_error.txt | grep -i -e "completed.*failed";
    cat /tmp/test_error.txt | grep -i -e "Caused.*There were failing tests" | cut -c 167-;
    cat /tmp/test_success.txt | grep -i -e "FLAGFLAG" -e " e: " -e " w: ";
    cat /tmp/test_error.txt | grep -i -e "FLAGFLAG" -e " e: " -e " w: ";
    wr r "t_fail -> PAS: $passed    FAIL: $failed";
    echo;
    exit 1;
  fi;
;;
"dokka")
  $gradle dokka --rerun-tasks 2>/tmp/doc_error.txt 1>/tmp/doc_success.txt ;
  r=$?;
  if  [ $r -eq 0 ]; then
    methodsWithoutDoc=$(cat /tmp/doc_success.txt | grep -i -e "No documentation" | wc -l )
    if [ $methodsWithoutDoc -gt 0 ]; then
      cat /tmp/doc_success.txt | grep -i -e "No documentation";
      wr y "att: $methodsWithoutDoc methods/class without doc"
    else
      echo "all methods are documented";
    fi
    echo "view doc at: file://`pwd`/build/javadoc/"
    wr g "exito dokka";
    exit 0;
  else
    wr r "fail dokka"
    exit 1;
  fi;
;;
"dokkaJar")
  $gradle dokkaJar --rerun-tasks 2>/tmp/doc_error.txt 1>/tmp/doc_success.txt ;
  r=$?;
  if  [ $r -eq 0 ]; then
    wr g "exito dokkaJar";
    exit 0;
  else
    wr r "fail dokkaJar"
    exit 1;
  fi;
;;
"coverage")
  rm  app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.csv 2>/dev/null;
   #  info (COUNTERS) de coverage with jacoco: https://www.eclemma.org/jacoco/trunk/doc/counters.html
   #$gradle testDebugUnitTest JacocoTestReport 2>/tmp/coverage_error.txt 1>/tmp/coverage_success.txt;
   $gradle --rerun-tasks JacocoTestReport 2>/tmp/coverage_error.txt 1>/tmp/coverage_success.txt;
   r=$?;
   if [ $r -eq 0 ]; then
     echo "files in: build/reports/jacoco/test/"
     ls -la build/reports/jacoco/test/;
     echo "generated at: file://`pwd`/build/reports/jacoco/test/html/index.html"
     wr g "coverage generated"
   else
     wr r "error in Cov report"
     exit 1;
   fi;

   #if jacoco test report was not generated in csv format, then exit
   if [ ! -f "app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.csv" ]; then
     wr y "Coverage was not generated in csv format";
     exit 0;
   fi;

#   exit;
   #the following is for when is enabled to generate the report in CSV format,
   #by the moment it is only in html format
   #proccess
   f="/tmp/jacoco.csv";
   f2="/tmp/jacoco02.csv";
   f3="/tmp/jacoco03.csv";
   f4="/tmp/jacoco04.csv";
   rm $f2 2>/dev/null 1>/dev/null;
   rm $f4 2>/dev/null 1>/dev/null;

   cp app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.csv $f;

   #view pretty
   #cat $f3; exit;
   lts=300
   #format $f3 to human readable, output goes to $f4
   total_lines=`cat $f | wc -l`;
   (( reg = total_lines - 1 )) ;
#   echo -e "POINTS\tINSTRUCTIONS\t\tLINES\t\tMETHODS\t\tBRANCHES\t\tCOMPLEXITY\t\tCLASS"> $f4;
   for l in `cat $f | tail -${reg}`; do
   #      5                      6              7                    8          9         10                  11             12                  13             14
   #INSTRUCTION_MISSED	INSTRUCTION_COVERED	BRANCH_MISSED	BRANCH_COVERED	LINE_MISSED	LINE_COVERED	COMPLEXITY_MISSED	COMPLEXITY_COVERED	METHOD_MISSED	METHOD_COVERED

   #   inst_por=`echo $l | awk -F, '{print $1 }'`;
      inst_mis=`echo $l | awk -F, '{print $4 }'`;
      inst_cov=`echo $l | awk -F, '{print $5 }'`;
      (( inst_tot = inst_mis + inst_cov ));
      if [ $inst_tot -eq 0 ]; then  inst_por=100;
         else   (( inst_por = inst_cov * 100 / inst_tot ));   fi;

      branch_mis=`echo $l | awk -F, '{print $6 }'`;
      branch_cov=`echo $l | awk -F, '{print $7 }'`;
      (( branch_tot = branch_mis + branch_cov ));
      if [ $branch_tot -eq 0 ]; then  branch_por=100;
         else   (( branch_por = branch_cov * 100 / branch_tot ));   fi;

      lin_mis=`echo $l | awk -F, '{print $8 }'`;
      lin_cov=`echo $l | awk -F, '{print $9 }'`;
      (( lin_tot = lin_mis + lin_cov ));
      if [ $lin_tot -eq 0 ]; then  lin_por=100;
         else   (( lin_por = lin_cov * 100 / lin_tot ));   fi;

      comp_mis=`echo $l | awk -F, '{print $10 }'`;
      comp_cov=`echo $l | awk -F, '{print $11 }'`;
      (( comp_tot = comp_mis + comp_cov ));
      if [ $comp_tot -eq 0 ]; then  comp_por=100;
         else  (( comp_por = comp_cov * 100 / comp_tot ));   fi;

      met_mis=`echo $l | awk -F, '{print $12 }'`;
      met_cov=`echo $l | awk -F, '{print $13 }'`;
      (( met_tot = met_mis + met_cov ));
      if [ $met_tot -eq 0 ]; then  met_por=100;
         else   (( met_por = met_cov * 100 / met_tot ));   fi;

      (( points = inst_por + branch_por + lin_por + comp_por + met_por ))

      pkg=`echo $l | awk -F, '{print $2 }'`
      cls=`echo $l | awk -F, '{print $3 }'`
      inst_porN=`expr $inst_por + 0`;

      points_s="$points";
      if [ $points -lt 10 ]; then  points_s="00${points}";
      else  if [ $points -lt 100 ]; then
            points_s="0${points}";
      fi;fi;

      link="file://`pwd`/app/build/reports/jacoco/jacocoTestReport/html/${pkg}/${cls}.html";
      link=""
      echo -e "${points_s}\t$cls\tinst(${inst_por}): ${inst_cov}/${inst_tot}\tlines(${lin_por}): ${lin_cov}/${lin_tot}\t methods(${met_por}): ${met_cov}/${met_tot}\tbranch(${branch_por}): ${branch_cov}/${branch_tot}\tComp(${comp_por}): ${comp_cov}/${comp_tot} \t ${link}" >> $f4;
   done;

   #show $f4 with filters
   cant_500=$(cat $f4 | grep "^500" | wc -l);
   cant_total=$(cat $f4 | wc -l)
   (( cant_less_500 = cant_total - cant_500 ))
   echo "graphic report: file://`pwd`/app/build/reports/jacoco/jacocoTestReport/html/index.html";
#   echo -e "classes covered with 100%:\t ${cant_500}/${cant_total}";
#   echo "classes without 100% of coverage (${cant_less_500}): ";
   cat $f4 | sort -r | tail -${cant_less_500};
   if [ $cant_500 -eq $cant_total ]; then
      color="g";
   else
      color="r";
   fi;
   wr $color "cov.gen! 500pt: ${cant_500}. less than 500: ${cant_less_500}";
   exit 0;
;;
"subir")
   git add .
   git commit -m "$2";
   git push;
   git l -1;
   exit;
;;
"viewcolors")
   for i in `seq 0 256`; do
     echo -e "\e[${i}mTEXTO con valor: ${i}\e[0m";
   done;
   echo -e "\e[31m\e[42mTEXTO con valor: ${i}";
   exit;
;;
"run")
	r=1;
    $gradle assembleDebug &&
    $gradle installDriverDebug &&
    adb shell cmd package uninstall -k "${app}" &&
    #el anterior siempre da $?=0
#    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    adb -d install "`pwd`/presentation/build/outputs/apk/driver/debug/presentation-driver-debug.apk" &&
    #anterior manejarla con $? 0->exito   otro-> fall{o
    adb shell am start -n "${app}/${pkg}.${activity}" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER  && r=0;
    date;
    exit $r;
;;
"install")
    adb shell cmd package uninstall -k $app
    #el anterior siempre da $?=0
    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    #anterior manejarla con $? 0->exito   otro-> fall{o
    adb shell am start -n "${app}/${pkg}.${activity}" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
    exit;
;;
"start")
#    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    adb shell am start -n "${app}/${pkg}.${activity}"  -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
#    sleep 1s;
    exit;
;;

"log")
    #help for logcat:   https://developer.android.com/studio/command-line/logcat.html
    p=`adb shell ps -A | grep ${app} | awk '{ print $2 }'`
    echo "PID = $p";
    if [ "$p" != "" ]; then
#a log | grep -e ".\ PersonListActivity" -e ".\ PersonListRecyclerViewAdapter"    
#      adb shell logcat --pid=$p ; #| cut -c 32-
#      adb shell logcat --pid=$p | cut -c 32-
      adb shell logcat --pid=$p *:V;
    else
      echo "not opened";
    fi;
    exit;
;;
"installgradle")
	version="5.6.4";

	#descargar
	wget https://services.gradle.org/distributions/gradle-${version}-bin.zip -P /tmp   2>>/tmp/descargagradle.txt 1>>/tmp/descargagradle.txt;
	if [ "$?" -eq "0" ]; then
		wr g "gradle descargado con exito";
	else
		wr r "ERROR descargando gradle";
		exit 1;
	fi;
	
	#descomprimir
	sudo unzip -d /opt/ /tmp/gradle-${version}-bin.zip  2>>/tmp/instalaciongradle.txt 1>>instalaciongradle.txt
	if [ "$?" -eq "0" ]; then
		wr g "gradle descomprimido con exito";
	else
		wr r "ERROR descomprimiendo gradle";
		exit 1;
	fi;

	#setear archivo para la configuracion de variables de entorno
	echo "export GRADLE_HOME=/opt/gradle-${version}" >>  /tmp/gradle-${version};
	echo 'export PATH=${GRADLE_HOME}/bin:${PATH}' >>  /tmp/gradle-${version};
	sudo mv /tmp/gradle-${version} /etc/profile.d/gradle.sh;

	if [ -f /etc/profile.d/gradle.sh ]; then
		wr g "archivo /etc/profile.d/gradle.sh  creado";
	else
		wr r "fallo la creacion del archivo /etc/profile.d/gradle.sh";
		exit 1;
	fi;
	
	#setear variables de entorno
	source /etc/profile.d/gradle.sh
	
	#colocar el seteo de las variables de entorno en .bashrc
	
	echo "source /etc/profile.d/gradle.sh" >> ~/.bashrc; 

	gradle -v;
;;
"installjava")
  sudo apt install openjdk-8-jdk openjdk-8-jre;
  sudo apt install openjdk-11-jdk openjdk-11-jre;
;;
*)
   wr r "unrecognized option: $1";
   exit 1;
;;
esac;
