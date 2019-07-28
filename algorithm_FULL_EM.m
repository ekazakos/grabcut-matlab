function [FinalAlpha,dcFg,dcBg] = algorithm_FULL_EM( alpha,img,handles,NumofComp,MaxIterEM,MaxIterFull,T,flag,changed_f)

[M,N]=size(img(:,:,1));

R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
image=[R(:) G(:) B(:)];

%%%%%%%%%%%% Smoothness Term%%%%%%%%%%%%%%%
%{
gradH = img(:,2:end,:) - img(:,1:end-1,:);
gradV = img(2:end,:,:) - img(1:end-1,:,:);

gradH = sum(gradH.^2, 3);
gradV = sum(gradV.^2, 3);
BetaH=1/(2*(mean(gradH(:))));
BetaV=1/(2*(mean(gradV(:))));
hC = exp(-BetaH.*gradH);
vC = exp(-BetaV.*gradV);

hC= [hC zeros(size(hC,1),1)];
vC = [vC ;zeros(1, size(vC,2))];
%}
sc = [0 T;T 0];

%%%%%%%%   8-connectivity   %%%%%%%%%%%%   

E = edges8connected(M,N,1);
Num=size(E,1);
img1=reshape(img,M*N,1,3);
grad=zeros(Num,1,3);
dist=zeros(Num,2);

s=[M,N];
[I1,J1] = ind2sub(s,E(:,1));
[I2,J2] = ind2sub(s,E(:,2));

I=1:Num;
grad(I,1,:)=img1(E(I,1),1,:)-img1(E(I,2),1,:);
dist(I,1)= I2(I)-I1(I);
dist(I,2)= J2(I)-J1(I);
 
dist=sum(dist.^2,2);
grad = sum(grad.^2, 3);
Beta=1/(2*(mean(grad)));
weights=exp(-Beta.*grad)./sqrt(dist);
SparseSmoothness=sparse(E(:,1),E(:,2),weights,M*N,M*N);

%%%%%%%%%%%%% Grab Cut Iterations %%%%%%%%%%%%%%%%%%%%%%%%%%
prevL=double(alpha);

wInitFg=[];
covInitFg=[];
wInitBg=[];
covInitBg=[];
meanInitFg=[];
meanInitBg=[];
FgVals=[R(prevL==1) G(prevL==1) B(prevL==1)];
BgVals=[R(prevL==0) G(prevL==0) B(prevL==0)];

prevL=reshape(prevL,1,M*N);
iter=0;
for i=1:MaxIterFull
    iter=iter+1;
    [wFg,meanFg,covFg]=EM_algorithm(FgVals,NumofComp,MaxIterEM,wInitFg,meanInitFg,covInitFg);
    [wBg,meanBg,covBg]=EM_algorithm(BgVals,NumofComp,MaxIterEM,wInitBg,meanInitBg,covInitBg);
    wInitFg=wFg;meanInitFg=meanFg;covInitFg=covFg;
    wInitBg=wBg;meanInitBg=meanBg;covInitBg=covBg;
    [DataCostFg,DataCostBg] = Costs(wFg,meanFg,covFg,wBg,meanBg,covBg,image,NumofComp,M,N);
    
    %%%%%%%%%% Hard Background Constraints%%%%%%%%%%%%%%%
    DataCostBg(alpha==0) = min(min(DataCostBg));
    
    %%%%%%%%%% Hard Foreground Constraints%%%%%%%%%%%%%%%
    if(flag==1)
        
        DataCostBg(changed_f) = max(max(DataCostBg));
        
    end
   
    dc=cat(1,reshape(DataCostBg,1,M*N),reshape(DataCostFg,1,M*N));
   [currL, energy, energyafter] = GCMex(prevL, single(dc), SparseSmoothness, single(sc),0);
       
    if (nnz(currL(:)~=prevL(:))<numel(prevL)/1000)
        fprintf('Convergence at iteration:%d\n',iter);
        break;
    end
    prevL=double(currL);
    FgVals=[R(prevL==1) G(prevL==1) B(prevL==1)];
    BgVals=[R(prevL==0) G(prevL==0) B(prevL==0)];

end
FinalAlpha=currL;
dcFg=DataCostFg;
dcBg=DataCostBg;



function [DataCostFg,DataCostBg] = Costs(wFg,meanFg,covFg,wBg,meanBg,covBg,image,NumofComp,M,N)

DFg=zeros(size(image,1),NumofComp);
DBg=zeros(size(image,1),NumofComp);

for k=1:NumofComp
    
   XFg=image-repmat(meanFg(k,:),size(image,1),1); 
   XBg=image-repmat(meanBg(k,:),size(image,1),1);
   
   DFg(:,k)=-log(wFg(k))+0.5*log(det(covFg(:,:,k)))+0.5*sum((XFg/covFg(:,:,k)).*XFg,2);
   DBg(:,k)=-log(wBg(k))+0.5*log(det(covBg(:,:,k)))+0.5*sum((XBg/covBg(:,:,k)).*XBg,2);
   
end

DataCostFg=reshape(min(DFg,[],2),M,N);
DataCostBg=reshape(min(DBg,[],2),M,N);
