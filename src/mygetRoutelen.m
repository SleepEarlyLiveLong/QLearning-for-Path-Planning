function routelen = mygetRoutelen(Distance,route)
%MYGETROUTELEN - calculate the length of the input route.
%   
%   routelen = mygetRoutelen(Distance,route)
% 
%   Input - 
%   Distance:       a matrix representing the distance between the Direct Connectable 
%                   Points in an undirected graph abstracted from the map;
%   route:          an array representing the previously planned route.
%   Output - 
%   routelen:       the length of the input route.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%%
if isempty(route)
    routelen = [];
else
    routelen = 0;
    side_num = length(route)-1;
    for i = 1:side_num
        if Distance(route(i),route(i+1)) ~= -1
            routelen = routelen+Distance(route(i),route(i+1));
        else
            error('Route planning error!\n');
        end
    end
end

end