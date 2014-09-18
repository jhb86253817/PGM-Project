function paraEstimate()

test_data = load('test_data');

connection = load('-ascii','connection_optimal.mat');

p = ones(size(test_data,1),1);

%for finding parents
[x,y] = find(connection == 1);
xy = [x,y];

for i = 1:size(test_data,1),
    for j = 1:26,
        %find parents        
        parents = xy(find(xy(:,2)==j),1);
        %find value of parents
        parents_value = test_data(i,parents);
        %calculate the probability of variable j
        probability = singleProbability(j,parents,test_data(i,j),parents_value,test_data);
        %accumulate the joint probability
		p(i) = p(i) * probability;
	end;
end;

p = p ./ sum(p);

save probs.mat p;
