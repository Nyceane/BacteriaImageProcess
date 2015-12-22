function [S P] = multrand2(P)
% P is 2-d matrix: 2nd dimension is # of choices

% sumP = row_sum(P); 
tempP=P;
for i=1:size(P,1)
    maxi=max(P(i,:));
    P(i,:)=P(i,:)-maxi;
end
P=exp(P);
tempP1=P;
% if (sum(sum(isnan(P)))>=1)
%     fprintf('P in multrand2 function have %g NaN value\n',sum(sum(isnan(P))));
%     P
% end
sumP = sum(P,2);
P = P./repmat(sumP, [1,size(P,2)]);%�����ҵ�������ĵط��ˣ�ԭ��������
%���գ�ȷ���ˣ�����ΪP����Inf��sumP��Ҳ��Inf(���ܸ���),��Inf/Infʱ�������NaN
%���ԣ���������PΪʲô�����Inf��

% if (sum(sum(isnan(P)))>=1)
%     fprintf('P in multrand2 function have %g NaN value\n',sum(sum(isnan(P))));
%     P
% end

%������Bernoulli���Ĺ���
cumP = cumsum(P,2);
% rand(size(P));
unifrnd = rand(size(P,1),1);
temp = cumP > repmat(unifrnd,[1,size(P,2)]);
Sindx = diff(temp,1,2);%������һ�׽���΢��(ʵ�ʾ���������������)
S = zeros(size(P));
S(:,1) = 1-sum(Sindx,2);
S(:,2:end) = Sindx;

end
