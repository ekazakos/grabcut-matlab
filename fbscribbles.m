function [gg1]=fbscribbles(im1,medianC,hObject, handles)
gg1=im2double(im1);
strokeW=5;
gg=rgb2gray(gg1);

imshow(im1,'Parent',handles);
[xx,yy]=meshgrid(1:256);xx=xx-128;yy=yy-128;
hold on;
x=[];
y=[];

[sx,sy]=size(gg);
while(1)
    [xx,yy,button]=ginput(1);
    
    if (button==99);% 'c'
        % first figure out luminances
        
         mask=0;
        for i=2:length(x)
            x0=x(i-1);y0=y(i-1);
            x1=x(i);y1=y(i);
            mask=mask+drawLine([x0 y0],[x1 y1],strokeW,sx,sy);
        end
        mask=(mask>0);
        for cc=1:3
            gg1(:,:,cc)=mask*medianC(cc) ...
                +(1-mask).*gg1(:,:,cc);
        end
        
        imshow(gg1,'Parent',handles);
        x=[];y=[];
        hold on;
    elseif(button==27)
            break;
    else

    hold(handles,'on');
    plot(xx,yy,'x');
    x=[x;xx];
    y=[y;yy];
    end
   
end
gg1=im2uint8(gg1);
   
    
function [mask]=drawLine(x0,x1,strokeW,sx,sy)
[xG,yG]=meshgrid(1:sy,1:sx);
mask=zeros(sx,sy);
d=x1-x0;
step=strokeW/norm(d);
for t=0:step:1
    xn=x0+t*d;
    dImage=(xG-xn(1)).^2+(yG-xn(2)).^2;
    mask=mask+(dImage<strokeW^2);
end
mask=(mask>0);


