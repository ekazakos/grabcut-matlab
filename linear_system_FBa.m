function [ F, B, a ] = linear_system_FBa( mf, Sf, mb, Sb ,C, VarC, alphainit, maxIter, minL )

I=eye(3);
ResAll=[];
for i=1:size(mf,2)
    miF=mf(:,i);
    invSf=inv(Sf(:,:,i));
    for j=1:size(mb,2)
    
        miB=mb(:,j);
        invSb=inv(Sb(:,:,j));
        
        a=alphainit;
        a0=alphainit;
        Lprev=-realmax;
        iter=1;
        while(1)
            
            A=[invSf+I*(a^2/VarC^2) I*a*(1-a)/VarC^2;
              I*((a*(1-a))/VarC^2) invSb+I*(1-a)^2/VarC^2];
            B=[invSf*miF+C*(a/VarC^2);
              invSb*miB+C*((1-a)/VarC^2)];
            
            x=A\B;
            F=max(0,min(1,x(1:3)));
            B=max(0,min(1,x(4:6)));
            VarA=0.1+0.1*sqrt(sum((miF-miB).^2));
            k=((a0/(VarA^2))+((C-B)'*(F-B))/(VarC^2))/((1/(VarA^2))+(sum((F-B).^2)/(VarC^2)));
            a=max(0,min(1,k));
            LC=-sum((C-a*F-(1-a)*B).^2)/(VarC^2);
            LF=-((F-miF)'*invSf*(F-miF))/2;
            LB=-((B-miB)'*invSb*(B-miB))/2;
            La=-((a-a0)^2)/(VarA^2);
            L=LC+LF+LB+La;
        
            if(iter>=maxIter || abs(L-Lprev)<=minL)
                break;
            end
            Lprev=L;
            iter=iter+1;
        end
        res.F=F;
        res.B=B;
        res.a=a;
        res.L=L;
        ResAll=[ResAll;res];
        
    end
end
[~,ind]=max([ResAll.L]);
F=ResAll(ind).F;
B=ResAll(ind).B;
a=ResAll(ind).a;
end

