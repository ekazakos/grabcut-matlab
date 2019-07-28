function [ DFg, DBg] = EM_alternative(img, prevL, K , kvecFg, kvecBg, init)

wFg=zeros(K,1);
wBg=zeros(K,1);
mFg=zeros(K,3);  
mBg=zeros(K,3);
SFg=zeros(3,3,K);
SBg=zeros(3,3,K);

R=img(:,:,1);
G=img(:,:,2);
B=img(:,:,3);
image=[R(:) G(:) B(:)];
DFg=zeros(size(image,1),K);
DBg=zeros(size(image,1),K);
opts = statset('MaxIter',100);

xFg=[R(prevL==1) G(prevL==1) B(prevL==1)];
xBg=[R(prevL==0) G(prevL==0) B(prevL==0)];


if(init==1)
    
 %   rng('default');
 %   [kvecFg, mFg]=kmeans(xFg,K,'emptyaction','singleton','Options',opts);
 %   [kvecBg, mBg]=kmeans(xBg,K,'emptyaction','singleton','Options',opts); 
    [wFg,mFg,SFg,kvecFg] = EM_algorithm(xFg,K,5);
    [wBg,mBg,SBg,kvecBg] = EM_algorithm(xBg,K,5);
end

for i=1:K
    if(init==0)
        wFg(i)=numel(kvecFg==i)/numel(kvecFg);
        wBg(i)=numel(kvecBg==i)/numel(kvecBg);

        mFg(i,:)=mean(xFg(kvecFg==i,:));
        mBg(i,:)=mean(xBg(kvecBg==i,:));

        SFg(:,:,i)=cov(xFg(kvecFg==i,:));
        SBg(:,:,i)=cov(xBg(kvecBg==i,:));
    end  
    DistFg=image-repmat(mFg(i,:),size(image,1),1); 
    DistBg=image-repmat(mBg(i,:),size(image,1),1);
        
    DFg(:,i)=-log(wFg(i))+0.5*log(det(SFg(:,:,i)))+0.5*sum((DistFg/SFg(:,:,i)).*DistFg,2);
    DBg(:,i)=-log(wBg(i))+0.5*log(det(SBg(:,:,i)))+0.5*sum((DistBg/SBg(:,:,i)).*DistBg,2);
end

end

