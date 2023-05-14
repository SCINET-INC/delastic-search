# record=$1
# oldIndexKeys=$2
echo $record
echo $oldIndexKeys
dfx canister call elastic_search updateIndex "($record, $oldIndexKeys)"
# echo "CALLING"