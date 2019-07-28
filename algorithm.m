function FinalAlpha = algorithm( alpha,img,NumofComp,MaxIterFull,T,flagf,flagb,changed_f,changed_b)

[M,N]=size(img(:,:,1));
%%%%%%%%%%%% Smoothness Term%%%%%%%%%%%%%%%
%{
%%%%%%%    4-connectivity         %%%%%%%%
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

%%%%%%%%%%%% K initialization with Kmeans%%%%%%%%%%%%%%%%%%%%
kvecFg=[];
kvecBg=[];
[DFg, DBg] = EM_alternative(img, prevL, NumofComp , kvecFg, kvecBg, 1);
prevL=reshape(prevL,1,M*N);
iter=0;
for i=1:MaxIterFull
    iter=iter+1;
    DataCostFg=reshape(min(DFg,[],2),M,N);
    DataCostBg=reshape(min(DBg,[],2),M,N);
    
    %%%%%%%%%% Hard Background Constraints%%%%%%%%%%%%%%%
    DataCostBg(prevL==0) = min(min(DataCostBg));
    DataCostFg(prevL==0) = max(max(DataCostFg));
    
    if(flagf==1)
        DataCostFg(changed_f) = min(min(DataCostFg));
        DataCostBg(changed_f) = max(max(DataCostBg));     
    end
    
    if(flagb==1)
        DataCostBg(changed_b) = min(min(DataCostBg));
        DataCostFg(changed_b) = max(max(DataCostFg));     
    end
 
    dc=cat(1,reshape(DataCostBg,1,M*N),reshape(DataCostFg,1,M*N));
    [currL, energy, energyafter] = GCMex(prevL, single(dc), SparseSmoothness, single(sc),0);
    fprintf('Energy:%f  Energy After:%f\n',energy,energyafter);
    if(i<MaxIterFull)
        
  %      if (nnz(currL(:)~=prevL(:))<numel(prevL)/1000)
   %         fprintf('Convergence at iteration :%d\n',iter);
   %         break;
  %      end
        
        [C, kvecFg]=min(DFg(currL(:)==1,:),[],2);
        [C, kvecBg]=min(DBg(currL(:)==0,:),[],2);

        [DFg, DBg] = EM_alternative(img, currL, NumofComp , kvecFg, kvecBg, 0);
        
        prevL=double(currL);
    end
end
FinalAlpha=currL;

