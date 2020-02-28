function wr {
  normal="echo -n -e \e[0m";
  blink="echo -n -e \e[5m\e[41m";
  green="echo -n -e \e[42m\e[31m";
  red="echo -n -e \e[41m\e[33m";
  yellow="echo -n -e \e[43m\e[34m";


  d=$(date);
  echo -n "$d: ";
  case $1 in
    "g")    $green; echo -n $2; $normal;    ;;
    "r")    $red; echo -n $2; $normal;    ;;
    "y")    $yellow; echo -n $2; $normal;    ;;
    "b")    $blink; echo -n $2; $normal;    ;;
    *) echo "No color setted for funcion wr: $1"
  esac;
  echo;
}
