function structureLearning2(variables_num)

training_data = load('training_data');

arc_list = load('-ascii','arc_list.mat');

connection_final = zeros(variables_num);
edges_num = 0;
for i = 1:80,
	connection_final(arc_list(i,1),arc_list(i,2)) = 1;
	
	edges_num = edges_num + 1;

	%limit the number of edges
	if edges_num==51,%the value of 51 is got additionally,make the graph have highest BDeu score,not just a casual value
		break;
	endif;
end;

score = bdeuScore_all(connection_final,1,training_data);
score
save connection_optimal.mat connection_final;
