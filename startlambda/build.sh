source ../private_keys.sh
export AWS_PAGER=""
location=$(cabal exec which bootstrap)
cabal build -O2 --enable-executable-static
status=$?
if [ $status -eq 0 ];
then
  rm output.zip
  zip -j output.zip $location
  aws lambda update-function-code --function-name $START_LAMBDA_NAME --zip-file fileb://output.zip
else
  echo "Build failed."
fi
