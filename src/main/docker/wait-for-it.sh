while ! nc -z omservice 38080
do
  echo sleeping;
  sleep 5;
done;
echo connected;
