set -x #echo on 

if [[ "$1" != "cover" ]]
then
	TEST_DIR="checks/${1}_ch0"
	TEST_SBY="checks/${1}_ch0.sby"
else
	TEST_DIR="checks/cover"
	TEST_SBY="checks/cover.sby"
fi

sby -d $TEST_DIR -f $TEST_SBY 
