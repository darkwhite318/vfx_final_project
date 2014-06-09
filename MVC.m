function r = MVC(x,y,spb,diff)
%==================================
%x, y: position
%spb : source patch boundary
%diff:color diffrence
%r   :three r for RGB  
%==================================

%add first point to the last
R = size(spb,1);
spb  = [spb(R,:);spb];
R = R+1;
tempx = ones(R,1)*x;
tempy = ones(R,1)*y;
temp = [tempx tempy];
vec = spb - temp;

dotv = dot(vec(1:R-1,:),vec(2:R,:),2);
normv = sqrt((vec(:,1).^2)+(vec(:,2).^2));
normvDe = normv(1:R-1).*normv(2:R);
cosAlpha = dotv./normvDe;

tanAlpha = sqrt(ones(R-1,1) - cosAlpha.^2)./(ones(R-1,1) + cosAlpha);
tanAlpha = [tanAlpha;tanAlpha(1)];
wi = (tanAlpha(1:R-1) + tanAlpha(2:R))./ normv(2:R);

s = sum(wi);
lamda = [wi/s wi/s wi/s];

%sum is tooooooooo slow!!!!!!
v = sum(lamda.*diff);
t = 1:3;
r(1,1,t) = v(t);
%lamda = wi/s;







