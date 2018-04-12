install.packages(class_pack)
library(caret)
library(skimr)
library(RANN)


orange = read.csv("https://raw.githubusercontent.com/selva86/datasets/master/orange_juice_withmissing.csv");
str(orange)

trainRowNumbers = createDataPartition(orange$Purchase,p = 0.8,list= FALSE)
trainData = orange[ trainRowNumbers, ]
testData = orange[ -trainRowNumbers, ]
x = trainData[, 2:18]
y = trainData$Purchase
skimmed = skim_to_wide(trainData)
skimmed[,c(10:16)]

anyNA(trainData)

preProcess_missingdata_model = preProcess(trainData , method = "knnImpute")
trainData_impute = predict(preProcess_missingdata_model, newdata = trainData)

anyNA(trainData_impute)

dummies_model = dummyVars(Purchase~., data = trainData_impute)
trainData_mat = predict(dummies_model, newdata = trainData_impute)
# Warning message:
# In model.frame.default(Terms, newdata, na.action = na.action, xlev = object$lvls) :
# ���� 'Purchase'�� ������ �ƴմϴ�.

trainData_dummy = data.frame(trainData_mat)
preProcess_range_model = preProcess(trainData_dummy, method = "range")
trainData_pre = predict(preProcess_range_model, newdata = trainData_dummy)

#�������
apply(trainData_pre[, 1:10], 2, FUN = function(x) { c("min" = min(x), "max" = max(x)) })
#������ �ϳ��� ��!

trainData_pre$Purchase = y # �Ʊ� ���� �κ� ����


model_rf = train(Purchase ~., data = trainData_pre, method = "rf")
model_rf
plot(model_rf)

varimp_rf = varImp(model_rf)
plot(varimp_rf)

testData2 = predict(preProcess_missingdata_model, testData)
testData3 = predict(dummies_model, testData2)
#Warning message:
#  In model.frame.default(Terms, newdata, na.action = na.action, xlev = object$lvls) :
#  ���� 'Purchase'�� ������ �ƴմϴ�
testData3 = data.frame(testData3)
testData4 = predict(preProcess_range_model, testData3)

########hyper parameter tunning

# method : repeatedcv
# number : 10��.
fitControl <- trainControl(method = 'repeatedcv', number = 7, savePredictions = 'final', classProbs = T, summaryFunction = twoClassSummary)

#method : earth, nnet, ada  // caret 
model_ada = train(class ~., data = trainData_pre, method = 'ada', metric = 'ROC', tuneLength = 5, trControl = fitControl)


#��ó�� �ڵ� �ݵ�� ����
#Ʃ�� ���ϴ´�� �ѹ� �ǽ�, ������ ���� ���� ���;� ��.
#��ó�� �ڵ尡 �ݵ�� �� �־�� ��.

#�ᱹ, ��ó�� + Ʃ���� �ʼ�!

predicted_mars = predict(model_mars2, testData4)
confusionMatrix(reference = testData$Purchase, data = predicted_mars,mode = 'everything', positive='MM')

model_mars2


### HW
url_address = "https://www.dropbox.com/s/4wpkhme7476zdt3/dataset.csv?dl=1"
dataset <- read.csv(url_address)
e-mail : sunnybenlim@gmail.com
#�ʼ��ڵ� : train & test & ��ó�� & tunning & confusion matrix


#output : dataset$class : {good,bad}
#Evaluation : 
#�ݿ��� 24:00
#CONFUSION MATRIX �������.