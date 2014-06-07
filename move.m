function O = move(It,Is,mask_s,c,b,x,y)
%c: center b: bound 
[R C S]  = size(It);
up_radius = c(1)-b(1);
down_radius = b(2)-c(1);
left_radius = c(2)-b(3);
right_radius = b(4)-c(2);
if(y-up_radius<1)
    y = up_radius+1;
end
if(y+down_radius > R)
    y = R - down_radius;
end
if(x-left_radius<1)
    x = left_radius+1;
end
if(x+right_radius > C)
    x = C-right_radius;
end
I  = zeros(size(mask_s,1),size(mask_s,2),3);
I2 = I;
for nu = 1:3
I(:,:,nu) = uint8(~mask_s).*It(y-up_radius:y+down_radius,x-left_radius:x+right_radius,nu) ;
I2(:,:,nu) = uint8(mask_s).*Is(b(1):b(2),b(3):b(4),nu);
end
If = I + I2;
O = It;
O(y-up_radius:y+down_radius,x-left_radius:x+right_radius,:) = If;
