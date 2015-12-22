%��ȡһ���ļ����µ�����.jpg��Ӧ��patch
function imdata_batch=getImageData4Batch(fpath,batch_size,filtersize,onepatchrow,onepatchcol)
%y = randsample(n,k,replacement) or y = randsample(population,k,replacement) returns a sample 
    %taken with replacement if replacement is true, or without replacement if replacement is false. The default is false.
    images_all=sample_images_all(fpath);
    for i = 1:length(images_all)%��ÿ��ͼƬ��ȡbatch_size��batch_ws��С��ͼƬ(����patch��С)
        imdata = images_all{i};
        rows = size(imdata,1);
        cols = size(imdata,2);

        for batch=1:batch_size%�����һ��imbatch,��һ��ͼƬ����һ��ͼƬsubsample��3��70*70��patch,����ÿ��batch��һ��70*70��patch
            rowidx = ceil(rand*(rows-2*filtersize-onepatchrow))+filtersize + [1:onepatchrow];%ws�Ǿ���˴�С
            colidx = ceil(rand*(cols-2*filtersize-onepatchcol))+filtersize + [1:onepatchcol];
            k=3*(i-1)+batch;%һ��ͼƬȡ����patch
            imdata_batch(:,:,k) = imdata(rowidx, colidx);%��imdata��һ�Ŵ�����ͼƬ)ȡ��patch
            patch_k=imdata_batch(:,:,k);
            imdata_batch(:,:,k) = imdata_batch(:,:,k) - mean(patch_k(:));%��ȥ��ֵ
        end
    end
end