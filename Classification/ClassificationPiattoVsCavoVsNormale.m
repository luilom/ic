
function [total_accuracy,class_accuracy,results, real_results] = ClassificationPiattoVsCavoVsNormale (classificationType)



labelsPath = '../labels.csv';
dataPath = '../DatiPreprocessed/';

isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
	pkg load statistics;
end

addpath(genpath('..'));

numRip=20;
numFold=2;


if  strcmp(classificationType,'first')==1
    fullMatrix = FeaturesFirstClassifier(labelsPath, dataPath);
    featuresRange= 3:7;
    label_column = 8;


elseif strcmp(classificationType,'second')==1
    fullMatrix = FeaturesSecondClassifier(labelsPath, dataPath);
    featuresRange = 2:3;
    label_column = 4;
end


total_accuracy = 0;
num_classes = length(unique(fullMatrix(:,label_column)));
class_accuracy = zeros(num_classes, 1);

for i=1:numRip
    c = cvpartition(fullMatrix(:,label_column),'KFold',2);
    trainBinary=training(c,1);
    testBinary=test(c,1);
    
    trainingSetRange = find(trainBinary)';
    testSetRange=find(testBinary)';

    trainingSet = fullMatrix(trainingSetRange, featuresRange);
    testSet=fullMatrix(testSetRange, featuresRange);
    label = fullMatrix(trainingSetRange, label_column);
    results = multisvm(trainingSet, label', testSet);
    real_results = fullMatrix(testSetRange, label_column);
    total_accuracy = total_accuracy + sum(results == real_results)/length(results);
    tab = crosstab(results, real_results);
    for j=1:num_classes
        class_accuracy(j) = class_accuracy(j) + tab(j,j)/sum(tab(:,j));
    end
    clear test train c;
end
total_accuracy = total_accuracy/numRip;
for j=1:num_classes
    class_accuracy(j) = class_accuracy(j)/numRip;
end


end