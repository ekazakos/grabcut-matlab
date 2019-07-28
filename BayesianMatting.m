function [ ResIm ] = BayesianMatting( Im, Trimap, NeighNum ,VarC, MaxIter, minL)

fgmap=Trimap==1;
bgmap=Trimap==0;
unkmap=~fgmap&~bgmap;
unkNum=sum(unkmap(:));

F=Im;
F(repmat(~fgmap,[1,1,3]))=0;
B=Im;
B(repmat(~bgmap,[1,1,3]))=0;
alpha=zeros(size(Trimap));
alpha(fgmap)=1;
alpha(unkmap)=NaN;

unkreg=unkmap;
se=strel('square',3);
g = gaussian_fallof(NeighNum,8,'s',[]);
n=1;
erprev=0;
while(n<unkNum)
    
    unkreg=imerode(unkreg,se);
    erodedreg=unkmap&~unkreg;
    [X,Y]=find(erodedreg);
    fprintf('%d\n',sum(unkmap(:)));
    
    if(erodedreg==erprev)
        
        [X,Y]=find(erodedreg);
        for j=1:length(X)
            cx=X(j);cy=Y(j);
            F(cx,cy,:)=Im(cx,cy,:);
            B(cx,cy,:)=0;
            alpha(cx,cy)=1;
            unkmap(cx,cy)=0;
            n=n+1;
            
        end
        
        continue;
    end
    erprev=erodedreg;
    for j=1:length(X)
        
        cx=X(j);cy=Y(j);
        c=reshape(Im(cx,cy,:),3,1);
        apix=getNeighborhood(alpha,cx,cy,NeighNum);
        cpix=getNeighborhood(Im,cx,cy,NeighNum);
        
        fpix=getNeighborhood(F,cx,cy,NeighNum);
        fpix=reshape(fpix,NeighNum*NeighNum,3);
        fweights=(apix.^2).*g;
        fpix=fpix(fweights>0,:);
        fweights=fweights(fweights>0);
        
        bpix=getNeighborhood(B,cx,cy,NeighNum);
        bpix=reshape(bpix,NeighNum*NeighNum,3);
        bweights=((1-apix).^2).*g;
        bpix=bpix(bweights>0,:);
        bweights=bweights(bweights>0);
       %{
        if(isempty(bweights))
            F(cx,cy,:)=Im(cx,cy,:);
            B(cx,cy,:)=0;
            alpha(cx,cy)=1;
            unkmap(cx,cy)=0;
            n=n+1;
            continue;
        end
       %}
        if (length(fweights)<10 || length(bweights)<10)
            continue;
        end
        
        [mf,Sf]=Clustering(fpix,fweights,0.05);
        [mb,Sb]=Clustering(bpix,bweights,0.05);
                
        weights = gaussian_fallof(NeighNum,0.2,'c',cpix);
        ind=~isnan(apix);
        
        weights=weights(ind);
        apix=apix(ind);
        W=sum(weights);
        
        alphainit=sum(apix.*weights)/W;
        
        [ f, b, a ] = linear_system_FBa( mf, Sf, mb, Sb, c, VarC, alphainit, MaxIter, minL );
        F(cx,cy,:)=f;
        B(cx,cy,:)=b;
        alpha(cx,cy)=a;
        unkmap(cx,cy)=0;
        n=n+1;
    end
    
end

alpha=repmat(alpha,[1 1 3]);
ResIm=alpha.*F;

end

function [Rect] = getNeighborhood(mat,cx,cy,N)
[m,n,k]=size(mat);
Rect=nan(N,N,k);
crect=floor(N/2);
xmin=max(1,cx-crect);
xmax=min(m,cx+crect);
ymin=max(1,cy-crect);
ymax=min(n,cy+crect);
rectxmin=crect-(cx-xmin)+1;
rectxmax=crect+(xmax-cx)+1;
rectymin=crect-(cy-ymin)+1;
rectymax=crect+(ymax-cy)+1;
Rect(rectxmin:rectxmax,rectymin:rectymax,:)=mat(xmin:xmax,ymin:ymax,:);

end

function weights = gaussian_fallof(N,sigma,domain,C)
% domain: 's' for spatial domain
%         'c' for color domain

cent=ceil(N/2);
diff=zeros(N^2,1);
if(domain=='s')
    vec=1:N^2;
    s=[N,N];
    [I,J]=ind2sub(s,vec);

    diff=(I-cent).^2 + (J-cent).^2;
    
    
else
    
    ind=sub2ind([N,N],cent,cent);
    C1=reshape(C,N*N,3);
    C2=repmat(C1(ind,:),N^2,1);
    
    diff= sum((C1-C2).^2,2); 
        
end

weights=exp(-diff/(2*(sigma^2)));
weights=reshape(weights,N,N);

end

