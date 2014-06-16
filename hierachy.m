function O = hierachy(finalList,x,y,hier_list,hier_num_list,level)
%finalList     :final ans list
%x, y,         :point to calc
%hier_list     :hierarchy size:(numb,2,14)
%hier_num_list :hierarchy num for each layer size:(14,1)
%level         :number of layer of the hierarchy
%=======================================================

R = size(hier_list,1);
check_list = ones(R,level);
conum = hier_num_list(level);
coarest =[hier_list(conum,:,level);hier_list(1:conum,:,level)];
Rnew = conum+1;
tempx = ones(Rnew,1)*x;
tempy = ones(Rnew,1)*y;
temp = [tempx tempy];
vec = coarest -temp;

dotv = dot(vec(1:Rnew-1,:),vec(2:Rnew,:),2);
normv = sqrt((vec(:,1).^2)+(vec(:,2).^2));
normvDe = normv(1:Rnew-1).*normv(2:Rnew);
cosAlpha = abs(dotv./normvDe);

check_list(1:Rnew-1,level) = ~(normv(2:Rnew) < ones(Rnew-1,1)*(R/16)) & (cosAlpha < ones(Rnew-1,1)*cos(0.75));

level_num = level-1;
flag = 1;

 while(flag)
     for in = 1:hier_num_list(level_num + 1)
        if(check_list(in,level_num + 1) == 0 )
            vec1 = hier_list(in*2-1,:,level_num)-[x y];
            vec2 = hier_list(in,:,level_num+1)-[x y];
            dotinv = dot(vec1, vec2,2);
             norminv1 = sqrt(vec1(1)^2 + vec1(2)^2);
             norminv2 = sqrt(vec2(1)^2 + vec2(2)^2);
            %cosAlphain = abs(dotinv/(norm(vec1)*norm(vec2)));
            cosAlphain = abs(dotinv/(norminv1*norminv2));
            if(cosAlphain < cos(0.75*(0.8^(level-level_num))))
                check_list(in*2-1,level_num) = 0;
                check_list(in*2+1,level_num) = 0;%bug may happen at the end
                finalList(in*2^level_num-(2^(level_num-1))) = 0;
                finalList(in*2^level_num+(2^(level_num-1))) = 0;
            end   
        end
     end
     if((sum(check_list(1:hier_num_list(level_num),level_num)) == hier_num_list(level_num)) || level_num == 1)
         flag = 0;
     end
    level_num = level_num-1;
 end
 t = 1;
 O = zeros(R,2);
for in  = 1:R
    if(finalList(in) == 0)
        O(t,:) = hier_list(in,:,1);
        t = t+1;
    end
end
O = O(1:t-1,:);