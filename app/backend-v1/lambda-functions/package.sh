LAMBDA_NAME="<lambda function name here>"
cd package
zip -r ../$LAMBDA_NAME.zip .
cd ..
zip -g $LAMBDA_NAME.zip lambda_function.py