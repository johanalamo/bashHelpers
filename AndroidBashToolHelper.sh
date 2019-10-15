log_file="log.txt";
app="com.alamo.boardsgame";
pkg="threeinline.alamo.com.threeinline";
#activity="PlayLocalGameActivity"
activity="MenuActivity"

normal="echo -n -e \e[0m";
blink="echo -n -e \e[5m";
green="echo -n -e \e[42m\e[31m";
red="echo -n -e \e[41m\e[33m";
yellow="echo -n -e \e[43m\e[34m";

function wr {
  d=$(date);
  echo -n "$d: ";
  case $1 in
    "g")    $green; echo -n $2; $normal;    ;;
    "r")    $red; echo -n $2; $normal;    ;;
    "y")    $yellow; echo -n $2; $normal;    ;;
    *) echo "otro"
  esac;
  echo;
  #statements
}

# esta es la forma de correr un test unitario (incluye la clase y el método)
#  ./gradlew :app:testDebugUnitTest --tests "threeinline.com.alamo.threeinline.ClasePruebaTest.metodoPrueba_isCorrect" --warning-mode all
# y coloca el resultado en     app/build/reports/tests/testDebugUnitTest
#   ./gradlew test --warning-mode all --continue
#
# otro ejemplo:
# ./gradlew :app:testDebugUnitTest --tests "threeinline.com.alamo.threeinline.ClasePruebaTest.metodoPrueba_isCorrect" 2>/dev/null 1>/dev/null ; echo $?
case $1 in
"com")
    first=1;

    while [ "$2" = "-r" ] || [ $first -eq 1 ]; do
        #./gradlew assembleDebug --stacktrace --debug 2>>$log_file 1>>$log_file;
        ./gradlew assembleDebug  --rerun-tasks --warning-mode all --full-stacktrace 2>/tmp/comp_error.txt 1>/tmp/comp_success.txt ;
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
  ./gradlew :app:testDebugUnitTest  --rerun-tasks --debug --full-stacktrace  2>/tmp/test_error.txt 1>/tmp/test_success.txt ;
  r=$?;
  passed=$(cat /tmp/test_success.txt | grep -i -e "${app}.*PASSED" | wc -l);
  failed=$(cat /tmp/test_success.txt | grep -i -e "${app}.*FAILED" | wc -l);
  if [ $r -eq 0 ]; then
    #cat /tmp/test_success.txt ;
    cat /tmp/test_success.txt | grep  -i -e "FLAGFLAG" -e " e: " -e "WARN" -e " w: " ;
#    cat /tmp/test_error.txt | grep -e "FLAG" -e " e: " -e " w: ";
    cant=$(cat /tmp/test_success.txt | grep PASSED | wc -l);
     wr g "t_ok -> PAS: $passed    FAIL: $failed";
     echo;
     exit 0;
  else
    cat /tmp/test_success.txt | grep -A 3 -i -e "TestEventLogger.*${app}.*>.*FAILED";
    cat /tmp/test_error.txt | grep -i -e "completed.*failed";
    cat /tmp/test_error.txt | grep -i -e "Caused.*There were failing tests" | cut -c 167-;
    cat /tmp/test_success.txt | grep -i -e "FLAGFLAG" -e " e: " -e " w: ";
    cat /tmp/test_error.txt | grep -i -e "FLAGFLAG" -e " e: " -e " w: ";
    wr r "t_fail -> PAS: $passed    FAIL: $failed";
    echo;
    exit 1;
  fi;
;;
"coverage")
   #  info (COUNTERS) de coverage with jacoco: https://www.eclemma.org/jacoco/trunk/doc/counters.html
   ./gradlew testDebugUnitTest JacocoTestReport 2>/tmp/coverage_error.txt 1>/tmp/coverage_success.txt;

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
   echo "graphic report: file:///home/jalamo/projects/csync/app/build/reports/jacoco/jacocoTestReport/html/index.html";
#   echo -e "classes covered with 100%:\t ${cant_500}/${cant_total}";
#   echo "classes without 100% of coverage (${cant_less_500}): ";
   cat $f4 | sort -r | tail -${cant_less_500};
   if [ $cant_500 -eq $cant_total ]; then
      color="g";
   else
      color="r";
   fi;
   wr $color "cov.gen! 500pt: ${cant_500}. less than 500: ${cant_less_500}";
   exit;
   # con esta instrucción se va generando alguito....
   # esta la genere yo
   rm -R salidaJacoco/*;
       java -jar /home/jalamo/Downloads/jacoco-0.8.5-20190830.011554-47/lib/jacococli.jar report \
   --classfiles ./app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes/threeinline/alamo/com/threeinline/ \
   --classfiles ./app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes/threeinline/com/alamo/threeinline/ \
   --classfiles ./app/build/intermediates/javac/debugAndroidTest/compileDebugAndroidTestJavaWithJavac/classes/threeinline/com/alamo/threeinline/test/ \
   --classfiles ./app/build/tmp/kotlin-classes/debug/threeinline/com/alamo/threeinline \
   --classfiles ./app/build/tmp/kotlin-classes/debug/threeinline/com/alamo/threeinline/business/exceptions/ \
   --classfiles ./app/build/tmp/kotlin-classes/debug/threeinline/com/alamo/threeinline/business/ \
   --classfiles ./app/build/tmp/kotlin-classes/debugUnitTest/threeinline/com/alamo/threeinline/ \
   --classfiles ./app/build/tmp/kotlin-classes/debugUnitTest/threeinline/com/alamo/threeinline/ \
   --classfiles ./app/build/tmp/kotlin-classes/debugAndroidTest/threeinline/com/alamo/threeinline/ \
   --html salidaJacoco/;

   #--classfiles ./app/build/tmp/kotlin-classes/releaseUnitTest/threeinline/com/alamo/threeinline/ \
   #--classfiles ./app/build/tmp/kotlin-classes/release/threeinline/com/alamo/threeinline/business/exceptions/ \
   #--classfiles ./app/build/tmp/kotlin-classes/release/threeinline/com/alamo/threeinline/business/ \
   #--classfiles ./app/build/tmp/kotlin-classes/release/threeinline/com/alamo/threeinline/ \
   #--classfiles ./app/build/intermediates/javac/release/compileReleaseJavaWithJavac/classes/threeinline/com/alamo/threeinline/ \
   #--classfiles ./app/build/intermediates/javac/release/compileReleaseJavaWithJavac/classes/threeinline/alamo/com/threeinline/exceptions/ \
   #--classfiles ./app/build/intermediates/javac/release/compileReleaseJavaWithJavac/classes/threeinline/alamo/com/threeinline/business/ \

   #--classfiles ./app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes/threeinline/alamo/com/threeinline/exceptions/ \
   --classfiles ./app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes/threeinline/alamo/com/threeinline/business \

   exit
   # y esta es generada por android studio
   /home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/jre/bin/java \
   -ea \
   -javaagent:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/intellij-coverage-agent-1.0.495.jar=/tmp/coverageargs \
   -Didea.test.cyclic.buffer.size=1048576 \
   -javaagent:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/idea_rt.jar=39761:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/bin \
   -Dfile.encoding=UTF-8 \
   -classpath /home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/idea_rt.jar:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/plugins/junit/lib/junit-rt.jar:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/plugins/junit/lib/junit5-rt.jar:/home/jalamo/and/Sdk/platforms/android-29/data/res:/home/jalamo/projects/csync/app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debugUnitTest:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debugAndroidTest:/home/jalamo/projects/csync/app/build/generated/res/resValues/androidTest/debug:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debug:/home/jalamo/projects/csync/app/build/generated/res/resValues/debug:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk8/1.2.41/5e34ca185bbea7452d704ed3537a22314a809383/kotlin-stdlib-jdk8-1.2.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-dsl-jvm/1.8.13/269b9d359302123b24cf9b0c73440ff2cbe252f3/mockk-dsl-jvm-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.objenesis/objenesis/2.6/639033469776fd37c08358c6b92a4761feb2af4b/objenesis-2.6.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/4a730b010f068e6adbfa64fa88f6e471/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/7dc9c6187b82e81e7fb7d623ee8e4d76/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b66a6315948aa7e3c2081f616fa20a6f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy-agent/1.8.22/347d063fe292e406f6a71ff64dfd9e8d794f0aba/byte-buddy-agent-1.8.22.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/bd56b7fc3342a9394a867f533ef4cb65/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/cb9d12eb8ac0fec6f0a6e41b889056c2/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/0ea814f599ddcfdaf19df46a393fada7/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/5f647214421517053177f3bbbaa4d782/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/677512acd711e5ed19af19420845dd86/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/1756e4fb85aaaea18bd6559a484f7b6a/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/44d4047f5968d27ea23a6f380702b455/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/f4dc7ccd43ef34388234fccbb0ff0ea6/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-common/1.8.13/259bb06ed31b37e0cbc95c4515edcfbf725cd590/mockk-agent-common-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.mockito4kotlin/annotation/0.3.0/35b66faca95ac3ab96bc5bbbebad42ed553c77af/annotation-0.3.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains/annotations/13.0/919f0dfe192fb4e063e7dacadee7f8bb9a2672a9/annotations-13.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-dsl/1.8.13/430e871125d1eac8f66313252e50cbc01131f4e0/mockk-dsl-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/1986c1dbf521792f085945dd37e73eb7/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.mockito/mockito-core/2.18.3/98aa130476c5d1915dac35b5ad053a7ffcd675bc/mockito-core-2.18.3.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy/1.8.22/4d65fdf7d9755ef7c75f2213f356119d0e68c2cd/byte-buddy-1.8.22.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk/1.8.13/a938c4ee2f635ac233ef1485f9be22c9f60d46e4/mockk-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-api/1.8.13/27a3f333c30f924ffb3e0cd00ac9dd24a2f07e87/mockk-agent-api-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/fe6ac62f51c33b394cc8754aadd35dce/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/fe6ac62f51c33b394cc8754aadd35dce/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/8d88c8169b7abdc13ee5367035b579d8/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/6c6777613b4f9c5fbad493deff8b9d18/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c91bc1464b70930fe59b3401dc68e402/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/8e3cf099d0561b997b7ad213824cd67b/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b98c38b269c563b947c5ad43288268bf/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/81d92bc27cb16d4dc5b2b2f38a3a315c/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/81d92bc27cb16d4dc5b2b2f38a3a315c/res:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-reflect/1.2.71/7512db3b3182753bd2e48ce8d345abbadc40fe6b/kotlin-reflect-1.2.71.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-android-extensions-runtime/1.3.41/8d3d500e42bd74c17fa9586db8ca85c336979d02/kotlin-android-extensions-runtime-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-common/1.3.41/2ecf4aa059427d7186312fd1736afedf7972e7f7/kotlin-stdlib-common-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk7/1.3.41/a1f331124ba069a09e964ad2640c36f140f2c758/kotlin-stdlib-jdk7-1.3.41.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b6c4a8808de8ff21b852d495de352b01/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.annotation/annotation/1.0.2/2f1d597d48e5309e935ce1212eedf5ae69d3f97/annotation-1.0.2.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c9cd80308130e58a0eebe9611b50b329/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c9cd80308130e58a0eebe9611b50b329/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/2c71543c29aa73dd0b7679d1eb9c1c07/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib/1.3.41/e24bd38de28a326cce8b1f0d61e809e9a92dad6a/kotlin-stdlib-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.lifecycle/lifecycle-common/2.0.0/e070ffae07452331bc5684734fce6831d531785c/lifecycle-common-2.0.0.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/6f5c7c5b84b6f198e3c27ad99cad8fea/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/f5bc76b58964a7672bc7efd178910eb7/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/60e79c102e86bea8892026b159d8c832/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-solver/1.1.3/54abe9ffb22cc9019b0b6fcc10f185cc4e67b34e/constraintlayout-solver-1.1.3.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/d90c6ff6cf4da890edf8cfe52fc2026f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.arch.core/core-common/2.0.0/bb21b9a11761451b51624ac428d1f1bb5deeac38/core-common-2.0.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-common/1.8.13/75c09c097c12952f50f861c547d96b8a3990016e/mockk-common-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/823631ada4aba6ce5f08e23128bd902f/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/823631ada4aba6ce5f08e23128bd902f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/a2f62a037228d04e0ee46c7c7741313c/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-jvm/1.8.13/83f3d3a43c7b850ab42881a33ed208a28b986984/mockk-agent-jvm-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/com.nhaarman.mockitokotlin2/mockito-kotlin/2.0.0-alpha04/67d79aa4a8134c1bdbcfa491ea6979c76a0034dc/mockito-kotlin-2.0.0-alpha04.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.collection/collection/1.0.0/42858b26cafdaa69b6149f45dfc2894007bc2c7a/collection-1.0.0.jar:/home/jalamo/projects/csync/app/build/intermediates/sourceFolderJavaResources/test/debug:/home/jalamo/projects/csync/app/build/intermediates/sourceFolderJavaResources/debug:/home/jalamo/.gradle/caches/transforms-2/files-2.1/3d8301118cc4dc9957d1eef7f86ebcc9/android.jar \
   com.intellij.rt.execution.junit.JUnitStarter \
   -ideVersion5 \
   -junit4 threeinline.com.alamo.threeinline.TatetiBoard_subscribeObserver_removeObserver_Test
   exit;

   /home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/jre/bin/java \
   -ea \
   -javaagent:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/intellij-coverage-agent-1.0.495.jar=/tmp/coverage1args \
   -Didea.test.cyclic.buffer.size=1048576 \
   -javaagent:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/idea_rt.jar=33641:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/bin \
   -Dfile.encoding=UTF-8 \
   -classpath /home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/lib/idea_rt.jar:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/plugins/junit/lib/junit-rt.jar:/home/jalamo/Downloads/android-studio-ide-183.5692245-linux/android-studio/plugins/junit/lib/junit5-rt.jar:/home/jalamo/and/Sdk/platforms/android-29/data/res:/home/jalamo/projects/csync/app/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debugUnitTest:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debugAndroidTest:/home/jalamo/projects/csync/app/build/generated/res/resValues/androidTest/debug:/home/jalamo/projects/csync/app/build/tmp/kotlin-classes/debug:/home/jalamo/projects/csync/app/build/generated/res/resValues/debug:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk8/1.2.41/5e34ca185bbea7452d704ed3537a22314a809383/kotlin-stdlib-jdk8-1.2.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-dsl-jvm/1.8.13/269b9d359302123b24cf9b0c73440ff2cbe252f3/mockk-dsl-jvm-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.objenesis/objenesis/2.6/639033469776fd37c08358c6b92a4761feb2af4b/objenesis-2.6.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/4a730b010f068e6adbfa64fa88f6e471/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/7dc9c6187b82e81e7fb7d623ee8e4d76/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b66a6315948aa7e3c2081f616fa20a6f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy-agent/1.8.22/347d063fe292e406f6a71ff64dfd9e8d794f0aba/byte-buddy-agent-1.8.22.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/bd56b7fc3342a9394a867f533ef4cb65/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/cb9d12eb8ac0fec6f0a6e41b889056c2/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/0ea814f599ddcfdaf19df46a393fada7/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/5f647214421517053177f3bbbaa4d782/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/677512acd711e5ed19af19420845dd86/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/1756e4fb85aaaea18bd6559a484f7b6a/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/44d4047f5968d27ea23a6f380702b455/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/f4dc7ccd43ef34388234fccbb0ff0ea6/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-common/1.8.13/259bb06ed31b37e0cbc95c4515edcfbf725cd590/mockk-agent-common-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.mockito4kotlin/annotation/0.3.0/35b66faca95ac3ab96bc5bbbebad42ed553c77af/annotation-0.3.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains/annotations/13.0/919f0dfe192fb4e063e7dacadee7f8bb9a2672a9/annotations-13.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-dsl/1.8.13/430e871125d1eac8f66313252e50cbc01131f4e0/mockk-dsl-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/1986c1dbf521792f085945dd37e73eb7/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.mockito/mockito-core/2.18.3/98aa130476c5d1915dac35b5ad053a7ffcd675bc/mockito-core-2.18.3.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/net.bytebuddy/byte-buddy/1.8.22/4d65fdf7d9755ef7c75f2213f356119d0e68c2cd/byte-buddy-1.8.22.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk/1.8.13/a938c4ee2f635ac233ef1485f9be22c9f60d46e4/mockk-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-api/1.8.13/27a3f333c30f924ffb3e0cd00ac9dd24a2f07e87/mockk-agent-api-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/fe6ac62f51c33b394cc8754aadd35dce/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/fe6ac62f51c33b394cc8754aadd35dce/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/8d88c8169b7abdc13ee5367035b579d8/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/6c6777613b4f9c5fbad493deff8b9d18/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c91bc1464b70930fe59b3401dc68e402/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/8e3cf099d0561b997b7ad213824cd67b/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b98c38b269c563b947c5ad43288268bf/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/81d92bc27cb16d4dc5b2b2f38a3a315c/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/81d92bc27cb16d4dc5b2b2f38a3a315c/res:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-reflect/1.2.71/7512db3b3182753bd2e48ce8d345abbadc40fe6b/kotlin-reflect-1.2.71.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-android-extensions-runtime/1.3.41/8d3d500e42bd74c17fa9586db8ca85c336979d02/kotlin-android-extensions-runtime-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-common/1.3.41/2ecf4aa059427d7186312fd1736afedf7972e7f7/kotlin-stdlib-common-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk7/1.3.41/a1f331124ba069a09e964ad2640c36f140f2c758/kotlin-stdlib-jdk7-1.3.41.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/b6c4a8808de8ff21b852d495de352b01/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.annotation/annotation/1.0.2/2f1d597d48e5309e935ce1212eedf5ae69d3f97/annotation-1.0.2.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c9cd80308130e58a0eebe9611b50b329/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/c9cd80308130e58a0eebe9611b50b329/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/2c71543c29aa73dd0b7679d1eb9c1c07/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib/1.3.41/e24bd38de28a326cce8b1f0d61e809e9a92dad6a/kotlin-stdlib-1.3.41.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.lifecycle/lifecycle-common/2.0.0/e070ffae07452331bc5684734fce6831d531785c/lifecycle-common-2.0.0.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/6f5c7c5b84b6f198e3c27ad99cad8fea/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/f5bc76b58964a7672bc7efd178910eb7/jars/classes.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/60e79c102e86bea8892026b159d8c832/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.constraintlayout/constraintlayout-solver/1.1.3/54abe9ffb22cc9019b0b6fcc10f185cc4e67b34e/constraintlayout-solver-1.1.3.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/d90c6ff6cf4da890edf8cfe52fc2026f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.arch.core/core-common/2.0.0/bb21b9a11761451b51624ac428d1f1bb5deeac38/core-common-2.0.0.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-common/1.8.13/75c09c097c12952f50f861c547d96b8a3990016e/mockk-common-1.8.13.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/823631ada4aba6ce5f08e23128bd902f/res:/home/jalamo/.gradle/caches/transforms-2/files-2.1/823631ada4aba6ce5f08e23128bd902f/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec/junit-4.12.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0/hamcrest-core-1.3.jar:/home/jalamo/.gradle/caches/transforms-2/files-2.1/a2f62a037228d04e0ee46c7c7741313c/jars/classes.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/io.mockk/mockk-agent-jvm/1.8.13/83f3d3a43c7b850ab42881a33ed208a28b986984/mockk-agent-jvm-1.8.13.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/com.nhaarman.mockitokotlin2/mockito-kotlin/2.0.0-alpha04/67d79aa4a8134c1bdbcfa491ea6979c76a0034dc/mockito-kotlin-2.0.0-alpha04.jar:/home/jalamo/.gradle/caches/modules-2/files-2.1/androidx.collection/collection/1.0.0/42858b26cafdaa69b6149f45dfc2894007bc2c7a/collection-1.0.0.jar:/home/jalamo/projects/csync/app/build/intermediates/sourceFolderJavaResources/test/debug:/home/jalamo/projects/csync/app/build/intermediates/sourceFolderJavaResources/debug:/home/jalamo/.gradle/caches/transforms-2/files-2.1/3d8301118cc4dc9957d1eef7f86ebcc9/android.jar \
   com.intellij.rt.execution.junit.JUnitStarter \
   -ideVersion5 @w@/tmp/idea_working_dirs_junit.tmp @/tmp/idea_junit.tmp \
   -socket41161

   #este archivo /tmp/coverage1args tenia este contendio (4 lineas)
   #false
   #false
   #false
   #true

   #con gradlew
   #              ./gradlew testDebugUnitTest JacocoTestReport
   #              ./gradlew JacocoTestReport




;;
"subir")
   git add .
   git commit -m "$2";
   git push;
   git l -1
;;
"temas")
   echo "dataproviders en testing";
   echo "informe de cobertura por clase/metodo";
   echo "sincronizar con gradle por consola";
   echo "design pattern observer";
   echo "design pattern strategy";
   echo "design pattern wrapper";
   echo "con jacoco.... ";
;;
esac;


if [ $1 = "viewcolors" ]; then
    for i in `seq 0 256`; do
        echo -e "\e[${i}mTEXTO con valor: ${i}\e[0m";
    done;
    echo -e "\e[31m\e[42mTEXTO con valor: ${i}";
    exit;
fi

if [ "$2" != ""  ]; then
	activity=$2;
fi
echo "activity: $activity";
#exit;
if [ $1 = "run" ]; then
    ./gradlew assembleDebug &&
    ./gradlew installDebug &&
    adb shell cmd package uninstall -k "${app}" &&
    #el anterior siempre da $?=0
    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    #anterior manejarla con $? 0->exito   otro-> fall{o
    adb shell am start -n "${app}/${pkg}.${activity}" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
    date;
    exit;
fi;
if [ $1 = "install" ]; then
    adb shell cmd package uninstall -k $app
    #el anterior siempre da $?=0
    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    #anterior manejarla con $? 0->exito   otro-> fall{o
    adb shell am start -n "${app}/${pkg}.${activity}" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
    exit;
fi;
if [ $1 = "start" ]; then
#    adb -d install "`pwd`/app/build/outputs/apk/debug/app-debug.apk" &&
    adb shell am start -n "${app}/${pkg}.${activity}"  -a android.intent.action.MAIN -c android.intent.category.LAUNCHER;
#    sleep 1s;
    exit;
fi;

if [ $1 = "log" ]; then
    p=`adb shell ps -A | grep ${app} | awk '{ print $2 }'`
    echo "PID = $p";
    if [ "$p" != "" ]; then
      adb shell logcat --pid=$p | cut -c 32-
    else
      echo "not opened";
    fi;
    exit;
fi;
if [ $1 = "downloaddata" ]; then
      dir="resources/"
      url="http://garbarino-mock-api.s3-website-us-east-1.amazonaws.com/products/"
#      rm -R $dir
#      mkdir $dir;
		products_id=( "0982a08485" "3d77bc3a98" "a20b55dd53" "5b119b7e68" "fac1a6c3d1" "83002e672d" "8f1dcc0c42" "62cb75e2fa" "dfe199bd8c" "f6f8b547a5");
      echo "downloading list, details and reviews (${#products_id[@]} products)";

      curl -s $url | jq '.' > ${dir}list_products.txt
		for (( i=0; i < ${#products_id[@]} ; i=i+1 )) #for from 0 to total elements (cols x rows)
		do
         p=${products_id[$i]}
         curl -s "${url}${p}/" | jq '.' > ${dir}details${p}.txt
         curl -s "${url}${p}/reviews/" | jq '.' > ${dir}reviews${p}.txt
			echo "product id: ${products_id[$i]}"  ;
      done;

      echo;
      echo "downloading images";
      cat "${dir}*.txt"

#      cat resources/*.txt | egrep "\"url\"|\"image_url\"" > ${dir}list_images.txt

      exit
   exit
fi;
if [ $1 = "downloadimages" ]; then
      dir="resources/"
      dirimages=${dir}images
      mkdir $dirimages

      for i in `cat ${dir}list_images.txt`; do
         wget $i;
      done

   exit
fi;

echo "unrecognized option";

exit;




adb install-multiple -r -t /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/dep/dependencies.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_2.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_9.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_0.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_1.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_3.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_4.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_5.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_7.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_6.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_8.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/instant-run-apk/debug/app-debug.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/resources/instant-run/debug/resources-debug.apk
adb shell am start -n "threeinline.alamo.com.threeinlinedos/threeinline.alamo.com.threeinline.MenuActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER


adb install-multiple -r -t /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/dep/dependencies.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_1.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_2.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_0.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_5.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_4.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_3.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_6.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_7.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_9.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/split-apk/debug/slices/slice_8.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/instant-run-apk/debug/app-debug.apk /home/johan/androidprojects/threeinline2/app/build/intermediates/resources/instant-run/debug/resources-debug.apk

# 12:06:37.960 [INFO] [org.gradle.internal.buildevents.BuildLogger] Tasks to be executed: [task ':app:preBuild', task ':app:preDebugBuild', task ':app:compileDebugAidl', task ':app:compileDebugRenderscript', task ':app:checkDebugManifest', task ':app:generateDebugBuildConfig', task ':app:mainApkListPersistenceDebug', task ':app:generateDebugResValues', task ':app:generateDebugResources', task ':app:mergeDebugResources', task ':app:createDebugCompatibleScreenManifests', task ':app:processDebugManifest', task ':app:processDebugResources', task ':app:compileDebugKotlin', task ':app:prepareLintJar', task ':app:generateDebugSources', task ':app:javaPreCompileDebug', task ':app:compileDebugJavaWithJavac', task ':app:compileDebugUnitTestKotlin', task ':app:generateDebugUnitTestSources', task ':app:preDebugUnitTestBuild', task ':app:javaPreCompileDebugUnitTest', task ':app:compileDebugUnitTestJavaWithJavac', task ':app:processDebugJavaRes', task ':app:processDebugUnitTestJavaRes', task ':app:testDebugUnitTest']

# while true; do ./a.sh com && ./a.sh test ; sleep 1s; done

# while true; do ./a.sh com && ./a.sh test && ./a.sh coverage; sleep 1s; done
