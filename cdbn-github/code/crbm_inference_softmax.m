%this script is written to compute information from visible
%layer:I(hj)=1/sigma*sum(viWij)+h_bias
%to compute fast, I add a dimension by batchsize, which can compute more
%example at the same time
%params
%imdata:[patchsize,patchsize,channels(colors),batchsize]
%W: filter:[filtersize^2,channels,numoffilters]
%output
%poshidexp2:hidden layer units' receving information from lower layer:
%[hidsize,hidsize,numfilters,batchsize]
%date:12/31/2014
%by: Dong Nie
function [poshidexp2] = crbm_inference_softmax(imdata, W, hbias_vec, pars)%����P(h=1|V)�ĵ�һ��: I(hij)=hbias+W*V

batchsize=size(imdata,4);
filtersize = sqrt(size(W,1));
numfilters = size(W,3);
numchannel = size(W,2);

%poshidprobs2 = zeros(size(imdata,1)-filtersize+1, size(imdata,2)-filtersize+1, numfilters,batchsize);%��ʼ��numbases��feature map(numbases��filter kernel, ��numbases��weight matrix,�˵Ĵ�С��ws*filtersize)
poshidexp2 = zeros(size(imdata,1)-filtersize+1, size(imdata,2)-filtersize+1, numfilters,batchsize);

%one way to fulfill convolution is to do it for each example from the batchsize: but I have tested, this method is slower.
% tic;
% for n=1:batchsize%compute batch by batch
%     for c=1:numchannel%compute channel by channel%to include 3 color is now ok...
%         H = reshape(W(end:-1:1, c, :),[filtersize,filtersize,numfilters]);
%         poshidexp2(:,:,:,n) = poshidexp2(:,:,:,n) + conv2_mult(imdata(:,:,c,n), H, 'valid');%��filter kernel�ֱ�����������(��imdata)�����
%     end
% end
% toc;
% v1=poshidexp2;
% poshidexp2 = zeros(size(imdata,1)-filtersize+1, size(imdata,2)-filtersize+1, numfilters,batchsize);
% fprintf('another version begin.\n');

% tic;
%another way to fulfill convolution, I believe this is much faster, it is
%because I use convn instead of conv2
%tic
for k=1:numfilters
    for c=1:numchannel
        H = reshape(W(end:-1:1, c, k),[filtersize,filtersize]);%here index from W should be in reverse order
        poshidexp2(:,:,k,:) = poshidexp2(:,:,k,:) + convn(imdata(:,:,c,:), H, 'valid');%��filter kernel�ֱ�����������(��imdata)�����
    end
end
% toc;
% v2=poshidexp2;

%here, the batchsize examples have the same hbais_vec, it still have to check, I think it is ok. 
for b=1:numfilters
    poshidexp2(:,:,b,:) = (1/(pars.std_gaussian)*poshidexp2(:,:,b,:) + hbias_vec(b));
    %poshidprobs2(:,:,b,:) = 1./(1 + exp(-poshidexp2(:,:,b,:)));%sigmoid, it is for lower layer
end

return
