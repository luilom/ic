
function [avgTotalAccuracy,results,real_results,vectorAccuracy,c_coefficient,gamma_coefficient,avgClass1Accuracy,avgClass2Accuracy,avgClass3Accuracy] = SVMRBF (classificationType,typeNormalization,featuresRange)

labelsPath = '../labels.csv';
dataPath = '../DatiPreprocessed/';

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
    pkg load statistics;
end

addpath(genpath('..'));

if  strcmp(classificationType,'first')==1
    if strcmp(typeNormalization,'standard')==1
        load 'fullMatrix1standard_new.mat' fullMatrix;
    else
        load 'fullMatrix1scaling_new.mat' fullMatrix;
    end
    %fullMatrix = FeaturesFirstClassifier(labelsPath, dataPath);
    %featuresRange= 3:11;
    %featuresRange = [3 5];
    label_column = 12;
    ConfusionMatrix=zeros(3,3,'double');
    numFold=5;
    
    
elseif strcmp(classificationType,'second')==1
    if strcmp(typeNormalization,'scaling')==1
        load 'fullMatrix2standard.mat' fullMatrix;
    else
        load 'fullMatrix2scaling.mat' fullMatrix;
    end
    %fullMatrix = FeaturesSecondClassifier(labelsPath, dataPath);
    %featuresRange = 3:6;
    %featuresRange = [3 4];
    label_column = 7;
    ConfusionMatrix=zeros(2,2,'double');
    numFold=5;
    
end

total_accuracy = 0;
num_classes = length(unique(fullMatrix(:,label_column)));
class_accuracy = zeros(num_classes, 1);

avgTotalAccuracy=0;
avgClass1Accuracy=0;
avgClass2Accuracy=0;
avgClass3Accuracy=0;
numRip=50;
vector_accuracy=zeros(numRip,1);
for rip=1:numRip
%%divido il dataset in training e test
c = cvpartition(fullMatrix(:,label_column),'KFold',numFold);

firstTrainBinary=training(c,1);
firstTestBinary=test(c,1);
firstTrainingSetRange = find(firstTrainBinary)';
firstTestSetRange=find(firstTestBinary)';
trainMatrix = fullMatrix(firstTrainingSetRange, :);

clear test train c;
CRange = -3:3;
GammaRange =-2:0;
numCols=length(CRange)*length(GammaRange);
vectorAccuracy=zeros(3+numFold,numCols); % la prima riga avr� l'esponente, la seconda la media, e le restanti avranno le accuratezze
numCol=1;
for i=CRange(1):CRange(length(CRange))
    c_coefficient=10^i;
    for k=GammaRange(1):GammaRange(length(GammaRange))
        gamma=10^k;
        setup=sprintf('-c %f -g %f -t %d' , c_coefficient, gamma, 2);
        
        c = cvpartition(trainMatrix(:,label_column),'KFold',numFold);
        avarage_accuracy=0;
        for j=1:numFold
            trainBinary=training(c,j);
            testBinary=test(c,j);
            
            trainingSetRange = find(trainBinary)';
            testSetRange=find(testBinary)';
            
            trainingSet = trainMatrix(trainingSetRange, featuresRange);
            testSet=trainMatrix(testSetRange, featuresRange);
            trainLabel = trainMatrix(trainingSetRange, label_column);
            
            model = svmtrain(trainLabel,trainingSet,setup);
            real_results = trainMatrix(testSetRange, label_column);
            [results, accuracy, decision_values] = svmpredict(real_results,testSet,model);
            avarage_accuracy=avarage_accuracy+accuracy(1);
            confusionmat(results,real_results);
            vectorAccuracy(j+3,numCol)=accuracy(1);
        end
        
        avarage_accuracy=avarage_accuracy/numFold;
        total_accuracy = total_accuracy + accuracy(1);
        vectorAccuracy(1,numCol)=i;
        vectorAccuracy(2,numCol)=k;
        vectorAccuracy(3,numCol)=avarage_accuracy;
        clear test train c;
        confusionmat(results,real_results);
        ConfusionMatrix = ConfusionMatrix+confusionmat(results,real_results);
        numCol=numCol+1;
    end
end


%FASE DI TEST

actualAccuracy=1;
actualC = 1;
actualGamma= 1;
for i=1:length(vectorAccuracy)-1
    x = vectorAccuracy(4:size(vectorAccuracy, 1),i);
    y = vectorAccuracy(4:size(vectorAccuracy,1),i+1);
    [h] = ttest2(x,y);
    if(h==1)
        if(vectorAccuracy(3,i)>vectorAccuracy(3,i+1) & vectorAccuracy(3,i)>actualAccuracy)
            actualAccuracy=vectorAccuracy(3,i);
            actualC=vectorAccuracy(1,i);
            actualGamma=vectorAccuracy(2,i);
        elseif(vectorAccuracy(3,i+1)>vectorAccuracy(3,i) & vectorAccuracy(3,i+1)>actualAccuracy)
            actualC=vectorAccuracy(1,i+1);
            actualAccuracy=vectorAccuracy(3,i+1);
            actualGamma=vectorAccuracy(2,i+1);
        end
    end
end

c_coefficient=10^actualC;
gamma_coefficient=10^actualGamma;
setup=sprintf('-c %f -g %f -t %d', c_coefficient,gamma_coefficient,2);

trainingSet = fullMatrix(firstTrainingSetRange, featuresRange);
testSet=fullMatrix(firstTestSetRange, featuresRange);
trainLabel = fullMatrix(firstTrainingSetRange, label_column);

model = svmtrain(trainLabel,trainingSet,setup);
real_results = fullMatrix(firstTestSetRange, label_column);
[results, accuracy, decision_values] = svmpredict(real_results,testSet,model);

total_accuracy = accuracy(1);

percClass1=0;
percClass2=0;
percClass3=0;
if(strcmp(classificationType,'first')==1)
    ConfusionMat=zeros(3,3);
    ConfusionMat=confusionmat(results,real_results);
    percClass1=(ConfusionMat(1,1)/sum(ConfusionMat(:,1)))*100;
    percClass2=(ConfusionMat(2,2)/sum(ConfusionMat(:,2)))*100;
    percClass3=(ConfusionMat(3,3)/sum(ConfusionMat(:,3)))*100;
elseif(strcmp(classificationType,'second')==1)
    ConfusionMat=zeros(2,2);
    ConfusionMat=confusionmat(results,real_results);
    percClass1=(ConfusionMat(1,1)/sum(ConfusionMat(:,1)))*100;
    percClass2=(ConfusionMat(2,2)/sum(ConfusionMat(:,2)))*100;
end

avgTotalAccuracy=avgTotalAccuracy+total_accuracy;
avgClass1Accuracy=avgClass1Accuracy+percClass1;
avgClass2Accuracy=avgClass2Accuracy+percClass2;
avgClass3Accuracy=avgClass3Accuracy+percClass3;
vector_accuracy(rip,1)=total_accuracy;

end

avgTotalAccuracy=avgTotalAccuracy/numRip;
avgClass1Accuracy=avgClass1Accuracy/numRip;
avgClass2Accuracy=avgClass2Accuracy/numRip;
avgClass3Accuracy=avgClass3Accuracy/numRip;
end


