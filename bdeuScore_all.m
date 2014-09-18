%calculate the total score of the whole structure
function score_current = bdeuScore_all(connection,alpha,training_data)

score_current = 0;
for i = 1:size(connection,1),
    %find parents
    [x,y] = find(connection == 1);
    xy = [x,y];
    parents = xy(find(xy(:,2)==i),1); 
    score_current = score_current + bdeuScore(i,parents,alpha,training_data);
end;
