
function [w,m,S,kvec] = EM_algorithm(x,K,MaxIter)

%%%%%Initialization%%%%%%%

wInit=zeros(K,1);
meanInit=zeros(K,3);
covInit=zeros(3,3,K);

kvec=randi(K,size(x,1),1);

for i=1:K
    
    wInit(i)=numel(kvec==i)/numel(kvec); 
    meanInit(i,:)=mean(x(kvec==i,:));
    covInit(:,:,i)=cov(x(kvec==i,:))+eye(3)*(1e-6);
end


iter=0;
M=size(x,1);
r=zeros(M,K); 

%%%%%%%%%% EM iterations%%%%%%%%%%%%%%
w=wInit;
m=meanInit;
S=covInit;

temp=zeros(M,K);
temp2=zeros(M,K);
for k=1:K

    temp(:,k)=w(k).*mvnpdf(x,m(k,:),S(:,:,k));

end

L=sum(log(sum(temp,2)));

for j=1:MaxIter
    iter=iter+1;
    Lprev=L;
    %%%%%%%%%%%% E-step %%%%%%%%%%%%
    
    for k=1:K
        r(:,k)=w(k).*mvnpdf(x,m(k,:),S(:,:,k));
    end
    r=r./repmat(sum(r,2),[1 K]);
   
    %%%%%%%%%%%%% M-step %%%%%%%%%%%%%
    for i=1:K
        w(i)=sum(r(:,i))/sum(sum(r));
        m(i,:)=sum(bsxfun(@times,r(:,i),x))/sum(r(:,i));
        C=x-repmat(m(i,:),[M 1]);
        D=bsxfun(@times,r(:,i),C);
        S(:,:,i)=D'*C/sum(r(:,i))+eye(size(x,2))*(1e-6);
    end
    %%%%%%% Calculation of Log Likelihood and Lower Bound
   

    for k=1:K

        temp(:,k)=w(k).*mvnpdf(x,m(k,:),S(:,:,k));
        temp2(:,k)= r(:,k).*log(w(k).*mvnpdf(x,m(k,:),S(:,:,k))./r(:,k));

    end
    L=sum(log(sum(temp,2)));
    B=sum(sum(temp2,2));
  %  fprintf('Iteration:%d      L:%f     B:%f\n',iter,L,B);
    if(abs(L-Lprev) <= 1e-4)
        break;
    end
end

%fprintf('Number of EM iterations : %d\n',iter);

[~,kvec]=max(r,[],2);

