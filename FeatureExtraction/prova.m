isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
	pkg load statistics;
end

training=FeaturesFirstClassifier (0,4);
label=[1 1 2 2 3 3 1 1 1 1]';
%SVMStruct = svmtrain(training,label');
test=FeaturesFirstClassifier (11,40);
%Group = svmclassify(SVMStruct,test);
results = multisvm(training, label, test); 