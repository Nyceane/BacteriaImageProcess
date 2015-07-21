%This script is the 2nd step to calculate the inference probability: in
%function crbm_inference_softmax, we get signals from lower layer: 
%I(hj)=sum(W*v)+bias; vice verse; this is the poshidexp parameter. Now I
%deal with the NaN problem, and then I make the code deal with batchsize
%examples at a time, this is very important: computational speed!
%params:
%poshidexp:signals from the lower layer:[hidsize,hidsize,numfilters,batchsize]
%spacing: move step
%output
%hidstates:hidden layer units' states:[hidsize,hidsize,numfilters,batchsize]
%hidprobs: hidden layer units' on probabilities:[hidsize,hidsize,numfilters,batchsize]
%Date:11/22/2014
%by: Dong Nie
function [hidstates hidprobs] = crbm_sample_multrand2(poshidexp, spacing)
% poshidexp is 3d array, now I add it to consider more examples a time
%poshidprobs = exp(poshidexp);%�п��������������Inf,��Ϊ�����ԣ���poshidexp��ĳ��Ԫ�ش���709ʱ��exp����������Inf
%######����һ����ԭʼ����
%poshidprobs=poshidexp;%#####�ҸĵĴ���,��multirand2����������exp(xx)��Ϊ�˷�ֹ����Inf�����,here is to get hij, then used to get probablistic form of hid layer(hidprobs)

batchsize=size(poshidexp,4);
hidstates = zeros(size(poshidexp));%bernoulli units in hidden layer
hidprobs = zeros(size(poshidexp));%p(h=1|v) in hidden layers

%This is not a good choice, to compute example by exmaple, it is slow
%tic;
for i=1:batchsize
    poshidprobs=poshidexp(:,:,:,i);
    poshidprobs_mult = zeros(spacing^2+1, size(poshidprobs,1)*size(poshidprobs,2)*size(poshidprobs,3)/spacing^2);%������ʵ��probabilistic max-pooling
    %poshidprobs_mult(end,:) = 1;%#####ԭʼ����
    poshidprobs_mult(end,:) = 0;%exp(0)=1�ҸĵĴ��룬����multrand������ͳһexp����������ʵ�Ǵ���hidden layerһ����spacingΪ�߳���block��Ӧ�ڵ�pooling layerP(pool=0|hidstates)

    % TODO: replace this with more realistic activation, bases..
    %����Ҫ���ľ��ǰ���lee��ƪ�����и�������P(h(ij)=1|V)�ķ���������sigmoid�������õ�Ӧ������softmax
    %unit�ķ�����exp(I(h(ij)))/(1+sigma(exp(I(h)))),where h is a block where h(ij) is
    %contained in.

    %��������ǽ�һ��block(�����õ���2*2��block)�������unit�ŵ�һ�����������ڻ�Ҫ����pooling
    %layer��P(pool=0|hidstates)�������ּ���һ��,��spacing^2+1��unit,ǰspacing������hidden units
    %on�ĸ��ʣ���һ������pooling layer off�ĸ���
    %here, notice the area of the block is !!!!very important, it directly
    %affect max pooling!!!, it need to check again later.

    for c=1:spacing
        for r=1:spacing
            temp = poshidprobs(r:spacing:end, c:spacing:end, :);
            poshidprobs_mult((c-1)*spacing+r,:) = temp(:);
        end
    end

    %��������Ϊposhidprobs_mult������Inf��ɵ�,normalizationʱ��Inf/Inf=NaN,��������Ҫ�ҵ�Ϊʲô�����Inf
    %to make it 
    [S1 P1] = multrand2(poshidprobs_mult');
    S = S1';
    P = P1';
    clear S1 P1

    % convert back to original sized matrix

    for c=1:spacing
        for r=1:spacing
            hidstates(r:spacing:end, c:spacing:end, :,i) = reshape(S((c-1)*spacing+r,:), [size(hidstates,1)/spacing, size(hidstates,2)/spacing, size(hidstates,3)]);
            hidprobs(r:spacing:end, c:spacing:end, :,i) = reshape(P((c-1)*spacing+r,:), [size(hidstates,1)/spacing, size(hidstates,2)/spacing, size(hidstates,3)]);
        end
    end
end
%toc;
return