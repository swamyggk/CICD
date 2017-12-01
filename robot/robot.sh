echo "Execute robot framework: Connect to Oracle, test on sample project services"

HOSTNAME=$1
PORT=$2
DBURL=$3

echo "HOSTNAME=$1"
echo "PORT=$2"
echo "DBURL=$3"

pybot --variable hostname:${HOSTNAME} --variable port:${PORT} --variable dbConnectionStr:${DBURL} tests/sampletest.robot
