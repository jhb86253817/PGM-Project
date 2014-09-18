%para_1 is the number of variables, para_2 is the times to run, para_3 is the ESS value of BDeu score
function structureLearning(variables_num, running_times,alpha)

%+++++++++++++++++++++++++++
training_data = load('training_data');

%run for many times to find most possibile structure to avoid local maximum, total counts of connection stored in it
connection_all = zeros(variables_num);
%accumulate the result, so that the calculation can be distributed
%connection_all = load('-ascii', 'connection_all_13.mat');


for k = 1:running_times,

    %create random matrix to represent connection between variables
    %1 means connected and 0 means not, direction from row variable to column variable
    connection = floor(rand(variables_num,variables_num)*2);

    %a variable also cannot connect itself
    connection = (ones(variables_num,variables_num) - eye(variables_num)) .* connection;

    %cyclic is not allowed,so element ij and ji cannot be both 1, if ij is 1, then ji is 0
    connection_u = triu(connection);
    connection_l = tril(xor(connection,connection') & connection);
    connection = connection_l + connection_u;
    
    %to make connection sparse
    for i = 1:4,
		connection2 = floor(rand(variables_num,variables_num)*2);
        connection = connection & connection2;
    end;
   

    %to speed up
    imrpove_times = 0;
    %-----------------------------------------------------------------------------------------------------
    %iteration stops when there is no improvement
    while 1,
    %go through all possible operators (addition, deletion, reversal), find the one that improves the most
    
    %record the index of the best operator
    index = zeros(1,2);
    %record the type of operator(1 means addition, 2 means deletion, 3 means reversal)
    op_type = 0;
    %record the best improve of the score
    score_delta = 0;

    for i = 1:length(connection),
	    for j = 1:length(connection),
	        if i~=j,
		        %----------------------------------------------------------------------------------
		        %if two nodes are connected, there can be two operators, i.e. deletion and reversal
		        if connection(i,j) == 1,
		            %if delete the edge, calculate the change of the score
		            %find parents
		            [x,y] = find(connection == 1);
		            xy = [x,y];
		            parents = xy(find(xy(:,2)==j),1);
		                                
		            score_before = bdeuScore(j,parents,alpha,training_data);
		                                
		            connection(i,j) = 0;
		            %find parents
		            [x,y] = find(connection == 1);
		            xy = [x,y];
		            parents = xy(find(xy(:,2)==j),1);
		            %++++++++++++++++++++++++++++++++++++
		            if length(parents)>10,
		                continue;
		            endif;
		            %++++++++++++++++++++++++++++++++++++
		            
		            score_after = bdeuScore(j,parents,alpha,training_data);
		            
		            connection(i,j) = 1;
		            %record the best score by now
		            
		            if (score_after - score_before) > score_delta,
		            index = [i,j];
		            op_type = 2;
		            score_delta = score_after - score_before;                        
		            endif;
		                        
		            %----------------------------------------------------------------------------------
		            %if revrese the edge, calculate the change of the score (two variables are changed in this case)
		            %find parents
		            [x,y] = find(connection == 1);
		            xy = [x,y];
		            parents_j = xy(find(xy(:,2)==j),1);
		            parents_i = xy(find(xy(:,2)==i),1);
		            %++++++++++++++++++++++++++++++++++++
		            if length(parents_i)>10 || length(parents_j)>10,
		                continue;
		            endif;
		            %++++++++++++++++++++++++++++++++++++
		                                
		                score_before = bdeuScore(j,parents_j,alpha,training_data) + bdeuScore(i,parents_i,alpha,training_data);
		            
		            connection(i,j) = 0;
		            connection(j,i) = 1;
		            %firstly, check cyclic                
		            if cyclicCheck(connection)==1,
		                connection(i,j) = 1;
		                connection(j,i) = 0;
		                continue;
		            endif;
		            %find parents
		            [x,y] = find(connection == 1);
		            xy = [x,y];
		            parents_j = xy(find(xy(:,2)==j),1);
		            parents_i = xy(find(xy(:,2)==i),1);
		            %++++++++++++++++++++++++++++++++++++
		            if length(parents_i)>10 || length(parents_j)>10,
		                continue;
		            endif;
		            %++++++++++++++++++++++++++++++++++++
		            
		            score_after = bdeuScore(j,parents_j,alpha,training_data) + bdeuScore(i,parents_i,alpha,training_data);
		                                
		            connection(i,j) = 1;
		            connection(j,i) = 0;
		            
		            %record the best score by now                    
		            if (score_after - score_before) > score_delta,
		            index = [i,j];
		            op_type = 3;
		            score_delta = score_after - score_before;                        
		            endif;

		        %----------------------------------------------------------------------------------
		        %if two nodes are not connected, the only operator is addition
		        else,
		            %if add the edge, calculate the change of the score
		            %if the ji element is already 1, no need to add edge for being cyclic
		            if connection(j,i)==1,
		                continue;
		            else,
		                %find parents
		                [x,y] = find(connection == 1);
		                xy = [x,y];
		                parents = xy(find(xy(:,2)==j),1);
		                %++++++++++++++++++++++++++++++++++++
		                if length(parents)>10,
			                continue;
			            endif;
		                %++++++++++++++++++++++++++++++++++++
		                
		                score_before = bdeuScore(j,parents,alpha,training_data);
		                
		                connection(i,j) = 1;
		                %check cyclic
		                if cyclicCheck(connection)==1,
		                    connection(i,j) = 0;
		                    continue;
		                endif;
		                %find parents
		                [x,y] = find(connection == 1);
		                xy = [x,y];
		                parents = xy(find(xy(:,2)==j),1);
		                %++++++++++++++++++++++++++++++++++++
		                if length(parents)>10,
		                    connection(i,j) = 0;
			                continue;
			            endif;
		                %++++++++++++++++++++++++++++++++++++
		                                        
		                score_after = bdeuScore(j,parents,alpha,training_data);
		                
		                connection(i,j) = 0;
		                
		                %record the best score by now                        
		                if (score_after - score_before) > score_delta,
		                index = [i,j];
		                op_type = 1;
		                score_delta = score_after - score_before;                            
		                endif;
		            
		            endif;            
		        endif;
		        %----------------------------------------------------------------------------------
		    endif;
        end;
    end;

    %when no operations can improve the current structure, the current search is over
    if score_delta == 0,
        break;
    endif;

    %when there is an improvement, take the best operation
    if op_type==1,
        connection(index(1),index(2)) = 1;
    elseif op_type==2,
        connection(index(1),index(2)) = 0;
    else,
        connection(index(1),index(2)) = 0;
        connection(index(2),index(1)) = 1;
    endif;

    %count the times of improvements
    imrpove_times = imrpove_times + 1;
    if imrpove_times == 100,
        break;
    endif;

    endwhile;
    %-----------------------------------------------------------------------------------------------------
    connection_all = connection_all + connection;
end;

%------------------------------------------------------------------------------------------------------
%output the result as rank list of arcs
arc_list = zeros(variables_num*(variables_num-1),3);
k=1;
for i = 1:length(connection),
    for j = 1:length(connection),
        if i~=j,
            arc_list(k,1) = i;
            arc_list(k,2) = j;
            arc_list(k,3) = connection(i,j);
            k = k + 1;
        endif;
    end;
end;

%based on probabilities, rank more possible arcs in the front
[sort_list,sort_index] = sort(arc_list(:,3),'descend');
arc_list = arc_list(sort_index,:);
%arc_list
arc_list_letter = arc_list(:,[1,2]);
save arc_list.mat arc_list_letter;
save connection.mat connection;

%save matrix connection_all
save connection_all.mat connection_all;
