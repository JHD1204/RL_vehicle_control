clear
count=400;
[x1,y1,theta1,kr1]=straight([0,0],[20,0],0,count);

[x2, y2, theta2, kr2]=sincos(10,0.02*pi,20);

[x3, y3, theta3, kr3]=straight([120,0],[140,0],0,count);

[x4, y4, theta4, kr4]=sincos(20,0.02*pi,140);

xr=[x1,x2,x3,x4];
yr=[y1,y2,y3,y4];
thetar=[theta1,theta2,theta3,theta4];
kappar=[kr1,kr2,kr3,kr4];

figure(1)
plot(xr,yr,'linewidth',3);
xlabel('x(m)');
ylabel('y(m)');
figure(2)
plot(xr,thetar,'linewidth',3);
figure(3)
plot(xr,kappar,'linewidth',3);
 
%% 如果出现sfunction无法计算s1值的问题，可以把规划半径r加大一点(自定义的函数)
function[xr,yr,thetar,kr]=straight(init_coord,end_coord,init_angle,count)
delta_x=(end_coord(1)-init_coord(1))/(count-1);
delta_y=(end_coord(2)-init_coord(2))/(count-1);
for i=1:count
    xr(i)=init_coord(1)+delta_x*i;
    yr(i)=init_coord(2)+delta_y*i;
    thetar(i)=init_angle;
    kr(i)=0;
end      
end

function[xr,yr,thetar,kr] = sincos(k1, k2 , x0)
xr = x0:0.05:x0+2*pi/k2;
yr = k1 * cos(k2 * xr - pi - x0*k2) + k1;
dy2 = - k1 * k2 * sin(k2 * xr - pi - x0*k2);
thetar = atan(dy2);
ddy2 = - k1 * k2 * k2 * cos(k2 * xr - pi - x0*k2);
n = size(xr);
kr = zeros(n);
for i=1:n(2)
    kr(i) = ddy2(i) / ((1 + dy2(i)^2))^(3/2);
end
end
