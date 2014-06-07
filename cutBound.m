function [O bound center]  = cutBound(I)

[R C] = size(I);
flag_up = 0;

right = 0;
left = C;
for in1 = 1:R
    for in2 = 1:C
        if(I(in1,in2) == 1)
            if(flag_up ==0)
            up = in1;
            flag_up = 1;
            end
            down = in1;
            if(in2>right)
                right = in2;
            end
            if(in2<left)
                left = in2;
            end
        end
    end
end
bound = [up down left right];
center = [round((up+down)/2),round((left+right)/2)];
O = I(up:down,left:right);