function probability = singleProbability(variable, parents, variable_value, parents_value, test_data)

%ESS
alpha = 1;
alpha_ = 1 / 3 / (3^length(parents));

combination = repmat(parents_value, 3, 1);
combination = [combination, (1:3)'];

counts = zeros(3,1);

%only select relevant columns 
data = [];

for i = 1:length(parents),
    data = [data,test_data(:,parents(i))];
end;

%add the value of kid
data = [data,test_data(:,variable)];

%counts
for i = 1:size(combination,1),
    temp = repmat(combination(i,:),size(test_data,1),1);
    temp2 = sum(data==temp,2);
    counts(i) = sum(temp2==(length(parents)+1));
end;

counts = counts + alpha_;

probability = counts(variable_value) / sum(counts);

